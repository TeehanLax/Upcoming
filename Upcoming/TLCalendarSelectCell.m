//
//  TLCalendarSelectCell.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLCalendarSelectCell.h"

@implementation TLCalendarSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))  return nil;
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-panel"]];
    [self setupCustomColors];
    
    return self;
}

-(void)prepareForReuse
{
    [self setupCustomColors];
}

#pragma mark - Private Methods

-(void)setupCustomColors
{
    self.backgroundColor = [UIColor darkGrayColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [[UIFont tl_appFont] fontWithSize:14];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-panel-active"]];
    self.selectedBackgroundView = selectedBackgroundView;
}

@end
