//
//  TLEventViewCell.m
//  Upcoming
//
//  Created by Brendan Lynch on 13-04-30.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLEventViewCell.h"
#import "UIColor+CustomizedColors.h"

@implementation TLEventViewCell

- (void)awakeFromNib {
    self.title.clipsToBounds = NO;
    self.title.font = [[UIFont tl_mediumAppFont] fontWithSize:14];
    self.title.textColor = [UIColor colorFromRGB:0x444444];
}

@end