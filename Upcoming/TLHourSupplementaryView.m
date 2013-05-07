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
@property (nonatomic, assign) CGFloat hourLineProgressionRatio;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation TLHourSupplementaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.lineHeight = 1.0f;
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.font = [[UIFont tl_appFont] fontWithSize:14];
        self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        self.timeLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.timeLabel];
    }
    return self;
}

+(NSString *)kind
{
    return NSStringFromClass(self);
}

-(void)setTimeString:(NSString *)timeString
{
    _timeString = timeString;
    self.timeLabel.text = timeString;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)applyLayoutAttributes:(TLCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.hourLineProgressionRatio = layoutAttributes.hourLineProgressRatio;
    [self setNeedsDisplay];
}


static const CGFloat leftMargin = 12.0f;

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    UIFont *font = [[UIFont tl_appFont] fontWithSize:14];
    CGSize textSize = [self.timeString sizeWithFont:font];
    
    CGRect textRect = CGRectMake(leftMargin, CGRectGetMidY(self.bounds) - textSize.height / 2, textSize.width, textSize.height);
    self.timeLabel.frame = textRect;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect textRect = self.timeLabel.frame;
    
    CGContextSaveGState(context);
    {
        UIBezierPath *textRectPath = [UIBezierPath bezierPathWithRect:CGRectInset(textRect, -5, -100)];
        [textRectPath appendPath:[UIBezierPath bezierPathWithRect:self.bounds]];
        CGPathRef path = [textRectPath CGPath];
        CGContextAddPath(context, path);
        CGContextEOClip(context);
        
        CGFloat drawableHeight = CGRectGetHeight(self.bounds) - 3;
        
        CGFloat y = lrint(self.hourLineProgressionRatio * drawableHeight) + 1;
        
        CGContextSaveGState(context);
        {
            CGContextSetLineWidth(context, self.lineHeight);
            CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 0.2f);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, 0, y + 1);
            CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), y + 1);
            
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
        
        CGContextSaveGState(context);
        {
            CGContextSetLineWidth(context, self.lineHeight);
            CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, 0, y);
            CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), y);
            
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
    }
    CGContextRestoreGState(context);
}


@end
