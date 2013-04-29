//
//  ECViewController.h
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-17.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLTouchDownGestureRecognizer.h"
#import "TLPastViewController.h"
#import "TLFutureViewController.h"

@class TLEventViewController;

@protocol TLEventViewControllerDelegate <NSObject>

-(void)userDidBeginInteractingWithDayListViewController:(TLEventViewController *)controller;
-(void)userDidEndInteractingWithDayListViewController:(TLEventViewController *)controller;

-(void)userDidInteractWithDayListView:(TLEventViewController *)controller updatingTimeRatio:(CGFloat)timeRatio;

@end

@interface TLEventViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id<TLEventViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UICollectionView *pastView;
@property (nonatomic, strong) IBOutlet UICollectionView *currentView;
@property (nonatomic, strong) IBOutlet UICollectionView *futureView;

@property (nonatomic, strong) TLPastViewController *pastViewController;
@property (nonatomic, strong) TLFutureViewController *futureViewController;

@property (nonatomic, strong) TLTouchDownGestureRecognizer *touchDown;

@end