#ifndef _ARP_HANDLER_
#define _ARP_HANDLER_

#include "headers.p4"

control arpResponder(inout headers hdr, inout standard_metadata_t standard_metadata) {
    action sendBack() {
        standard_metadata.egress_spec = standard_metadata.ingress_port;
    }

    action sendARPResponse(mac_addr_t switch_mac_addr) {
        //Handler ARP
        ipv4_addr_t switch_ip;
        hdr.arp.opcode = arp_opcode_t.REPLY;
        hdr.arp_ipv4.dst_hw_addr    = hdr.arp_ipv4.src_hw_addr;
        switch_ip = hdr.arp_ipv4.dst_proto_addr;
        hdr.arp_ipv4.dst_proto_addr = hdr.arp_ipv4.src_proto_addr;
        hdr.arp_ipv4.src_hw_addr    = switch_mac_addr;
        hdr.arp_ipv4.src_proto_addr = switch_ip;
        sendBack();
    }

    table arp_responder {
        key = { hdr.arp.opcode : exact;}
        actions = {
            sendARPResponse;
            NoAction;
        }
        size = MAX_WORKERS;
        default_action = NoAction();
    }

    apply {
        arp_responder.apply();
    }
}

#endif /* _ARP_HANDLER_ */