#ifndef _NEXT_STEP_
#define _NEXT_STEP_

control NextStep(inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply{
        if(meta.first_last_flag == 1) {
            standard_metadata.mcast_grp = 1;
        }
    }
}

#endif /* _NEXT_STEP_ */