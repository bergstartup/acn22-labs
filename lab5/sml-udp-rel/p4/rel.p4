#include "headers.p4"

control rel_checker(inout headers hdr, inout metadata_t metadata) {
    register<bit<32>>(MAX_WORKERS) rel_register;
    apply {
        bit<32> latest_worker_id;
        rel_register.read(latest_worker_id, hdr.sml.worker_rank);
        if(hdr.sml.chunk_id > latest_worker_id) {
            rel_register.write(hdr.sml.worker_rank, hdr.sml.chunk_id);
            metadata.process = 1;
        } else {
            metadata.process = 0;
        }
    }
}