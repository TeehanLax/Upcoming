//
//  TLHourGutterSupplementaryView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-08.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHourGutterSupplementaryView.h"

@interface TLHourGutterSupplementaryView ()

@property (nonatomic, strong) UILabel *label; 

@end

@implementation TLHourGutterSupplementaryView

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.font = [[UIFont tl_appFont] fontWithSize:11];
    self.label.textColor = [UIColor blackColor];
    self.label.textAlignment = NSTextAlignmentCenter;

    [self addSubview:self.label];
    
    return self;
}

+(NSString *)kind {
    return NSStringFromClass(self);
}

-(void)setString:(NSString *)string {
    self.label.text = string;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.label.center = CGPointMake(self.label.center.x, lrint(CGRectGetMidY(self.bounds)));
}

@end
