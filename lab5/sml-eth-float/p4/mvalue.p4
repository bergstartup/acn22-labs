
#include "headers.p4"

control GetMValue(inout bit<32> mvalue, in metadata meta) {
    // Define worker counter register
    register<bit<32>>(1) Mvalue_holder;
    apply {
        bit<32> current_max_m_value;
       	Mvalue_holder.read(current_max_m_value, 0);
        // first worker has value 0
        if((current_max_m_value < mvalue)||(meta.first_last_flag == 0)) {
            Mvalue_holder.write(0, mvalue);
        } else {
            mvalue = current_max_m_value;
        }
    }
}

