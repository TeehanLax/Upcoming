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

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout alphaForCellContentAtIndexPath:(NSIndexPath *)indexPath;

-(CGRect)collectionView:(UICollectionView *)collectionView frameForHourViewInLayout:(TLCollectionViewLayout *)layout;
-(CGFloat)collectionView:(UICollectionView *)collectionView alphaForHourLineViewInLayout:(TLCollectionViewLayout *)layout;

-(NSUInteger)collectionView:(UICollectionView *)collectionView numberOfEventSupplementaryViewsInLayout:(TLCollectionViewLayout *)layout;
-(CGRect)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout frameForEventSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout alphaForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TLCollectionViewLayout : UICollectionViewFlowLayout

@end