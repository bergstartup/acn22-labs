#include "headers.p4"

control compute(in int<32> inval, in headers hdr, in bit<32> index, out int<32> outval) {

    //Define register
    register<bit<32>>(1) CHK;
    apply {
        //Check if this chunck index is valid
        if(index < hdr.sml.chunck_size) {
            //Check meta.first_last_flag
            if(meta.first_last_flag == 0) {
                CHK.write(0, inval);
                outval = inval;
            } else {
                int<32> current_value;
                CHK.read(current_value, 0);
                current_value = current_value + inval;
                outval = current_value;
                CHK.write(0, current_value);
            }
        }
    }
}