#include <core.p4>
#include <v1model.p4>
#include "headers.p4"
#include "worker_counter.p4"
#include "compute.p4"
#include "next_step.p4"
#include "arpHandler.p4"
#include "udpReplier.p4"
#include "rel.p4"

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
          ETHERTYPE_ARP: parse_arp;
          ETHERTYPE_IPV4: parse_ipv4;
          default : accept;
        }
    }

    //Parse ARP
    state parse_arp {
        packet.extract(hdr.arp);
        transition select(hdr.arp.hw_type, hdr.arp.proto_type) {
            (0x0001, ETHERTYPE_IPV4) : parse_arp_ipv4;
            default: accept;
        }
    }

    state parse_arp_ipv4 {
        packet.extract(hdr.arp_ipv4);
        transition accept;
    }

    //Parse IP
    state parse_ipv4 {
      packet.extract(hdr.ipv4);
      transition select(hdr.ipv4.protocol) {
        ip_protocol_t.UDP  : parse_udp;
        default : accept;
      }
    }

    state parse_udp {
      packet.extract(hdr.udp);
      //Parse sml if dst port is 8000
      transition select(hdr.udp.dstPort) {
        8000: parse_sml;
        // on default streaming forward
        default: accept;
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
   apply{
  }
}


control TheIngress(inout headers hdr,
                   inout metadata meta,
                   inout standard_metadata_t standard_metadata) {
  // declare the controls

  arpResponder() arp;

  relChecker() rel;
  WorkerCounter() wctr;

  Compute() c0;
  Compute() c1;
  Compute() c2;
  Compute() c3;
  Compute() c4;
  Compute() c5;
  Compute() c6;
  Compute() c7;
  Compute() c8;
  Compute() c9;
  Compute() c10;
  Compute() c11;
  Compute() c12;
  Compute() c13;
  Compute() c14;
  Compute() c15;
  Compute() c16;
  Compute() c17;
  Compute() c18;
  Compute() c19;
  Compute() c20;
  Compute() c21;
  Compute() c22;
  Compute() c23;
  Compute() c24;
  Compute() c25;
  Compute() c26;
  Compute() c27;
  Compute() c28;
  Compute() c29;
  Compute() c30;
  Compute() c31;

  NextStep() nxt;

  // basic forwarding rules
  action drop() {
      mark_to_drop(standard_metadata);
  }

  action ipv4_forward(mac_addr_t dstAddr, egressSpec_t port) {
      standard_metadata.egress_spec = port;
      hdr.eth.srcAddr = hdr.eth.dstAddr;
      hdr.eth.dstAddr = dstAddr;
      hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
  }

  table ipv4_lpm {
      key = {
          hdr.ipv4.dstAddr: lpm;
      }
      actions = {
          ipv4_forward;
          drop;
          NoAction;
      }
      size = 1024;
      default_action = NoAction();
  }

  // computational steps
  apply {
    //Handler ARP
    if (hdr.arp.isValid()) {
      arp.apply(hdr, standard_metadata);
    }

    //First check for Switch ML
    if (hdr.sml.isValid()) {
      //Atomic execution
      @atomic{
        //Check if duplicate
        rel.apply(hdr, meta);
        //worker_counter();
        wctr.apply(hdr, meta);
        //Compute 0
        c0.apply(hdr.chk.val0, hdr, 0, hdr.chk.val0, meta);
        //Compute 1
        c1.apply(hdr.chk.val1, hdr, 1, hdr.chk.val1, meta);
        //Compute 2
        c2.apply(hdr.chk.val2, hdr, 2, hdr.chk.val2, meta);
        //Compute 3
        c3.apply(hdr.chk.val3, hdr, 3, hdr.chk.val3, meta);
        //Compute 4
        c4.apply(hdr.chk.val4, hdr, 4, hdr.chk.val4, meta);
        //Compute 5
        c5.apply(hdr.chk.val5, hdr, 5, hdr.chk.val5, meta);
        //Compute 6
        c6.apply(hdr.chk.val6, hdr, 6, hdr.chk.val6, meta);
        //Compute 7
        c7.apply(hdr.chk.val7, hdr, 7, hdr.chk.val7, meta);
        //Compute 8
        c8.apply(hdr.chk.val8, hdr, 8, hdr.chk.val8, meta);
        //Compute 9
        c9.apply(hdr.chk.val9, hdr, 9, hdr.chk.val9, meta);
        //Compute 10
        c10.apply(hdr.chk.val10, hdr, 10, hdr.chk.val10, meta);
        //Compute 11
        c11.apply(hdr.chk.val11, hdr, 11, hdr.chk.val11, meta);
        //Compute 12
        c12.apply(hdr.chk.val12, hdr, 12, hdr.chk.val12, meta);
        //Compute 13
        c13.apply(hdr.chk.val13, hdr, 13, hdr.chk.val13, meta);
        //Compute 14
        c14.apply(hdr.chk.val14, hdr, 14, hdr.chk.val14, meta);
        //Compute 15
        c15.apply(hdr.chk.val15, hdr, 15, hdr.chk.val15, meta);
        //Compute 16
        c16.apply(hdr.chk.val16, hdr, 16, hdr.chk.val16, meta);
        //Compute 17
        c17.apply(hdr.chk.val17, hdr, 17, hdr.chk.val17, meta);
        //Compute 18
        c18.apply(hdr.chk.val18, hdr, 18, hdr.chk.val18, meta);
        //Compute 19
        c19.apply(hdr.chk.val19, hdr, 19, hdr.chk.val19, meta);
        //Compute 20
        c20.apply(hdr.chk.val20, hdr, 20, hdr.chk.val20, meta);
        //Compute 21
        c21.apply(hdr.chk.val21, hdr, 21, hdr.chk.val21, meta);
        //Compute 22
        c22.apply(hdr.chk.val22, hdr, 22, hdr.chk.val22, meta);
        //Compute 23
        c23.apply(hdr.chk.val23, hdr, 23, hdr.chk.val23, meta);
        //Compute 24
        c24.apply(hdr.chk.val24, hdr, 24, hdr.chk.val24, meta);
        //Compute 25
        c25.apply(hdr.chk.val25, hdr, 25, hdr.chk.val25, meta);
        //Compute 26
        c26.apply(hdr.chk.val26, hdr, 26, hdr.chk.val26, meta);
        //Compute 27
        c27.apply(hdr.chk.val27, hdr, 27, hdr.chk.val27, meta);
        //Compute 28
        c28.apply(hdr.chk.val28, hdr, 28, hdr.chk.val28, meta);
        //Compute 29
        c29.apply(hdr.chk.val29, hdr, 29, hdr.chk.val29, meta);
        //Compute 30
        c30.apply(hdr.chk.val30, hdr, 30, hdr.chk.val30, meta);
        //Compute 31
        c31.apply(hdr.chk.val31, hdr, 31, hdr.chk.val31, meta);
        // Decide what to do with this packet
        nxt.apply(meta, standard_metadata);
      }
      //End of atomic execution
    }
    // else check for normal ipv4 routing
    else if (hdr.ipv4.isValid()) {
      ipv4_lpm.apply();
    }
  }
  //End of apply
}

control TheEgress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
  udp_replier() ur;
  apply {
    // i only care about sml for now
    if(hdr.sml.isValid()) {
      ur.apply(hdr, standard_metadata);
    }
  }
}

