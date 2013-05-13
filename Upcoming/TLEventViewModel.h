//
//  TLEventViewModel.h
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-06.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKEvent;

typedef enum : NSInteger {
    TLEventViewModelEventSpanFull = 0,
    TLEventViewModelEventSpanLeft,
    TLEventViewModelEventSpanRight,
    TLEventViewModelEventSpanTooManyWarning
} TLEventViewModelEventSpan;


// Wraps an event, a horizontal placement, and possibly an "extra events" count. 
@interface TLEventViewModel : NSObject

@property (nonatomic, strong) EKEvent *event;
@property (nonatomic, assign) TLEventViewModelEventSpan eventSpan;
@property (nonatomic, assign) NSInteger extraEventsCount; // Ignored unless eventSpan is TLEventViewModelEventSpanTooManyWarning

// Determine if the event overlaps with another. "Touching" events don't count as overlapping. 
-(BOOL)overlapsWith:(TLEventViewModel *)otherModel;

@property (nonatomic, readonly) NSDate *effectiveStartDate;
@property (nonatomic, readonly) NSDate *effectiveEndDate;

@end
