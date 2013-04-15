//
//  TLHourDecorationView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-15.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHourDecorationView.h"

@implementation TLHourDecorationView

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.backgroundColor = [UIColor orangeColor];
    
    return self;
}

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, NO);
    
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    
    CGContextBeginPath(context);
    CGFloat dashes[] = {1,1};
    
    CGContextSetLineDash(context, 0.0, dashes, 2);
    CGContextSetLineWidth(context, 0.5f);
    
    CGContextMoveToPoint(context, CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds));
    CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGContextStrokePath(context);
}


@end
