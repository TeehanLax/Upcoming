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

@end

@implementation TLCalendarSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))  return nil;
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-panel"]];
    [self setupCustomColors];
    
    self.dotView = [[TLCalendarDotView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.dotView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.dotView];
    
    return self;
}

-(void)prepareForReuse
{
    [self setupCustomColors];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dotView.center = CGPointMake(16, CGRectGetMidY(self.bounds));
    self.textLabel.frame = CGRectInset(self.textLabel.frame, 16, 0);
}

#pragma mark - Overridden Properties

-(void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    
    self.dotView.dotColor = dotColor;
    
    [self.dotView setNeedsDisplay];
}

#pragma mark - Private Methods

-(void)setupCustomColors
{
    self.backgroundColor = [UIColor darkGrayColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [[UIFont tl_appFont] fontWithSize:14];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.dotColor = [UIColor clearColor];
    
    UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-panel-active"]];
    self.selectedBackgroundView = selectedBackgroundView;
}

@end
