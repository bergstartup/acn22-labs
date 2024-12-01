#ifndef _REL_CHECK_
#define _REL_CHECK_

#include "headers.p4"

control relChecker(inout headers hdr, inout metadata meta) {
    register<bit<32>>(MAX_WORKERS) rel_register;
    apply {
        bit<32> read_val;

        rel_register.read(read_val, hdr.sml.worker_rank);
            if(hdr.sml.chunk_id > read_val) {
            //Recvd next chunk : Then update counter and process the chunk
            meta.process = 1;
            rel_register.write(hdr.sml.worker_rank, hdr.sml.chunk_id);
        } else if((hdr.sml.chunk_id + 1 == read_val)||(hdr.sml.chunk_id == read_val)){
            //Recvd prev chunk or same chunk: Then send the processed data back
            meta.process = 0;
        } else {
            //Worker moved to next iteration
            meta.process = 1;
            rel_register.write(hdr.sml.worker_rank, hdr.sml.chunk_id);
        }
    }
}

#endif /* _REL_CHECK_ */