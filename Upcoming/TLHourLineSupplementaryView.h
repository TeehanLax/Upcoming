//
//  TLHourSupplementaryView.h
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-02.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLHourLineSupplementaryView : UICollectionReusableView

+(NSString *)kind;

@property (nonatomic, strong) NSString *timeString;

@end
