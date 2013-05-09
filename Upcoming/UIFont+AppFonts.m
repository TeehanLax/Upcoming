//
//  UIFont+AppFonts.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-26.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "UIFont+AppFonts.h"

@implementation UIFont (AppFonts)

+(UIFont *)tl_appFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:[UIFont systemFontSize]];
}

+(UIFont *)tl_mediumAppFont {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:[UIFont systemFontSize]];
}

+(UIFont  *)tl_boldAppFont {
    return [UIFont fontWithName:@"AvenirNext-Bold" size:[UIFont systemFontSize]];
}

+(UIFont  *)tl_demiBoldAppFont {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:[UIFont systemFontSize]];
}

@end
