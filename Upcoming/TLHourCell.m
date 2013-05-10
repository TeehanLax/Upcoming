//
//  TLEventViewCell.m
//  Upcoming
//
//  Created by Brendan Lynch on 13-04-30.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHourCell.h"
#import "UIColor+CustomizedColors.h"
#import "TLAppDelegate.h"
#import "TLRootViewController.h"
#import "TLEventViewController.h"
#import "TLCollectionViewLayoutAttributes.h"

@interface TLHourCell ()

@property (nonatomic, weak) IBOutlet UILabel *hourLabel;

@end

@implementation TLHourCell

-(void)awakeFromNib {
    [self reset];
}

-(void)reset {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.alpha = 0;

    [self setNeedsDisplay];
}

-(void)prepareForReuse {
    [super prepareForReuse];

    [self reset];
}

-(void)applyLayoutAttributes:(TLCollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    self.contentView.alpha = layoutAttributes.contentAlpha;
}

-(void)setHour:(NSInteger)hour {
    self.hourLabel.text = [NSString stringWithFormat:@"%d", hour];
}

-(void)drawRect:(CGRect)rect {
    CGFloat alpha = 0.1;
    TLRootViewController *rootViewController = AppDelegate.viewController;

    UICollectionView *collectionView = (UICollectionView *)[self superview];
    NSIndexPath *indexPath = [collectionView indexPathForCell:self];

    CGFloat minSize = (collectionView.frame.size.height - (MAX_ROW_HEIGHT * EXPANDED_ROWS)) / (NUMBER_OF_ROWS - EXPANDED_ROWS);
    self.minY = minSize * indexPath.item;
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

    CGPoint point = self.frame.origin;
    CGSize size = self.frame.size;

    CGImageRef imageRef = CGImageCreateWithImageInRect([rootViewController.gradientImage CGImage], CGRectMake(point.x, self.minY + self.superview.frame.origin.y, size.width, self.maxY - self.minY));
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    UIGraphicsBeginImageContext(self.backgroundImage.frame.size);
    [img drawAtPoint:CGPointZero blendMode:kCGBlendModeSoftLight alpha:1];
    [aImage drawAtPoint:CGPointZero blendMode:kCGBlendModeSoftLight alpha:alpha];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImage.image = image;
}

@end
