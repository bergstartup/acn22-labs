#ifndef _NEXT_STEP_
#define _NEXT_STEP_

control NextStep(inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply{
        // the last worker has the value 1 in the flag
        // the last worker has to set up a multicast or broadcast the packet to all the other workers
        if(meta.first_last_flag == 1) {
            standard_metadata.mcast_grp = 1;
        } else {
	    mark_to_drop(standard_metadata);
	}
    }
}

#endif /* _NEXT_STEP_ */
