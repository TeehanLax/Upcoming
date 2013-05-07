//
//  TLProfiling.h
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-23.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <mach/mach_time.h>

#define TL_PROFILING     1

void TLComputeDelta(uint64_t start, uint64_t end, const char *methodName);


#if TL_PROFILING
#define TL_PROFILE_START uint64_t start = mach_absolute_time();
#else
#define TL_PROFILE_START
#endif

#if TL_PROFILING
#define TL_PROFILE_END   uint64_t end = mach_absolute_time(); TLComputeDelta(start, end, __PRETTY_FUNCTION__);
#else
#define TL_PROFILE_END
#endif
