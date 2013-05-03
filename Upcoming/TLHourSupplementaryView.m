//
//  TLHourSupplementaryView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-02.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHourSupplementaryView.h"
#import "UIFont+AppFonts.h"
#import "TLCollectionViewLayoutAttributes.h"
#import <ViewUtils.h>

@interface TLHourSupplementaryView ()

@property (nonatomic, assign) CGFloat lineHeight;

@end

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

-(void)applyLayoutAttributes:(TLCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.lineHeight = layoutAttributes.hourLineHeight;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat rightMargin = 12.0f;
    UIFont *font = [[UIFont tl_appFont] fontWithSize:14];
    CGSize textSize = [self.timeString sizeWithFont:font];
    CGRect textRect = CGRectMake(CGRectGetWidth(self.bounds) - rightMargin - textSize.width, CGRectGetMidY(self.bounds) - textSize.height / 2, textSize.width, textSize.height);
    
    CGContextSaveGState(context);
    {
        UIBezierPath *textRectPath = [UIBezierPath bezierPathWithRect:CGRectInset(textRect, -5, 0)];
        [textRectPath appendPath:[UIBezierPath bezierPathWithRect:self.bounds]];
        CGPathRef path = [textRectPath CGPath];
        CGContextAddPath(context, path);
        CGContextEOClip(context);
        
        CGContextSaveGState(context);
        {
            CGContextSetLineWidth(context, self.lineHeight);
            CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 0.2f);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, 0, (int)CGRectGetMidY(self.bounds) + 1);
            CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), (int)CGRectGetMidY(self.bounds) + 1);
            
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
        
        CGContextSaveGState(context);
        {
            CGContextSetLineWidth(context, self.lineHeight);
            CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, 0, (int)CGRectGetMidY(self.bounds));
            CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), (int)CGRectGetMidY(self.bounds));
            
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
    }
    CGContextRestoreGState(context);
    
    
    [[UIColor colorWithWhite:0.0f alpha:0.2f] set];
    [self.timeString drawInRect:CGRectOffset(textRect, 0, 1) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    [[UIColor colorWithWhite:1.0f alpha:1.0f] set];
    [self.timeString drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}


@end
