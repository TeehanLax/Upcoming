//
//  TLCollectionViewLayout.m
//  SingleCollectionView
//
//  Created by Brendan Lynch on 13-04-26.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLCollectionViewLayout.h"
#import "TLHourSupplementaryView.h"
#import "TLEventSupplementaryView.h"
#import "TLCollectionViewLayoutAttributes.h"

@implementation TLCollectionViewLayout

-(CGFloat)minimumInteritemSpacing {
    return 0.f;
}

-(CGFloat)minimumLineSpacing {
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

    attributes.zIndex = 0;

    return attributes;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [[super layoutAttributesForElementsInRect:rect] mutableCopy];

    [array addObject:[self layoutAttributesForSupplementaryViewOfKind:[TLHourSupplementaryView kind] atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];

    NSUInteger numberOfEvents;

    if ([self.collectionView.delegate conformsToProtocol:@protocol(TLCollectionViewLayoutDelegate)]) {
        numberOfEvents = [(id < TLCollectionViewLayoutDelegate >)(self.collectionView.delegate) collectionView : self.collectionView numberOfEventSupplementaryViewsInLayout : self];

        for (NSInteger i = 0; i < numberOfEvents; i++) {
            [array addObject:[self layoutAttributesForSupplementaryViewOfKind:[TLEventSupplementaryView kind] atIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
    }

    return array;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:[TLHourSupplementaryView kind]]) {
        TLCollectionViewLayoutAttributes *attributes = [TLCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];

        CGRect frame = CGRectZero;
        CGFloat alpha = 1.0f;
        CGFloat hourLineProgression = 0.5f;

        if ([self.collectionView.delegate conformsToProtocol:@protocol(TLCollectionViewLayoutDelegate)]) {
            frame = [(id < TLCollectionViewLayoutDelegate >)(self.collectionView.delegate) collectionView : self.collectionView frameForHourViewInLayout : self];
            alpha = [(id < TLCollectionViewLayoutDelegate >)(self.collectionView.delegate) collectionView : self.collectionView alphaForHourLineViewInLayout : self];
            hourLineProgression = [(id < TLCollectionViewLayoutDelegate >)(self.collectionView.delegate) collectionView : self.collectionView hourProgressionForHourLineViewInLayout : self];
        }

        attributes.frame = frame;
        attributes.alpha = alpha;
        attributes.hourLineProgressRatio = hourLineProgression;
        attributes.zIndex = 2;

        return attributes;
    } else {
        TLCollectionViewLayoutAttributes *attributes = [TLCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];

        CGRect frame = CGRectZero;

        if ([self.collectionView.delegate conformsToProtocol:@protocol(TLCollectionViewLayoutDelegate)]) {
            frame = [(id < TLCollectionViewLayoutDelegate >)(self.collectionView.delegate) collectionView : self.collectionView layout : self frameForEventSupplementaryViewAtIndexPath : indexPath];
        }

        attributes.frame = frame;
        attributes.alpha = 1.0f;
        attributes.zIndex = 1;

        return attributes;
    }
}

@end