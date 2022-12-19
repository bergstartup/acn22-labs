
#include "headers.p4"

control GetMValue(inout headers hdr, in metadata meta) {
    // Define worker counter register
    register<bit<32>>(SLOT_SIZE) Mvalue_holder;
    apply {
        bit<32> current_max_m_value;
       	Mvalue_holder.read(current_max_m_value, hdr.sml.slot_mod);
        
        //Condition to update the value if only if packet is not duplicate
        //If got higher mvalue or first worker write
        if((meta.process == 1)&&((current_max_m_value < hdr.sml.m_val)||(meta.first_last_flag == 0))) {
            Mvalue_holder.write(hdr.sml.m_val, mvalue);
        } else {
            hdr.sml.m_val = current_max_m_value;
        }
    }
}

