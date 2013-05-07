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

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TLEventSupplementaryView

-(id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }

    self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];

    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.font = [[UIFont tl_appFont] fontWithSize:14];
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor colorFromRGB:0x999999];
    [self.contentView addSubview:self.timeLabel];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [[UIFont tl_appFont] fontWithSize:14];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor colorFromRGB:0x444444];
    [self.contentView addSubview:self.titleLabel];

    return self;
}

+(NSString *)kind {
    return NSStringFromClass(self);
}

-(void)applyLayoutAttributes:(TLCollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    self.contentView.alpha = layoutAttributes.contentAlpha;
}

-(void)setTimeString:(NSString *)timeString {
    _timeString = timeString;
    self.timeLabel.text = timeString;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    self.titleLabel.text = titleString;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)layoutSubviews {
    [super layoutSubviews];

    self.timeLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

-(void)drawRect:(CGRect)rect {
}

@end
