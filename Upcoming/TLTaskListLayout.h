//
//  TLTaskListLayout.h
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat TLTaskListLayoutConcentrationPointNone;

@class TLTaskListLayout;

@protocol TLTaskListLayoutDelegate <UICollectionViewDelegate>

// Whether or not we actually have an event in this hour. 
-(BOOL)collectionView:(UICollectionView *)collectionView layout:(TLTaskListLayout *)collectionViewLayout hasEventForHour:(NSInteger)hour;

@end

@interface TLTaskListLayout : UICollectionViewLayout

@property (nonatomic, readonly) CGFloat hourSize;
@property (nonatomic, assign) CGFloat concentrationPoint;

@end
