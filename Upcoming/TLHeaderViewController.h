//
//  TLHeaderViewController.h
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EKEvent;

@class TLHeaderViewController;

@protocol TLHeaderViewControllerDelegate <NSObject>

-(void)userDidTapDismissHeaderButton;

@end

extern const CGFloat kHeaderHeight;
extern const CGFloat kUpperHeaderHeight;

@interface TLHeaderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(void)flashScrollBars;
-(void)scrollTableViewToTop;
-(void)hideHeaderView;
-(void)showHeaderView;
-(void)updateHour:(NSInteger)hours minute:(NSInteger)minutes event:(EKEvent *)event;

@property (nonatomic, weak) id<TLHeaderViewControllerDelegate> delegate;

@property (nonatomic, assign) CGFloat arrowRotationRatio;

@end
