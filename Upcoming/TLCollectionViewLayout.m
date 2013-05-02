//
//  TLCollectionViewLayout.m
//  SingleCollectionView
//
//  Created by Brendan Lynch on 13-04-26.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLCollectionViewLayout.h"
#import "TLHourSupplementaryView.h"

@implementation TLCollectionViewLayout

- (CGFloat)minimumInteritemSpacing {
    return 0.f;
}

- (CGFloat)minimumLineSpacing {
    return 0.f;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:[TLHourSupplementaryView kind] atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [array addObject:attributes];
    
    return array;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (![kind isEqualToString:[TLHourSupplementaryView kind]])
        return nil;
    
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    CGRect frame = CGRectZero;
    
    if ([self.collectionView.delegate conformsToProtocol:@protocol(TLCollectionViewLayoutDelegate)])
    {
        frame = [(id<TLCollectionViewLayoutDelegate>)(self.collectionView.delegate) collectionView:self.collectionView frameForHourViewInLayout:self];
    }
    
    attributes.frame = frame;
    attributes.zIndex = 1;
    
    return attributes;
}


@end