control TheChecksumComputation(inout headers  hdr, inout metadata meta) {
  apply {
   update_checksum(
      hdr.ipv4.isValid(),
      {
        hdr.ipv4.version,
        hdr.ipv4.ihl,
        hdr.ipv4.diffserv,
        hdr.ipv4.totalLen,
        hdr.ipv4.identification,
        hdr.ipv4.flags,
        hdr.ipv4.fragOffset,
        hdr.ipv4.ttl,
        hdr.ipv4.protocol,
        hdr.ipv4.srcAddr,
        hdr.ipv4.dstAddr
      },
      hdr.ipv4.hdrChecksum,
      HashAlgorithm.csum16
    );

    // if udp is present update checksum
    update_checksum_with_payload(
      hdr.udp.isValid(),
      {
          hdr.ipv4.srcAddr,
          hdr.ipv4.dstAddr,
          (bit<8>)0x00,
          hdr.ipv4.protocol,
          hdr.udp.hdrLen,
          hdr.udp.srcPort,
          hdr.udp.dstPort,
          hdr.udp.hdrLen
      },
      hdr.udp.checksum,
      HashAlgorithm.csum16
    );

    update_checksum(
      hdr.sml.isValid(),
      {
        hdr.ipv4.srcAddr,
        hdr.ipv4.dstAddr,
        (bit<8>)0x00,
        hdr.ipv4.protocol,
        hdr.udp.hdrLen,
        hdr.udp.srcPort,
        hdr.udp.dstPort,
        hdr.udp.hdrLen,
        hdr.sml,
        hdr.chk
      },
      hdr.udp.checksum,
      HashAlgorithm.csum16
    );
  }
}

control TheDeparser(packet_out packet, in headers hdr) {
  apply {
    packet.emit(hdr.eth);
    packet.emit(hdr.arp);
    packet.emit(hdr.arp_ipv4);
    packet.emit(hdr.ipv4);
    packet.emit(hdr.udp);
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
