from lib.gen import GenInts, GenMultipleOfInRange
from lib.test import CreateTestData, RunIntTest
from lib.worker import *
from scapy.all import Packet
import socket
from lib.comm import send,receive

NUM_ITER   = 1     # TODO: Make sure your program can handle larger values
CHUNK_SIZE = 30  # TODO: Define me
Address_to_Send = ("10.0.0.0",8000)
MAX_CHUNK_SIZE = 32


class SwitchML(Packet):
    name = "SwitchMLPacket"
    fields_desc = [
       BitField("num_workers", 0, 32),
       BitField("chunk_size", 0, 32)
    ]

def AllReduce(soc, rank, data, result, total_worker):
    """
    Perform in-network all-reduce over UDP

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
    iterations = math.ceil(len(data)/CHUNK_SIZE)
    print(rank, total_worker)
    for i in range(iterations):
        #SML header
        chunk_size = CHUNK_SIZE #Change for last element
        
        #Payload
        #Divide the data arrays into chunk sizes
        chunk = data[chunk_size*i:chunk_size*(i+1)]
        payload = bytearray() #Big endianess, because p4 runtime uses it
        filler = [0 for i in range(chunk_size, MAX_CHUNK_SIZE)]
        chunk.extend(filler)
        for element in chunk:
            payload.extend(element.to_bytes(length=4,byteorder="big"))

        #Create frame
        switch_ml_packet = SwitchML(num_workers=int(total_worker), chunk_size=chunk_size)/Raw(payload)
        switch_ml_packet.show()
        #Convert to bytes
        send(soc, bytes(switch_ml_packet), Address_to_Send)
        recvd = receive(soc,1024)
        #take 4 bytes from the payload and create an integer array of the results
        for j in range(chunk_size):
            #result[i * chunk_size + j] = int.from_bytes(SwitchML(bytes(answered.res[0][1].payload)).payload.load[j * 4: (j + 1) * 4], "big")

def main():
    rank = GetRankOrExit()

    s = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
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
        CreateTestData("udp-iter-%d" % i, rank, data_out)
        AllReduce(s, rank, data_out, data_in, num_workers)
        RunIntTest("udp-iter-%d" % i, rank, data_in, True)
    Log("Done")

if __name__ == '__main__':
    main()