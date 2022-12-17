
#include "headers.p4"

control WorkerCounter(inout bit<32> mvalue) {
    // Define worker counter register
    register<bit<32>>(1) Mvalue_holder;
    apply {
        bit<32> current_max_m_value;
        Counter.read(current_max_m_value, 0);
        // first worker has value 0
        if(current_max_m_value < mvalue) {
            Counter.write(0, mvalue);
        } else {
            mvalue = current_max_m_value;
        }
    }
}

