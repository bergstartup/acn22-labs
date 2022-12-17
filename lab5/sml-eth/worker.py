from lib.gen import GenInts, GenMultipleOfInRange
from lib.test import CreateTestData, RunIntTest
from lib.worker import *
from scapy.all import Packet, get_if_hwaddr
from scapy.sendrecv import *

#Custom imports
from scapy.layers.inet import *
from scapy.packet import *
from scapy.fields import *
from scapy.sendrecv import *
import sys



NUM_ITER   = 1    # TODO: Make sure your program can handle larger values
CHUNK_SIZE = 30  # TODO: Define me
SRC_MAC_ADDRESS = get_if_hwaddr("eth0")
DST_MAC_ADDRESS = 'ff:ff:ff:ff:ff:ff'
MAX_CHUNK_SIZE = 32

class SwitchML(Packet):
    name = "SwitchMLPacket"
    fields_desc = [
        BitField("num_workers", 0, 32),
        BitField("chunk_size", 0, 32)
    ]

def AllReduce(iface, rank, data, result, total_worker):
    """
    Perform in-network all-reduce over ethernet

    :param str  iface: the ethernet interface used for all-reduce
    :param int   rank: the worker's rank
    :param [int] data: the input vector for this worker
    :param [int]  res: the output vector

    This function is blocking, i.e. only returns with a result or error
    """
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
        frame = (Ether(src=SRC_MAC_ADDRESS, dst = DST_MAC_ADDRESS, type=0x8777)/SwitchML(num_workers=int(total_worker), chunk_size=chunk_size)/Raw(payload))
        frame.show()
        #Send and recv frame
        answered , unanswered = srp(x = frame, iface=iface)
        
        #take 4 bytes from the payload and create an integer array of the results
        for j in range(chunk_size):
            result[i * chunk_size + j] = int.from_bytes(SwitchML(bytes(answered.res[0][1].payload)).payload.load[j * 4: (j + 1) * 4], "big")


def main():
    iface = 'eth0'
    rank = GetRankOrExit()
    num_workers = sys.argv[2]
    Log("Started...")
    for i in range(NUM_ITER):
        num_elem = GenMultipleOfInRange(2, 2048, 2 * CHUNK_SIZE) # You may want to 'fix' num_elem for debugging
        input_data = GenInts(num_elem)
        output_data = GenInts(num_elem, 0)
        CreateTestData("eth-iter-%d" % i, rank, input_data)
        AllReduce(iface, rank, input_data, output_data, num_workers)
        RunIntTest("eth-iter-%d" % i, rank, output_data, True)
    Log("Done")

if __name__ == '__main__':
    main()
