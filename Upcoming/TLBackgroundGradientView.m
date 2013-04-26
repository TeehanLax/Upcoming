//
//  TLBackgroundGradientView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-25.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLBackgroundGradientView.h"

@interface TLBackgroundGradientView ()

@property (nonatomic, strong) UIImageView *innerShadowView;

@end

#define kNormalColors    @[(id)[[UIColor colorWithRed:42.0f/255.0f green:64.0/255.0f blue:99.0f/255.0f alpha:1.0f] CGColor],\
                           (id)[[UIColor colorWithRed:79.0f/255.0f green:122.0f/255.0f blue:165.0f/255.0f alpha:1.0f] CGColor],\
                           (id)[[UIColor colorWithRed:163.0f/255.0f green:219.0f/255.0f blue:225.0f/255.0f alpha:1.0f] CGColor],\
                           (id)[[UIColor colorWithRed:217.0f/255.0f green:236.0f/255.0f blue:203.0f/255.0f alpha:1.0f] CGColor],\
                           (id)[[UIColor colorWithRed:201.0f/255.0f green:142.0f/255.0f blue:131.0f/255.0f alpha:1.0f] CGColor]];


#define kAlertColors     @[(id)[[UIColor colorWithRed:18.0f/255.0f green:27.0/255.0f blue:42.0f/255.0f alpha:1.0f] CGColor],\
                           (id)[[UIColor colorWithRed:53.0f/255.0f green:81.0f/255.0f blue:109.0f/255.0f alpha:1.0f] CGColor],\
                           (id)[[UIColor colorWithRed:184.0f/255.0f green:226.0f/255.0f blue:231.0f/255.0f alpha:1.0f] CGColor],\
                           (id)[[UIColor colorWithRed:247.0f/255.0f green:180.0f/255.0f blue:180.0f/255.0f alpha:1.0f] CGColor],\
                           (id)[[UIColor colorWithRed:195.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f] CGColor]];

@implementation TLBackgroundGradientView

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.innerShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inner-shadow"]];
    self.innerShadowView.frame = self.bounds;
    self.innerShadowView.contentMode = UIViewContentModeScaleToFill;
    self.innerShadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.innerShadowView];
    
    NSArray *locationsArray = @[@(0.0f), @(0.34f), @(0.64f), @(0.76f), @(0.95f)];
    NSArray *colorsArray = kNormalColors;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.backgroundColor = [[UIColor clearColor] CGColor];
    gradientLayer.colors = colorsArray;
    gradientLayer.locations = locationsArray;
    
    [self.layer addSublayer:gradientLayer];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
        animation.fromValue = kNormalColors;
        animation.toValue = kAlertColors;
        animation.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.duration = 4.0f;
        
        gradientLayer.colors = kAlertColors;
        [gradientLayer addAnimation:animation forKey:nil];
        
    });
    
    return self;
}


@end

