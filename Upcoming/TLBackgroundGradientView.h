//
//  TLBackgroundGradientView.h
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-25.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLBackgroundGradientView : UIView

// Change the ratio between normal colours and alerted colours.
-(void)setAlertRatio:(CGFloat)ratio animated:(BOOL)animated;

// Animated. 
-(void)setDarkened:(BOOL)darkened;

@end
