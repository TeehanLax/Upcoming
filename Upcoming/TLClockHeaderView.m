//
//  TLClockHeaderView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLClockHeaderView.h"

@implementation TLClockHeaderView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *color = [UIColor colorWithWhite:85.0f/255.0f alpha:1.0f];
    [color set];
    
    NSInteger hours = floorf(self.timeRatio * 24);
    NSInteger minutes = (int)(floorf(self.timeRatio * 3600)) % 60;
    
    if (hours > 12) hours -= 12;
    if (hours == 0) hours += 12;
    
    // First, draw the clock.
    CGContextSaveGState(context);
    {
        
    }
    CGContextRestoreGState(context);
    
    //Next, draw the time.
    CGContextSaveGState(context);
    {
        NSString *timeString = [NSString stringWithFormat:@"%d:%02d", hours, minutes];
        UIFont *font = [UIFont systemFontOfSize:50];
        CGSize timeSize = [timeString sizeWithFont:font];
        CGFloat rightMargin = 10.0f;
        CGRect timeRect = CGRectMake(CGRectGetWidth(self.bounds) - timeSize.width - rightMargin, (CGRectGetHeight(self.bounds) - timeSize.height) / 2.0f, timeSize.width, timeSize.height);
        [timeString drawInRect:timeRect withFont:font];
    }
    CGContextRestoreGState(context);
}

-(void)setTimeRatio:(CGFloat)timeRatio
{
    _timeRatio = timeRatio;
    [self setNeedsDisplay];
}

@end
