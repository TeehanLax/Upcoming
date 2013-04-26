//
//  TLBackgroundGradientView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-25.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLBackgroundGradientView.h"

@interface TLBackgroundGradientView ()

@property (nonatomic, strong) UIImageView *innerShadowView;

@end

@implementation TLBackgroundGradientView

static NSInteger numberOfColors = 5;

// Create a gradient. Colours at the beginning of the array are at the top of the view.
static CGFloat colors [] = {
    42.0f/255.0f, 64.0f/255.0f, 99.0f/255.0f, 1.0,
    79.0f/255.0f, 122.0f/255.0f, 165.0f/255.0f, 1.0,
    163.0f/255.0f, 219.0f/255.0f, 225.0f/255.0f, 1.0,
    217.0f/255.0f, 236.0f/255.0f, 203.0f/255.0f, 1.0,
    201.0f/255.0f, 142.0f/255.0f, 131.0f/255.0f, 1.0
};

static CGFloat locations [] = {
    0.0f, 0.34f, 0.64f, 0.76f, 0.95f
};


- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.innerShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inner-shadow"]];
    self.innerShadowView.frame = self.bounds;
    self.innerShadowView.contentMode = UIViewContentModeScaleToFill;
    self.innerShadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.innerShadowView];
        
    return self;
}

- (void)drawRect:(CGRect)dirtyRect
{
    CGRect rect = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    // Draw the linear gradient
    CGContextSaveGState(context);
    {
        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, locations, numberOfColors);
        CGColorSpaceRelease(baseSpace), baseSpace = NULL;
        
        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGGradientRelease(gradient), gradient = NULL;
        CGColorSpaceRelease(baseSpace);
    }
    CGContextRestoreGState(context);
}

@end

