//
//  TLBackgroundGradientView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-25.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLBackgroundGradientView.h"

@implementation TLBackgroundGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setDrawInnserShadow:(BOOL)drawInnserShadow
{
    _drawInnserShadow = drawInnserShadow;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)dirtyRect
{
    CGRect rect = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Create a gradient from white to red
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0
    };
    NSInteger numberOfColors = 2;
    
    // Draw the linear gradient
    CGContextSaveGState(context);
    {
        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, numberOfColors);
        CGColorSpaceRelease(baseSpace), baseSpace = NULL;
        
        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGGradientRelease(gradient), gradient = NULL;
    }
    CGContextRestoreGState(context);
    
    if (_drawInnserShadow)
    {
    // Draw the inner shadow
        CGContextSaveGState(context);
        {
            CGRect bounds = [self bounds];
            
            
            // Create the "visible" path, which will be the shape that gets the inner shadow
            // In this case it's just a rect, but could be as complex as your want
            CGPathRef visiblePath = [[UIBezierPath bezierPathWithRect:rect] CGPath];
            
            // Fill this path
            UIColor *backbroundColor = [UIColor clearColor];
            [backbroundColor setFill];
            CGContextAddPath(context, visiblePath);
            CGContextFillPath(context);
            
            
            // Now create a larger rectangle, which we're going to subtract the visible path from
            // and apply a shadow
            CGMutablePathRef path = CGPathCreateMutable();
            //(when drawing the shadow for a path whichs bounding box is not known pass "CGPathGetPathBoundingBox(visiblePath)" instead of "bounds" in the following line:)
            //-42 cuould just be any offset > 0
            CGPathAddRect(path, NULL, CGRectInset(bounds, -50, -50));
            
            // Add the visible path (so that it gets subtracted for the shadow)
            CGPathAddPath(path, NULL, visiblePath);
            CGPathCloseSubpath(path);
            
            // Add the visible paths as the clipping path to the context
            CGContextAddPath(context, visiblePath);
            CGContextClip(context);
            
            
            // Now setup the shadow properties on the context
            UIColor *shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 20.0f, [shadowColor CGColor]);
            
            // Now fill the rectangle, so the shadow gets drawn
            [shadowColor setFill];
            CGContextSaveGState(context);
            CGContextAddPath(context, path);
            CGContextEOFillPath(context);
            
            // Release the paths
            CGPathRelease(path);    
            
        }
        CGContextRestoreGState(context);
    }
}

@end
