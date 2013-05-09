//
//  TLEventSupplementaryView.h
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-07.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLEventSupplementaryView : UICollectionReusableView

+(NSString *)kind;

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *timeString;

@property (nonatomic, strong) UIView *contentView;

@end