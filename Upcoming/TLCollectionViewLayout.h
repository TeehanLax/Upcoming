//
//  TLCollectionViewLayout.h
//  SingleCollectionView
//
//  Created by Brendan Lynch on 13-04-26.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLCollectionViewLayoutAttributes.h"

#define NUMBER_OF_ROWS 24
#define EXPANDED_ROWS  3
#define MAX_ROW_HEIGHT 44.f

@class TLCollectionViewLayout;

@protocol TLCollectionViewLayoutDelegate <UICollectionViewDelegateFlowLayout>

// Methods for cells.
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout alphaForCellContentAtIndexPath:(NSIndexPath *)indexPath;

// Methods for hour line supplementary views.
-(CGRect)collectionView:(UICollectionView *)collectionView frameForHourLineViewInLayout:(TLCollectionViewLayout *)layout;
-(CGFloat)collectionView:(UICollectionView *)collectionView alphaForHourLineViewInLayout:(TLCollectionViewLayout *)layout;

// Methods for event supplementary views. 
-(NSUInteger)collectionView:(UICollectionView *)collectionView numberOfEventSupplementaryViewsInLayout:(TLCollectionViewLayout *)layout;
-(CGRect)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout frameForEventSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout alphaForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;
-(TLCollectionViewLayoutAttributesBackgroundState)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout backgroundStateForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;
-(TLCollectionViewLayoutAttributesAlignment)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout alignmentForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;

@end

// Most of the logic for the actual layout is in UICollectionViewFlowLayout and delegate
// callbacks (since the layout relies heavily on the state of the view controller). 
@interface TLCollectionViewLayout : UICollectionViewFlowLayout

@end