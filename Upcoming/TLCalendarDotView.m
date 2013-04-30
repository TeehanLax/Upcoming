//
//  TLCalendarDotView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-30.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLCalendarDotView.h"

@implementation TLCalendarDotView

-(void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, self.bounds);
    CGContextSetFillColor(ctx, CGColorGetComponents([self.dotColor CGColor] ?: [[UIColor clearColor] CGColor]));
    CGContextFillPath(ctx);
}

@end
