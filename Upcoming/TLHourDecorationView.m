//
//  TLHourDecorationView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-15.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHourDecorationView.h"

@implementation TLHourDecorationView

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.backgroundColor = [UIColor orangeColor];
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 0.5f;
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
