//
//  ECViewController.h
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-17.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECPastViewController.h"
#import "ECFutureViewController.h"

@interface ECViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *pastView;
@property (nonatomic, strong) IBOutlet UICollectionView *currentView;
@property (nonatomic, strong) IBOutlet UICollectionView *futureView;

@property (nonatomic, strong) ECPastViewController *pastViewController;
@property (nonatomic, strong) ECFutureViewController *futureViewController;

@end