#ifndef _WORKER_COUNTER_
#define _WORKER_COUNTER_

#include "headers.p4"

control WorkerCounter(in headers hdr, inout metadata meta) {
    // Define worker counter register
    register<bit<32>>(MAX_SLOTS) Counter;
    apply {
        bit<32> current_counter;
        Counter.read(current_counter, (bit<32>)hdr.sml.slot_mod);
        meta.first_last_flag = current_counter;
        // first worker has value 0
	    if(meta.process == 1) {
            	if(current_counter == 0) {
                	Counter.write((bit<32>)hdr.sml.slot_mod, hdr.sml.worker_count - 1);
            	} else {
                	Counter.write((bit<32>)hdr.sml.slot_mod, current_counter-1);
            	}
	    } else {
            if(current_counter != 0) {
                //Still yet to recv other packets
                meta.first_last_flag = 0;
            }
	    }
    }
}

#endif /* _WORKER_COUNTER_ */
