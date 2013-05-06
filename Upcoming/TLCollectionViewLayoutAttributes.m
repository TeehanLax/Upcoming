//
//  TLHourLineSupplementaryViewLayoutAttributes.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-03.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLCollectionViewLayoutAttributes.h"

@implementation TLCollectionViewLayoutAttributes

-(id)copyWithZone:(NSZone *)zone
{
    TLCollectionViewLayoutAttributes *otherAttributes = [super copyWithZone:zone];
    
    otherAttributes.hourLineHeight = self.hourLineHeight;
    otherAttributes.hourLineProgressRatio = self.hourLineProgressRatio;
    
    return otherAttributes;
}

@end
