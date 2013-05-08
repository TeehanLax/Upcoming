//
//  UIColor+CustomizedColors.h
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-23.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CustomizedColors)

+(UIColor *)tl_interpolatedColorWithRatio:(CGFloat)ratio color:(UIColor *)color color:(UIColor *)otherColor;

+(UIColor *)tl_colorFromRGB:(int)rgbValue;

@end
