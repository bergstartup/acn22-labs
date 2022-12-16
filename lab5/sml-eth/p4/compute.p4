#ifndef _COMPUTE_
#define _COMPUTE_

#include "headers.p4"

control Compute(in val_t inval, in headers hdr, in bit<32> index, out val_t outval, inout metadata meta) {

    //Define register to store the sum
    register<bit<32>>(32) CHK;
    apply {
        outval = 0;
        // Check if this chunk index is within the chunk size
        // This is to handle varying chunk sizes upto 32
        if(index < hdr.sml.chunk_size) {
            // Check if it is first packet
            if(meta.first_last_flag == 0) {
                CHK.write(index, inval);
                outval = inval;
            } else {
                val_t current_value = 0;
                CHK.read(current_value, index);
                current_value = current_value + inval;
                outval = current_value;
                CHK.write(index, current_value);
            }
        }
    }
}

#endif /* _COMPUTE_ */