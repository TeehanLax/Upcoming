//
//  TLProfiling.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-23.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLProfiling.h"


// Profiling
void TLComputeDelta(uint64_t start, uint64_t end, const char *methodName) {
    uint64_t elapsed = end - start;
    uint64_t elapsedNano;
    static mach_timebase_info_data_t sTimebaseInfo;

    if (sTimebaseInfo.denom == 0) {
        (void)mach_timebase_info(&sTimebaseInfo);
    }

    elapsedNano = elapsed * sTimebaseInfo.numer / sTimebaseInfo.denom;

    NSLog(@"INFO: %s took %llu ms ", methodName, (elapsedNano / 1000000));
}
