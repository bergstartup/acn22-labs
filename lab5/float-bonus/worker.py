from lib.gen import GenInts, GenMultipleOfInRange
from lib.test import CreateTestData, RunIntTest
from lib.worker import *
from scapy.all import Packet, Raw
from scapy.fields import *
import socket
from lib.comm import unreliable_send,receive
import sys

NUM_ITER   = 3     # TODO: Make sure your program can handle larger values
CHUNK_SIZE = 32  # TODO: Define me
Address_to_Send = ("10.0.0.0",8000)
MAX_CHUNK_SIZE = 32

class SwitchML(Packet):
    name = "SwitchMLPacket"
    fields_desc = [
        BitField("num_workers", 0, 32),
        BitField("worker_rank", 0, 32),
        BitField("chunk_size", 0, 32),
        BitField("chunk_id", 0, 32),
        BitField("total_chunks", 0, 32),
        BitField("m_val", 0, 32),
        BitField("slot_mod",0,8),
    ]

def get_m(chunk):
    high = max(chunk)
    count = 0
    while high!=0:
        high = high>>1
        count += 1
    return count-1
    
def AllReduce(soc, rank, data, result, total_worker):
    """
    Perform reliable in-network all-reduce over UDP

    :param str    soc: the socket used for all-reduce
    :param int   rank: the worker's rank
    :param [int] data: the input vector for this worker
    :param [int]  res: the output vector

    This function is blocking, i.e. only returns with a result or error
    """

    # TODO: Implement me
    # NOTE: Do not send/recv directly to/from the socket.
    #       Instead, please use the functions send() and receive() from lib/comm.py
    #       We will use modified versions of these functions to test your program
    #
    #       You may use the functions unreliable_send() and unreliable_receive()
    #       to test how your solution handles dropped/delayed packets
    makeup_data = [0 for i in range(CHUNK_SIZE)]
    makeup_data.extend(data)
    iterations = math.ceil(len(makeup_data)/CHUNK_SIZE)
    scaling_factor = 1
    prev_factor = 1
    soc.settimeout(0.5)
    for i in range(iterations):
        #SML header
        chunk_size = CHUNK_SIZE #Change for last element
        


        #Payload
        #Divide the data arrays into chunk sizes and scale it
        chunk = data[chunk_size*i:chunk_size*(i+1)]
        for j in range(len(chunk)):
            chunk[j] *= scaling_factor
        
        #Get possible m for next chunk
        qc = data[chunk_size*(i+1):chunk_size*(i+2)]
        try:
            m_val = get_m(qc)
        except:
            m_val = 0
        
        
        #Divide the data arrays into chunk sizes
        chunk = data[chunk_size*i:chunk_size*(i+1)]
        payload = bytearray() #Big endianess, because p4 runtime uses it
        filler = [0 for j in range(chunk_size, MAX_CHUNK_SIZE)]
        chunk.extend(filler)
        for element in chunk:
            payload.extend(element.to_bytes(length=4,byteorder="big"))

        #Create frame
        switch_ml_packet = SwitchML(num_workers=int(total_worker), worker_rank=rank, chunk_size=chunk_size, chunk_id=i+1, total_chunks=iterations, m_val = m_val,slot_mod=i%2)/Raw(payload)
        while True:
            #Convert to bytes
            unreliable_send(soc, bytes(switch_ml_packet), Address_to_Send)
            try:
                recvd, _ = receive(soc,1024)
                recvd_chunk = SwitchML(recvd).chunk_id
                if recvd_chunk == i+1:
                    break
            except:
                pass

        #Get scaling factor
        replied_m = SwitchML(recvd).m_val
        prev_factor = scaling_factor
        scaling_factor = int((2**31-1)/(int(total_worker)*(2**replied_m)))

        #Ignore init packet
        if i==0:
            continue
        #take 4 bytes from the payload and create an integer array of the results
        for j in range(chunk_size):
            result[(i-1) * chunk_size + j] = int.from_bytes(SwitchML(recvd).payload.load[j * 4: (j + 1) * 4], "big")

def main():
    rank = GetRankOrExit()

    s = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)# TODO: Create a UDP socket. 
    s.bind(("0.0.0.0",8000))
    # NOTE: This socket will be used for all AllReduce calls.
    #       Feel free to go with a different design (e.g. multiple sockets)
    #       if you want to, but make sure the loop below still works
    
    num_workers = sys.argv[2]
    Log("Started...")
    for i in range(NUM_ITER):
        num_elem = GenMultipleOfInRange(2, 2048, 2 * CHUNK_SIZE) # You may want to 'fix' num_elem for debugging
        data_out = GenInts(num_elem)
        data_in = GenInts(num_elem, 0)
        CreateTestData("udp-rel-iter-%d" % i, rank, data_out)
        AllReduce(s, rank, data_out, data_in, num_workers)
        RunIntTest("udp-rel-iter-%d" % i, rank, data_in, True)
    Log("Done")

if __name__ == '__main__':
    main()
