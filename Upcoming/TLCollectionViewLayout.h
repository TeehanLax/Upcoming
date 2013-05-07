//
//  TLCollectionViewLayout.h
//  SingleCollectionView
//
//  Created by Brendan Lynch on 13-04-26.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLCollectionViewLayout;

@protocol TLCollectionViewLayoutDelegate <UICollectionViewDelegateFlowLayout>

-(CGRect)collectionView:(UICollectionView *)collectionView frameForHourViewInLayout:(TLCollectionViewLayout *)layout;
-(CGFloat)collectionView:(UICollectionView *)collectionView alphaForHourLineViewInLayout:(TLCollectionViewLayout *)layout;
-(CGFloat)collectionView:(UICollectionView *)collectionView hourProgressionForHourLineViewInLayout:(TLCollectionViewLayout *)layout;

-(NSUInteger)collectionView:(UICollectionView *)collectionView numberOfEventSupplementaryViewsInLayout:(TLCollectionViewLayout *)layout;
-(CGRect)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout frameForEventSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TLCollectionViewLayout : UICollectionViewFlowLayout

@end