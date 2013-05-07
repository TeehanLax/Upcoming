//
//  TLCollectionViewLayout.m
//  SingleCollectionView
//
//  Created by Brendan Lynch on 13-04-26.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLCollectionViewLayout.h"
#import "TLHourSupplementaryView.h"
#import "TLCollectionViewLayoutAttributes.h"

@implementation TLCollectionViewLayout

- (CGFloat)minimumInteritemSpacing {
    return 0.f;
}

- (CGFloat)minimumLineSpacing {
    return 0.f;
}

+(Class)layoutAttributesClass {
    return [TLCollectionViewLayoutAttributes class];
}

-(CGSize)collectionViewContentSize {
    return self.collectionView.bounds.size;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        attributes.zIndex = 0;
        return attributes;
    } else {
        attributes.zIndex = 1;
        
        UICollectionViewLayoutAttributes *backgroundAttributes = [super layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
        attributes.frame = backgroundAttributes.frame;
        
        return attributes;
    }
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    for (UICollectionViewLayoutAttributes *attributes in array) {
        if (attributes.indexPath.section == 0) continue;
        
        attributes.frame = [[self layoutAttributesForItemAtIndexPath:attributes.indexPath] frame];
    }
    
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:[TLHourSupplementaryView kind] atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [array addObject:attributes];
    
    return array;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (![kind isEqualToString:[TLHourSupplementaryView kind]])
        return nil;
    
    TLCollectionViewLayoutAttributes* attributes = [TLCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    CGRect frame = CGRectZero;
    CGFloat alpha = 1.0f;
    CGFloat hourLineProgression = 0.5f;
    
    if ([self.collectionView.delegate conformsToProtocol:@protocol(TLCollectionViewLayoutDelegate)])
    {
        frame = [(id<TLCollectionViewLayoutDelegate>)(self.collectionView.delegate) collectionView:self.collectionView frameForHourViewInLayout:self];
        alpha = [(id<TLCollectionViewLayoutDelegate>)(self.collectionView.delegate) collectionView:self.collectionView alphaForHourLineViewInLayout:self];
        hourLineProgression = [(id<TLCollectionViewLayoutDelegate>)(self.collectionView.delegate) collectionView:self.collectionView hourProgressionForHourLineViewInLayout:self];
    }
    
    attributes.frame = frame;
    attributes.alpha = alpha;
    attributes.hourLineProgressRatio = hourLineProgression;
    attributes.zIndex = 1;
    
    return attributes;
}


@end