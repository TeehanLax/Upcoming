//
//  ECViewController.h
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-17.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLTouchDownGestureRecognizer.h"
#import "TLCollectionViewLayout.h"

@class TLEventViewController;
@class EKEvent;
@class TLEventViewModel;


@protocol TLEventViewControllerDelegate <NSObject>

-(void)userDidBeginInteractingWithDayListViewController:(TLEventViewController *)controller;
-(void)userDidEndInteractingWithDayListViewController:(TLEventViewController *)controller;

-(void)userDidInteractWithDayListView:(TLEventViewController *)controller updateTimeHour:(NSInteger)hour minute:(NSInteger)minute eventViewModel:(TLEventViewModel *)event;

@end



@interface TLEventViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, TLCollectionViewLayoutDelegate>

@property (nonatomic, weak) id<TLEventViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) TLTouchDownGestureRecognizer *touchDown;

// Determines whether finger is touching or not.
@property (nonatomic, assign, getter = isTouching) BOOL touching;

@end