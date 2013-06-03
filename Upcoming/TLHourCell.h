//
//  TLEventViewCell.h
//  Upcoming
//
//  Created by Brendan Lynch on 13-04-30.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLHourCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIView *background;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImage;

@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat maxY;

-(void)setHour:(NSInteger)hour;

@end
