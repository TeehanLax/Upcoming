//
//  TLEventViewModel.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-06.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLEventViewModel.h"

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
    BOOL overlaps =
        ([self.event.endDate isLaterThanDate:otherModel.event.startDate] && [self.event.startDate isEarlierThanDate:otherModel.event.startDate] && ![self.event.endDate isEqualToDate:otherModel.event.startDate]) ||
        ([self.event.startDate isEarlierThanDate:otherModel.event.endDate] && [self.event.endDate isLaterThanDate:otherModel.event.endDate] && ![self.event.startDate isEqualToDate:otherModel.event.endDate]) ||
        ([self.event.startDate isLaterThanDate:otherModel.event.startDate] && [self.event.endDate isEarlierThanDate:otherModel.event.endDate]) ||
        ([self.event.startDate isEarlierThanDate:otherModel.event.startDate] && [self.event.endDate isLaterThanDate:otherModel.event.endDate]);

    return overlaps;
}

@end
