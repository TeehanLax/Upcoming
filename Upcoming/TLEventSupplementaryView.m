//
//  TLEventSupplementaryView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-07.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLEventSupplementaryView.h"
#import "TLCollectionViewLayoutAttributes.h"

@interface TLEventSupplementaryView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation TLEventSupplementaryView

-(id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }

    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backgroundImageView];
    
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [[UIFont tl_appFont] fontWithSize:14];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor tl_colorFromRGB:0x444444];
    [self.contentView addSubview:self.titleLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.font = [[UIFont tl_appFont] fontWithSize:14];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    [self.contentView addSubview:self.timeLabel];
    
    // Require this because UICollectionView will leave random supplementary views floating around, but give them a bounds of CGRect Zero. 
    self.clipsToBounds = YES;

    return self;
}

+(NSString *)kind {
    return NSStringFromClass(self);
}

-(void)applyLayoutAttributes:(TLCollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    self.contentView.alpha = layoutAttributes.contentAlpha;
        
    switch (layoutAttributes.backgroundState) {
        case TLCollectionViewLayoutAttributesBackgroundStateFuture:
            self.backgroundImageView.image = [[UIImage imageNamed:@"background-future"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
            break;
        case TLCollectionViewLayoutAttributesBackgroundStateUnhighlighted:
            self.backgroundImageView.image = [[UIImage imageNamed:@"background-unhighlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
            break;
        case TLCollectionViewLayoutAttributesBackgroundStateHighlighted:
            self.backgroundImageView.image = [[UIImage imageNamed:@"background-highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
            break;
        case TLCollectionViewLayoutAttributesBackgroundStatePast:
            self.backgroundImageView.image = [[UIImage imageNamed:@"background-past"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
            break;
        case TLCollectionViewLayoutAttributesBackgroundStateImmediate:
            self.backgroundImageView.image = [[UIImage imageNamed:@"background-immediate"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
            break;
    }
    
    CGFloat x = 0.0f;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat xOffset = 0.0f;
    switch (layoutAttributes.alignment) {
        case TLCollectionViewLayoutAttributesAlignmentFull:
            x = 5.0f;
            width = 310.0f;
            xOffset = 35.0f;
            break;
        case TLCollectionViewLayoutAttributesAlignmentLeft:
            x = 5.0f;
            width = 154.0f;
            xOffset = 35.0f;
            break;
        case TLCollectionViewLayoutAttributesAlignmentRight:
            x = 2.0;
            width = 152.0f;
            xOffset = 35.0f;
            break;
        case TLCollectionViewLayoutAttributesAlignmentNoTime:
            x = 5.0f;
            width = 154.0f;
            xOffset = 5.0f;
            break;
    }
    
    CGRect frame = CGRectMake(x, 2, width, self.frame.size.height - 4);
    [self.timeLabel sizeToFit];
    self.timeLabel.frame = CGRectMake(x + 4, 2, CGRectGetWidth(self.timeLabel.frame), CGRectGetHeight(frame));
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.timeLabel.frame) + 3, 2, CGRectGetWidth(frame) - 3 - CGRectGetMaxX(self.timeLabel.frame), frame.size.height);
    self.backgroundImageView.frame = frame;
}

-(void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    self.titleLabel.text = titleString;
}

-(void) setTimeString:(NSString *)timeString {
    _timeString = timeString;
    self.timeLabel.text = timeString;
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)prepareForReuse {
    [super prepareForReuse];
}

@end
