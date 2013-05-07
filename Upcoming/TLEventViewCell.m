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
#import "TLEventViewController.h"

@implementation TLEventViewCell

- (void)awakeFromNib {
    self.titleLabel.clipsToBounds = NO;
    self.titleLabel.font = [[UIFont tl_mediumAppFont] fontWithSize:14];
    self.titleLabel.textColor = [UIColor colorFromRGB:0x444444];
    
    [self.background.layer setCornerRadius:3.0f];
    [self.background.layer setMasksToBounds:YES];
    
    [self reset];
}

-(void)reset{
    
    self.titleLabel.text = @"";
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.alpha = 0;
    
    [self setNeedsDisplay];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self reset];
    
}

- (void)drawRect:(CGRect)rect {
    float alpha = 0.3;
    if (self.titleLabel.text.length > 0) {
        alpha = 1;
    }
    
    TLAppDelegate *appDelegate = (TLAppDelegate *)[UIApplication sharedApplication].delegate;
    TLRootViewController *rootViewController = appDelegate.viewController;
    
    UICollectionView *collectionView = (UICollectionView *)[self superview];
    NSIndexPath *indexPath = [collectionView indexPathForCell:self];
    
    CGFloat minSize = (collectionView.frame.size.height - (MAX_ROW_HEIGHT * EXPANDED_ROWS)) / 20;
    self.minY = minSize * indexPath.row;
    self.maxY = (collectionView.frame.size.height - (minSize * 24)) + self.minY;
    
    CGRect backgroundImageFrame = self.backgroundImage.frame;
    backgroundImageFrame.size.height = self.maxY - self.minY;
    self.backgroundImage.frame = backgroundImageFrame;
    
    CGRect imageRect = CGRectMake(0, 0, self.backgroundImage.frame.size.width, self.backgroundImage.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(imageRect.size, YES, 0);
    [[UIColor whiteColor] set];
    UIRectFill(imageRect);
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGPoint p = self.frame.origin;
    CGSize s = self.frame.size;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([rootViewController.gradientImage CGImage], CGRectMake(p.x, self.minY + self.superview.frame.origin.y, s.width, self.maxY - self.minY));
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIGraphicsBeginImageContext(self.backgroundImage.frame.size);
    [img drawAtPoint:CGPointZero blendMode:kCGBlendModeSoftLight alpha:1];
    [aImage drawAtPoint:CGPointZero blendMode:kCGBlendModeSoftLight alpha:alpha];
    if (self.titleLabel.text.length > 0) {
        // draw the shape again per design
        [aImage drawAtPoint:CGPointZero blendMode:kCGBlendModeSoftLight alpha:alpha];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImage.image = image;
}

@end
