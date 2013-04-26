//
//  ECFutureViewController.h
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-23.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECFutureViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) CGFloat parentHeight;

@end