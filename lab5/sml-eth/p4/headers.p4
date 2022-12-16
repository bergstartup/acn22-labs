#ifndef _HEADERS_
#define _HEADERS_

typedef bit<9>  sw_port_t;   /*< Switch port */
typedef bit<48> mac_addr_t;  /*< MAC address */
typedef bit<16> ether_type_t;
typedef bit<32> val_t;
const int NUM_WORKERS = 8;

header ethernet_t {
  /* TODO: Define me */
  mac_addr_t dstAddr;
  mac_addr_t srcAddr;
  ether_type_t etherType;
}

header sml_t {
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
  sml_t sml;
  chunk_t chk;
}

struct metadata { 
  /* empty */ 
  bit<32> first_last_flag; //1 if last; 0 if first 
}

#endif /* _HEADERS_ */