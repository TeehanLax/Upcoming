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
            xOffset = 5.0f;
            break;
        case TLCollectionViewLayoutAttributesAlignmentLeft:
            x = 5.0f;
            width = 154.0f;
            xOffset = 5.0f;
            break;
        case TLCollectionViewLayoutAttributesAlignmentRight:
            x = 2.0;
            width = 152.0f;
            xOffset = 5.0f;
            break;
    }
    
    CGRect frame = CGRectMake(x, 2, width, self.frame.size.height - 4);
    self.titleLabel.frame = CGRectInset(frame, xOffset, 0);
    self.backgroundImageView.frame = frame;
}

-(void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    self.titleLabel.text = titleString;
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)prepareForReuse {
    [super prepareForReuse];
}

@end
