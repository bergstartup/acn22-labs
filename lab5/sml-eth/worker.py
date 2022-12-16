from lib.gen import GenInts, GenMultipleOfInRange
from lib.test import CreateTestData, RunIntTest
from lib.worker import *
from scapy.all import Packet
from scapy.sendrecv import *

#Custom imports
from scapy.layers.inet import *
from scapy.packet import *
from scapy.fields import *
from scapy.sendrecv import *


NUM_ITER   = 1     # TODO: Make sure your program can handle larger values
CHUNK_SIZE = 8  # TODO: Define me

class SwitchML(Packet):
    name = "SwitchMLPacket"
    fields_desc = [
        BitField("chunk_index", 0, 32),
        BitField("worker_rank", 0, 32), #May change to worker rank
        BitField("chunk_size", 0, 32),
    ]

def AllReduce(iface, rank, data, result):
    """
    Perform in-network all-reduce over ethernet

    :param str  iface: the ethernet interface used for all-reduce
    :param int   rank: the worker's rank
    :param [int] data: the input vector for this worker
    :param [int]  res: the output vector

    This function is blocking, i.e. only returns with a result or error
    """
    iterations = math.ceil(len(data)/CHUNK_SIZE)
    for i in range(iterations):
        start = i*CHUNK_SIZE
        
        #SML header
        chunk_index = i
        chunk_size = CHUNK_SIZE #Change for last element
        
        #Payload
        chunk = data[start:start+CHUNK_SIZE]
        payload = bytearray() #Big endianess, beause p4 runtime uses it
        for element in chunk:
            payload.extend(element.to_bytes(length=4,byteorder="big"))

        #Create frame
        #Change the no of worker value
        frame = (Ether(type=0x0001)/SwitchML(chunk_index = chunk_index, worker_rank = rank, chunk_size = CHUNK_SIZE)/Raw(payload))
        
        #Send and recv frame
        data = srp(frame, iface=iface)
        
        Log("Frame recv : ",data)
        print(data)
        # for j in range(CHUNK_SIZE):
        #     result[i * CHUNK_SIZE + j] = int.from_bytes(SwitchML(data.res[0][1].payload).payload.load[j * 4: (j + 1) * 4], "big")

  
        

def main():
    iface = 'eth0'
    rank = GetRankOrExit()
    Log("Started...")
    for i in range(NUM_ITER):
        num_elem = GenMultipleOfInRange(2, 2048, 2 * CHUNK_SIZE) # You may want to 'fix' num_elem for debugging
        data_out = GenInts(num_elem)
        print(data_out)
        data_in = GenInts(num_elem, 0)
        CreateTestData("eth-iter-%d" % i, rank, data_out)
        AllReduce(iface, rank, data_out, data_in)
        RunIntTest("eth-iter-%d" % i, rank, data_in, True)
    Log("Done")

if __name__ == '__main__':
    main()