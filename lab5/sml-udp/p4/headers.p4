#ifndef _HEADERS_
#define _HEADERS_

typedef bit<9>  sw_port_t;   /*< Switch port */
typedef bit<48> mac_addr_t;  /*< MAC address */
typedef bit<16> ether_type_t;
typedef bit<32> val_t;
typedef bit<16> port_t;
typedef bit<16> ether_type_t;

const ether_type_t ETHERTYPE_IPV4   = 16w0x0800;
const ether_type_t ETHERTYPE_ARP    = 16w0x0806;


enum bit<8> ip_protocol_t {
    UDP  = 17
}

enum bit<16> arp_opcode_t {
    REQUEST = 1,
    REPLY   = 2
}


header ethernet_t {
  mac_addr_t dstAddr;
  mac_addr_t srcAddr;
  ether_type_t etherType;
}


header arp_h {
    bit<16>       hw_type;
    ether_type_t  proto_type;
    bit<8>        hw_addr_len;
    bit<8>        proto_addr_len;
    arp_opcode_t  opcode;
}

header arp_ipv4_h {
    mac_addr_t   src_hw_addr;
    ipv4_addr_t  src_proto_addr;
    mac_addr_t   dst_hw_addr;
    ipv4_addr_t  dst_proto_addr;
}

header ipv4_t {
    bit<4> version;
    bit<4> ihl;
    bit<8> diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3> flags;
    bit<13> fragOffset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header udp_t {
    port_t srcPort;
    port_t dstPort;
    bit<16> hdrLen;
    bit<16> checksum;
}

header sml_t {
  bit<32> worker_count;
  bit<32> chunk_size;
}

header chunk_t {
  val_t val0;
  val_t val1;
  val_t val2;
  val_t val3;
  val_t val4;
  val_t val5;
  val_t val6;
  val_t val7;
  val_t val8;
  val_t val9;
  val_t val10;
  val_t val11;
  val_t val12;
  val_t val13;
  val_t val14;
  val_t val15;
  val_t val16;
  val_t val17;
  val_t val18;
  val_t val19;
  val_t val20;
  val_t val21;
  val_t val22;
  val_t val23;
  val_t val24;
  val_t val25;
  val_t val26;
  val_t val27;
  val_t val28;
  val_t val29;
  val_t val30;
  val_t val31;
}

struct headers {
  ethernet_t eth;
  arp_h arp;
  arp_ipv4_h arp_ipv4;
  ipv4_t ipv4;
  udp_t udp;
  sml_t sml;
  chunk_t chk;
}

struct metadata { 
  bit<32> first_last_flag; //1 if last; 0 if first 
}

#endif /* _HEADERS_ */
