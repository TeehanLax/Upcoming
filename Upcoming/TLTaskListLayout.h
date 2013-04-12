//
//  TLTaskListLayout.h
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLTaskListLayout;

@protocol TLTaskListLayoutDelegate <UICollectionViewDelegate>

-(NSInteger)collectionView:(UICollectionView *)collectionView layout:(TLTaskListLayout *)collectionViewLayout minuteDurationForItemAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)collectionView:(UICollectionView *)collectionView layout:(TLTaskListLayout *)collectionViewLayout minuteStartTimeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TLTaskListLayout : UICollectionViewLayout

@property (nonatomic, readonly) CGFloat hourSize;
@property (nonatomic, assign) CGFloat concentrationPoint;

@end
