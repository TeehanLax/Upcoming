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
        CGContextSetLineWidth(context, 4); // set the line width
        CGContextSetLineCap(context, kCGLineCapRound);

        CGFloat height = CGRectGetHeight(self.bounds);
        CGRect clockRect = CGRectMake(0, 0, height, height);
        
        // get the circle centre
        CGPoint center = CGPointMake(CGRectGetMidX(clockRect), CGRectGetMidY(clockRect));
        CGFloat radius = 15.0f;
        
        CGContextSaveGState(context);
        {
            CGFloat startAngle = -((float)M_PI / 2); // 90 degrees
            CGFloat endAngle = ((2 * (float)M_PI) + startAngle);
            CGContextAddArc(context, center.x, center.y, radius + 4, startAngle, endAngle, 0);
            CGContextStrokePath(context); // draw
        }
        CGContextRestoreGState(context);
        
        // Draw the hour hand.
        CGContextSaveGState(context);
        {
            CGFloat radius = 5.0f;
            
            CGFloat angle = (self.timeRatio * 24 / 12.0f) * M_PI * 2.0f - M_PI_2;
            
            CGFloat x = center.x + radius * cos(angle);
            CGFloat y = center.y + radius * sin(angle);
            
            CGContextMoveToPoint(context, center.x, center.y);
            CGContextAddLineToPoint(context, x, y);
            
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
        
        // Draw the minute hand.
        CGContextSaveGState(context);
        {
            CGFloat radius = 10.0f;
            
            CGFloat angle = (float)(minutes) / 60.0f * M_PI * 2.0f - M_PI_2;
            
            CGFloat x = center.x + radius * cos(angle);
            CGFloat y = center.y + radius * sin(angle);
            
            CGContextMoveToPoint(context, center.x, center.y);
            CGContextAddLineToPoint(context, x, y);
            
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
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
