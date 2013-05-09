//
//  TLHeaderViewController.h
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EKEvent;
@class TLEventViewModel;
@class TLHeaderViewController;

@protocol TLHeaderViewControllerDelegate <NSObject>

-(void)userDidTapDismissHeaderButton;

@end

// Height of the visible header (while menu is hidden).
extern const CGFloat kHeaderHeight;
// Height of the visible header (while menu is open).
extern const CGFloat kUpperHeaderHeight;

@interface TLHeaderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(void)flashScrollBars;
-(void)scrollTableViewToTop;
-(void)hideHeaderView;
-(void)showHeaderView;

// Used when user is interacting with collection view.
-(void)updateHour:(NSInteger)hours minute:(NSInteger)minutes event:(TLEventViewModel *)eventViewModel;

@property (nonatomic, weak) id<TLHeaderViewControllerDelegate> delegate;

@property (nonatomic, assign) CGFloat arrowRotationRatio;

@end
