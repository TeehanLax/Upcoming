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
}TLEventViewModelEventSpan;

@interface TLEventViewModel : NSObject

@property (nonatomic, strong) EKEvent *event;
@property (nonatomic, assign) TLEventViewModelEventSpan eventSpan;
@property (nonatomic, assign) NSInteger extraEventsCount;

@end
