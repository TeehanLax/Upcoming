//
//  TLEventSupplementaryView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-07.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLEventSupplementaryView.h"

@implementation TLEventSupplementaryView

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    
    return self;
}

+(NSString *)kind {
    return NSStringFromClass(self);
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
