//
//  TLViewController.h
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TLTaskListLayout.h"

@class TLDayListViewController;

@protocol TLDayListViewControllerDelegate <NSObject>

-(void)userDidBeginInteractingWithDayListView:(TLDayListViewController *)controller;
-(void)userDidEndInteractingWithDayListView:(TLDayListViewController *)controller;

@end

@interface TLDayListViewController : UICollectionViewController <TLTaskListLayoutDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<TLDayListViewControllerDelegate> delegate;

@end
