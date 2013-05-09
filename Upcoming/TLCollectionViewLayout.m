//
//  TLCollectionViewLayout.m
//  SingleCollectionView
//
//  Created by Brendan Lynch on 13-04-26.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLCollectionViewLayout.h"
#import "TLHourLineSupplementaryView.h"
#import "TLEventSupplementaryView.h"

@implementation TLCollectionViewLayout

-(CGFloat)minimumInteritemSpacing {
    return 0.0f;
}

-(CGFloat)minimumLineSpacing {
    return 0.0f;
}

+(Class)layoutAttributesClass {
    return [TLCollectionViewLayoutAttributes class];
}

-(CGSize)collectionViewContentSize {
    return self.collectionView.bounds.size;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    TLCollectionViewLayoutAttributes *attributes = (TLCollectionViewLayoutAttributes *)[super layoutAttributesForItemAtIndexPath:indexPath];

    // hours are in the "background" – 0 zIndex. 
    attributes.zIndex = 0;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(TLCollectionViewLayoutDelegate)]) {
        attributes.contentAlpha = [(id<TLCollectionViewLayoutDelegate>)(self.collectionView.delegate) collectionView:self.collectionView layout:self alphaForCellContentAtIndexPath:indexPath];
    }

    return attributes;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    for (TLCollectionViewLayoutAttributes *attributes in array) {
        attributes.contentAlpha = [(id<TLCollectionViewLayoutDelegate>)(self.collectionView.delegate) collectionView:self.collectionView layout:self alphaForCellContentAtIndexPath:attributes.indexPath];
    }
    
    [array addObject:[self layoutAttributesForSupplementaryViewOfKind:[TLHourLineSupplementaryView kind] atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];

    NSUInteger numberOfEvents;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(TLCollectionViewLayoutDelegate)]) {
        numberOfEvents = [(id <TLCollectionViewLayoutDelegate>)(self.collectionView.delegate) collectionView:self.collectionView numberOfEventSupplementaryViewsInLayout:self];

        for (NSInteger i = 0; i < numberOfEvents; i++) {
            [array addObject:[self layoutAttributesForSupplementaryViewOfKind:[TLEventSupplementaryView kind] atIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
    }

    return array;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    TLCollectionViewLayoutAttributes *attributes = [TLCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    if ([kind isEqualToString:[TLHourLineSupplementaryView kind]]) {
        CGRect frame = CGRectZero;
        CGFloat alpha = 1.0f;

        if ([self.collectionView.delegate conformsToProtocol:@protocol(TLCollectionViewLayoutDelegate)]) {
            id<TLCollectionViewLayoutDelegate> delegate = (id<TLCollectionViewLayoutDelegate>)self.collectionView.delegate;
            frame = [delegate collectionView:self.collectionView frameForHourLineViewInLayout:self];
            alpha = [delegate collectionView:self.collectionView alphaForHourLineViewInLayout:self];
        }

        attributes.frame = frame;
        attributes.alpha = alpha;
        attributes.zIndex = 4;

        return attributes;
    } else if ([kind isEqualToString:[TLEventSupplementaryView kind]]) {
        CGRect frame = CGRectZero;
        CGFloat alpha = 0.0f;
        TLCollectionViewLayoutAttributesBackgroundState backgroundState;
        TLCollectionViewLayoutAttributesAlignment alignment;

        if ([self.collectionView.delegate conformsToProtocol:@protocol(TLCollectionViewLayoutDelegate)]) {
            id<TLCollectionViewLayoutDelegate> delegate = (id<TLCollectionViewLayoutDelegate>)self.collectionView.delegate;
            
            frame = [delegate collectionView:self.collectionView layout:self frameForEventSupplementaryViewAtIndexPath:indexPath];
            alpha = [delegate collectionView:self.collectionView layout:self alphaForSupplementaryViewAtIndexPath:indexPath];
            backgroundState = [delegate collectionView:self.collectionView layout:self backgroundStateForSupplementaryViewAtIndexPath:indexPath];
            alignment = [delegate collectionView:self.collectionView layout:self alignmentForSupplementaryViewAtIndexPath:indexPath];
        }

        attributes.frame = frame;
        attributes.alpha = 1.0f;
        attributes.contentAlpha = alpha;
        attributes.backgroundState = backgroundState;
        attributes.alignment = alignment;
        attributes.zIndex = 3;

    }
    
    return attributes;
}

@end