#ifndef _UDP_REPLIER_
#define _UDP_REPLIER_

#include "headers.p4"

control udp_replier(inout headers hdr, inout standard_metadata_t standard_metadata) {
    action sendUDPReply(mac_addr_t switch_mac_addr, mac_addr_t node_mac, ipv4_addr_t node_ip) {
        ipv4_addr_t switch_ip;
        switch_ip = hdr.ipv4.dstAddr;
        hdr.ipv4.srcAddr = switch_ip;
        hdr.ipv4.dstAddr = node_ip;
        hdr.eth.srcAddr = switch_mac_addr;
        hdr.eth.dstAddr = node_mac;
    }

    table udp_replier_table {
        key = { standard_metadata.egress_port : exact;}
        actions = {
            sendUDPReply;
            NoAction;
        }
        size = MAX_WORKERS; //MAX worker count
        default_action = NoAction();
    }
    apply {
        udp_replier_table.apply();
    }
}

#endif /* _UDP_REPLIER_ */