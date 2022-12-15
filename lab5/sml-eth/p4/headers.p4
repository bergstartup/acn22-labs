#include <core.p4>
#include <v1model.p4>

typedef bit<9>  sw_port_t;   /*< Switch port */
typedef bit<48> mac_addr_t;  /*< MAC address */
#define MAX_CHUNK_SIZE 1400;
#define MAX_INT_SIZE 64;
#define WORKER_COUNT 2;

header ethernet_t {
  /* TODO: Define me */
  mac_addr_t dstAddr;
  mac_addr_t srcAddr;
  bit<16> etherType;
}

header sml_t {
  bit<32> chunck_id;
  bit<32> worker_rank;
  bit<32> chunck_size;
}

//Chunck size is 8 for  now
header chunck_t {
  int<32> val0;
  int<32> val1;
  int<32> val2;
  int<32> val3;
  int<32> val4;
  int<32> val5;
  int<32> val6;
  int<32> val7;
}


struct headers {
  ethernet_t eth;
  sml_t sml;
  chunck_t chk;
}

struct metadata { 
  /* empty */ 
  bit<32> first_last_flag; //1 if last; 0 if first 
}