#ifndef _WORKER_COUNTER_
#define _WORKER_COUNTER_

#include "headers.p4"

control WorkerCounter(in headers hdr, inout metadata meta) {
    // Define worker counter register
    register<bit<32>>(1) Counter;
    apply {
        bit<32> current_counter;
        Counter.read(current_counter, 0);
        meta.first_last_flag = current_counter;
        // first worker has value 0
        if(current_counter == 0) {
            Counter.write(0, NUM_WORKERS - 1);
        } else {
            Counter.write(0, current_counter-1);
        }
    }
}

#endif /* _WORKER_COUNTER_ */