//
//  TLTaskListLayout.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLTaskListLayout.h"

@implementation TLTaskListLayout

-(id)init
{
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(320, 10);
    self.minimumInteritemSpacing = 0.0f;
    self.sectionInset = UIEdgeInsetsZero;
    
    return self;
}

-(CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    return attributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* layoutAttributesArray = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributesArray)
    {
        if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
        {
            // Header
            attributes.size = CGSizeMake(300, 20);
            attributes.zIndex = 0;
        }
        else
        {
            // Cell
            attributes.zIndex = 1;
        }
    }
    
    return layoutAttributesArray;
}

@end
