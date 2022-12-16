#ifndef _HEADERS_
#define _HEADERS_

typedef bit<9>  sw_port_t;   /*< Switch port */
typedef bit<48> mac_addr_t;  /*< MAC address */
typedef bit<16> ether_type_t;
typedef bit<32> val_t;
// #define MAX_CHUNK_SIZE 1400;
// #define MAX_INT_SIZE 64;
// #define WORKER_COUNT 2;

header ethernet_t {
  /* TODO: Define me */
  mac_addr_t dstAddr;
  mac_addr_t srcAddr;
  ether_type_t etherType;
}

header sml_t {
  bit<32> chunk_id;
  bit<32> worker_rank;
  bit<32> chunk_size;
}

//chunk size is 8 for  now
header chunk_t {
  val_t val0;
  val_t val1;
  val_t val2;
  val_t val3;
  val_t val4;
  val_t val5;
  val_t val6;
  val_t val7;
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