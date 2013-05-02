//
//  TLHourSupplementaryView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-02.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHourSupplementaryView.h"
#import "UIFont+AppFonts.h"

@implementation TLHourSupplementaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

+(NSString *)kind
{
    return @"HourSupplementaryViewIdentifier";
}

-(void)setTimeString:(NSString *)timeString
{
    _timeString = timeString;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat rightMargin = 7.0f;
    UIFont *font = [[UIFont tl_appFont] fontWithSize:10];
    CGFloat textWidth = [self.timeString sizeWithFont:font].width;
    
    CGContextSaveGState(context);
    {
        
        CGContextSetLineWidth(context, 1);
        CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 0.5f);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, (int)CGRectGetMidY(self.bounds));
        CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), (int)CGRectGetMidY(self.bounds));
        
        
        CGContextStrokePath(context);
    }
    
    [[UIColor colorWithWhite:1.0f alpha:0.7f] set];
    CGRect textRect = CGRectMake(CGRectGetWidth(self.bounds) - rightMargin - textWidth, 0, textWidth, CGRectGetHeight(self.bounds));
    [self.timeString drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
//    [self.timeString drawAtPoint:CGPointZero forWidth:200 withFont:[UIFont tl_appFont] fontSize:10 lineBreakMode:NSLineBreakByClipping baselineAdjustment:UIBaselineAdjustmentNone];
}


@end
