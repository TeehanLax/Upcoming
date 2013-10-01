//
//  TLCalendarSelectCell.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLCalendarSelectCell.h"
#import "TLCalendarDotView.h"

@interface TLCalendarSelectCell ()

@property (nonatomic, strong) TLCalendarDotView *dotView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation TLCalendarSelectCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        return nil;
    }
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundView.backgroundColor = [UIColor clearColor];

    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-panel"]];
    [self.contentView addSubview:self.backgroundImageView];
    [self setupCustomColors];

    self.dotView = [[TLCalendarDotView alloc] initWithFrame:CGRectMake(10, 0, 8, 8)];
    [self.contentView addSubview:self.dotView];

    return self;
}

-(void)prepareForReuse {
    [self setupCustomColors];
}

-(void)layoutSubviews {
    [super layoutSubviews];

    self.dotView.center = CGPointMake(21, lrint(CGRectGetMidY(self.bounds)) - 1);
    self.textLabel.frame = CGRectInset(self.textLabel.frame, 16, 0);
    self.backgroundImageView.frame = CGRectMake(10, 1, 300, 44); // dimensions of the imageView's image
}

#pragma mark - Overridden Properties

-(void)setDotColor:(UIColor *)dotColor {
    _dotColor = dotColor;

    self.dotView.dotColor = dotColor;
}

#pragma mark - Private Methods

-(void)setupCustomColors {
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [[UIFont tl_appFont] fontWithSize:14];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.dotColor = [UIColor clearColor];

    UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-panel-active"]];
    self.selectedBackgroundView = selectedBackgroundView;
}

@end
