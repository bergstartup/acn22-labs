#ifndef _COMPUTE_
#define _COMPUTE_

#include "headers.p4"

control Compute(in val_t inval, in headers hdr, in bit<32> index, out val_t outval, inout metadata meta) {

    //Define register to store the sum
    register<bit<32>>(32) CHK0;
    register<bit<32>>(32) CHK1;
    apply {
        outval = 0;
        if(index < hdr.sml.chunk_size) {
            
            if (meta.process == 0) {
                //Duplicate packet so read-only
                if(hdr.sml.slot_mod == 0) {
                    CHK0.read(outval, index);
                } else {
                    CHK1.read(outval, index);
                }

            } 
            
            else {
                // Check if this chunk index is within the chunk size
                // This is to handle varying chunk sizes upto 32
                
                    // Check if it is first packet
                    if(meta.first_last_flag == 0) {
                        if(hdr.sml.slot_mod == 0) {
                            CHK0.write(index, inval);
                        } else {
                            CHK1.write(index, inval);
                        }
                        outval = inval;
                    } 
                    
                    else {
                        val_t current_value = 0;
                        if(hdr.sml.slot_mod == 0) {
                            CHK0.read(current_value, index);
                        } else {
                            CHK1.read(current_value, index);
                        }
                        current_value = current_value + inval;
                        outval = current_value;
                        if(hdr.sml.slot_mod == 0) {
                            CHK0.write(index, current_value);
                        } else {
                            CHK1.write(index, current_value);
                        }
                    }
                }
            }
    }
}

#endif /* _COMPUTE_ */
