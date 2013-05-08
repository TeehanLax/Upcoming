//
//  TLLoveButton.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-06.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLLoveButton.h"

@implementation TLLoveButton

-(void)layoutSubviews {
    [super layoutSubviews];
    
    // Float the text left, then the image to the right of the text. 

    CGRect frame = self.titleLabel.frame;
    frame.origin.x = 10.0f;
    self.titleLabel.frame = frame;

    frame = self.imageView.frame;
    frame.origin.x = CGRectGetMaxX(self.titleLabel.frame) + 5.0f;
    self.imageView.frame = frame;
}

@end
