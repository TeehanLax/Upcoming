//
//  ECViewController.h
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-17.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLTouchDownGestureRecognizer.h"

@class TLEventViewController;
@class EKEvent;

@protocol TLEventViewControllerDelegate <NSObject>

-(void)userDidBeginInteractingWithDayListViewController:(TLEventViewController *)controller;
-(void)userDidEndInteractingWithDayListViewController:(TLEventViewController *)controller;

-(void)userDidInteractWithDayListView:(TLEventViewController *)controller updatingTimeRatio:(CGFloat)timeRatio event:(EKEvent *)event;

@end

@interface TLEventViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id<TLEventViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) TLTouchDownGestureRecognizer *touchDown;

@end