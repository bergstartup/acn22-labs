#include <core.p4>
#include <v1model.p4>
#include "worker_counter.p4"
#include "compute.p4"
#include "headers.p4"


parser TheParser(packet_in packet,
                 out headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
  /* TODO: Implement me */
  state start {
        transition parse_ethernet;
    }

    state parse_ethernet { 
        packet.extract(hdr.ethernet);
        transition parse_sml;
    }

    state parse_sml {
        packet.extract(hdr.sml);
        transition chunck_parser;
    }

    state chunck_parser {
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

  apply {

    if (hdr.sml.isValid()) {

      //Atomic execution
      @atomic{
        //worker_counter();
        wctr.apply(hdr, meta);
        //Compute 0
        compute.apply(hdr.chk.val0, hdr, 0, hdr.chk.val0);
        //Compute 1
        compute.apply(hdr.chk.val1, hdr, 1, hdr.chk.val1);
        //Compute 2
        compute.apply(hdr.chk.val2, hdr, 2, hdr.chk.val2);
        //Compute 3
        compute.apply(hdr.chk.val3, hdr, 3, hdr.chk.val3);
        //Compute 4
        compute.apply(hdr.chk.val4, hdr, 4, hdr.chk.val4);
        //Compute 5
        compute.apply(hdr.chk.val5, hdr, 5, hdr.chk.val5);
        //Compute 6
        compute.apply(hdr.chk.val6, hdr, 6, hdr.chk.val6);
        //Compute 7
        compute.apply(hdr.chk.val7, hdr, 7, hdr.chk.val7);
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
    /* TODO: Implement me */
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