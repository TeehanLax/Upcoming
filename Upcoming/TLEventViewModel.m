//
//  TLEventViewModel.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-06.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLEventViewModel.h"
#import "EKEventManager.h"

@interface NSDate (Rounding)

-(NSDate *)dateByRoundingUpToNearestHalfHour;
-(NSDate *)dateByRoundingDownToNearestHalfHour;

@end

@implementation TLEventViewModel

-(BOOL)overlapsWith:(TLEventViewModel *)otherModel {
    /* There are four cases that events can overlap:
     
     self:        |-----|           |-----|      |-|      |-----|
     otherModel:      |-----|    |-----|       |-----|      |-|
     
     This scenario does not count:
     |---|
         |---|
     (ie: events "touch" but don't overlap)
     
     */
    
    NSDate *ourStartDate = [self.event.startDate dateByRoundingDownToNearestHalfHour];
    NSDate *ourEndDate = [self.event.endDate dateByRoundingUpToNearestHalfHour];
    NSDate *theirStartDate = [otherModel.event.startDate dateByRoundingDownToNearestHalfHour];
    NSDate *theirEndDate = [otherModel.event.endDate dateByRoundingUpToNearestHalfHour];
    
    BOOL overlaps =
        ([ourEndDate isLaterThanDate:theirStartDate] && [ourStartDate isEarlierThanDate:theirStartDate] && ![ourEndDate isEqualToDate:theirStartDate]) ||
        ([ourStartDate isEarlierThanDate:theirEndDate] && [ourEndDate isLaterThanDate:theirEndDate] && ![ourStartDate isEqualToDate:theirEndDate]) ||
        ([ourStartDate isLaterThanDate:theirStartDate] && [ourEndDate isEarlierThanDate:theirEndDate]) ||
        ([ourStartDate isEarlierThanDate:theirStartDate] && [ourEndDate isLaterThanDate:theirEndDate]);

    return overlaps;
}

@end


@implementation NSDate (Rounding)

-(NSDate *)dateByRoundingUpToNearestHalfHour {
    NSDateComponents *components = [[[EKEventManager sharedInstance] calendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self];
    
    NSInteger minutes = components.minute;
    
    if (minutes < 30) { minutes = 0; }
    else { minutes = 30; }
    
    components.minute = minutes;
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

-(NSDate *)dateByRoundingDownToNearestHalfHour {
    NSDateComponents *components = [[[EKEventManager sharedInstance] calendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self];
    
    NSInteger minutes = components.minute;
    NSInteger hours = components.hour;
    
    if (minutes <= 30) { minutes = 30; }
    else { minutes = 0; hours++; }
    
    components.minute = minutes;
    components.hour = hours;
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

@end