//
//  TLLoveButton.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-06.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLLoveButton.h"

@implementation TLLoveButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.titleLabel.frame;
    frame.origin.x = 10.0f;
    self.titleLabel.frame = frame;
    
    frame = self.imageView.frame;
    frame.origin.x = CGRectGetMaxX(self.titleLabel.frame) + 5.0f;
    self.imageView.frame = frame;
}

@end
