//
//  TLImageView.m
//  Upcoming
//
//  Created by Brendan Lynch on 13-05-01.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLImageView.h"

@implementation TLImageView

- (void)drawRect:(CGRect)rect
{
    UIImage *bgImage = [[UIImage imageNamed:@"event-row-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
    [bgImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) blendMode:kCGBlendModeSoftLight alpha:0.4];
    [super drawRect:rect];
}

@end