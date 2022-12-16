#include <core.p4>
#include <v1model.p4>
#include "headers.p4"
#include "worker_counter.p4"
#include "compute.p4"
#include "next_step.p4"

parser TheParser(packet_in packet,
                 out headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet { 
        packet.extract(hdr.eth);
        transition select(hdr.eth.etherType) {
          0x0001 : parse_sml;
          default : accept;
        }
    }

    state parse_sml {
        packet.extract(hdr.sml);
        transition chunk_parser;
    }

    state chunk_parser {
      packet.extract(hdr.chk);
      transition accept;
    }
}


control TheChecksumVerification(inout headers hdr, inout metadata meta) {
  apply {
    /* TODO: Implement me (if needed) */
  }
}


control TheIngress(inout headers hdr,
                   inout metadata meta,
                   inout standard_metadata_t standard_metadata) {
                    

  WorkerCounter() wctr;

  Compute() c1;
  Compute() c2;
  Compute() c3;
  Compute() c4;
  Compute() c5;
  Compute() c6;
  Compute() c7;
  Compute() c8;

  NextStep() nxt;


  apply {
    if (hdr.sml.isValid() && hdr.eth.etherType == 0x0001) {
      //Atomic execution
      @atomic{
        //worker_counter();
        wctr.apply(hdr, meta);
        //Compute 0
        c1.apply(hdr.chk.val0, hdr, 0, hdr.chk.val0, meta);
        //Compute 1
        c2.apply(hdr.chk.val1, hdr, 1, hdr.chk.val1, meta);
        //Compute 2
        c3.apply(hdr.chk.val2, hdr, 2, hdr.chk.val2, meta);
        //Compute 3
        c4.apply(hdr.chk.val3, hdr, 3, hdr.chk.val3, meta);
        //Compute 4
        c5.apply(hdr.chk.val4, hdr, 4, hdr.chk.val4, meta);
        //Compute 5
        c6.apply(hdr.chk.val5, hdr, 5, hdr.chk.val5, meta);
        //Compute 6
        c7.apply(hdr.chk.val6, hdr, 6, hdr.chk.val6, meta);
        //Compute 7
        c8.apply(hdr.chk.val7, hdr, 7, hdr.chk.val7, meta);
        // Decide what to do with this packet
        nxt.apply(meta, standard_metadata);
      }
      //End of atomic execution
    }
    //End of if
  }
  //End of apply
}

control TheEgress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
  apply {
    /* TODO: Implement me (if needed) */
  }
}

control TheChecksumComputation(inout headers  hdr, inout metadata meta) {
  apply {
    /* TODO: Implement me (if needed) */
  }
}

control TheDeparser(packet_out packet, in headers hdr) {
  apply {
    packet.emit(hdr.eth);
    packet.emit(hdr.sml);
    packet.emit(hdr.chk);
  }
}

V1Switch(
  TheParser(),
  TheChecksumVerification(),
  TheIngress(),
  TheEgress(),
  TheChecksumComputation(),
  TheDeparser()
) main;