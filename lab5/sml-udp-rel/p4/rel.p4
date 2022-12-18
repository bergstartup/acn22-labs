#include "headers.p4"

control relChecker(inout headers hdr, inout metadata meta) {
    register<bit<32>>(MAX_WORKERS) rel_register;
    apply {
        bit<32> latest_worker_id;
        rel_register.read(latest_worker_id, hdr.sml.worker_rank);
        if(hdr.sml.chunk_id > latest_worker_id) {
            if(hdr.sml.chunk_id == hdr.sml.total_chunks) {
                 rel_register.write(hdr.sml.worker_rank, 0);
            } else {
	         rel_register.write(hdr.sml.worker_rank, hdr.sml.chunk_id);
            }
	    meta.process = 1;
        } else {
            meta.process = 0;
        }
    }
}
