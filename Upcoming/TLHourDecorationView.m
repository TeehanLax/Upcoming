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
    
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.frame = CGRectIntegral(layoutAttributes.frame);
    
    if (layoutAttributes.indexPath.row % 2 == 0)
    {
        self.backgroundColor = [UIColor colorWithWhite:246.0/255.0 alpha:1.0f];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
