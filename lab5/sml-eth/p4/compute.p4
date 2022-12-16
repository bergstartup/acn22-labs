#ifndef _COMPUTE_
#define _COMPUTE_

#include "headers.p4"

control Compute(in val_t inval, in headers hdr, in bit<32> index, out val_t outval, inout metadata meta) {

    //Define register
    register<bit<32>>(1) CHK;
    apply {
        outval = 0;
        //Check if this chunk index is valid
        if(index < hdr.sml.chunk_size) {
            //Check meta.first_last_flag
            if(meta.first_last_flag == 0) {
                CHK.write(0, inval);
                outval = inval;
            } else {
                val_t current_value = 0;
                CHK.read(current_value, 0);
                current_value = current_value + inval;
                outval = current_value;
                CHK.write(0, current_value);
            }
        }
    }
}

#endif /* _COMPUTE_ */