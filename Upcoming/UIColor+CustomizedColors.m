//
//  UIColor+CustomizedColors.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-23.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "UIColor+CustomizedColors.h"

// Does a linear interpolation between a and b, given float amount between 0 and 1
static CGFloat lerp (CGFloat amount, CGFloat a, CGFloat b)
{
    return a + amount * (b - a);
}

@implementation UIColor (CustomizedColors)


+(UIColor *)interpolatedColorWithRatio:(CGFloat)ratio color:(UIColor *)color color:(UIColor *)otherColor
{
    CGFloat red1, red2, green1, green2, blue1, blue2, alpha1, alpha2;
    
    [color getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    [otherColor getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    
    return [UIColor colorWithRed:lerp(ratio, red1, red2) green:lerp(ratio, green1, green2) blue:lerp(ratio, blue1, blue2) alpha:lerp(ratio, alpha1, alpha2)];
}

@end
