//
//  TLEventViewCell.m
//  Upcoming
//
//  Created by Brendan Lynch on 13-04-30.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLEventViewCell.h"
#import "UIColor+CustomizedColors.h"
#import "TLAppDelegate.h"
#import "TLRootViewController.h"

@implementation TLEventViewCell

- (void)awakeFromNib {
    self.titleLabel.clipsToBounds = NO;
    self.titleLabel.font = [[UIFont tl_mediumAppFont] fontWithSize:14];
    self.titleLabel.textColor = [UIColor colorFromRGB:0x444444];
    
    [self.backgroundImage.layer setCornerRadius:3.0f];
    [self.backgroundImage.layer setMasksToBounds:YES];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    float alpha = 0.3;
    if (self.titleLabel.text.length > 0) {
        alpha = 1;
    }
    
    TLAppDelegate *appDelegate = (TLAppDelegate *)[UIApplication sharedApplication].delegate;
    TLRootViewController *rootViewController = appDelegate.viewController;
    NSLog(@"DRAW %@", rootViewController.gradientImage);
    
    CGRect imageRect = CGRectMake(0, 0, self.backgroundImage.frame.size.width, self.backgroundImage.frame.size.height);
    UIGraphicsBeginImageContext(imageRect.size);
    [[UIColor whiteColor] set];
    UIRectFill(imageRect);
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGPoint p = self.frame.origin;
    CGSize s = self.frame.size;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([rootViewController.gradientImage CGImage], CGRectMake(p.x, p.y + self.superview.frame.origin.y, s.width, 34));
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIGraphicsBeginImageContext(self.backgroundImage.frame.size);
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) blendMode:kCGBlendModeSoftLight alpha:1];
    [aImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) blendMode:kCGBlendModeSoftLight alpha:alpha];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.backgroundImage.image = image;
}

@end