//
//  TLSplashViewController.h
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-08.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLSplashViewController;

@protocol TLSplashViewControllerDelegate <NSObject>

-(void)splashScreenControllerFinishedTransition:(TLSplashViewController *)controller;

@end

@interface TLSplashViewController : UIViewController

@property (nonatomic, weak) id<TLSplashViewControllerDelegate> delegate;

@end
