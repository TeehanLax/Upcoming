//
//  TLTaskListCell.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-15.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLTaskListCell.h"

@interface TLTaskListCell ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation TLTaskListCell

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.8f alpha:1.0f];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.minimumScaleFactor = 0.1f;
    self.textLabel.textColor = [UIColor whiteColor];
//    [self.contentView addSubview:self.textLabel];
    
    self.textLabel.text = @"Some appointment";
    
    return self;
}

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.frame = CGRectIntegral(layoutAttributes.frame);
    
    [self setNeedsLayout];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = self.bounds;
}

@end
