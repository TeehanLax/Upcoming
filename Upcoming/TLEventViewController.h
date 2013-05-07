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

#define NUMBER_OF_ROWS 24
#define EXPANDED_ROWS  4
#define MAX_ROW_HEIGHT 38.f

@class TLEventViewController;
@class EKEvent;


@protocol TLEventViewControllerDelegate <NSObject>

-(void)userDidBeginInteractingWithDayListViewController:(TLEventViewController *)controller;
-(void)userDidEndInteractingWithDayListViewController:(TLEventViewController *)controller;

-(void)userDidInteractWithDayListView:(TLEventViewController *)controller updateTimeHour:(NSInteger)hour minute:(NSInteger)minute event:(EKEvent *)event;

@end

@interface TLEventViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, TLCollectionViewLayoutDelegate>

@property (nonatomic, weak) id<TLEventViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) TLTouchDownGestureRecognizer *touchDown;

@end