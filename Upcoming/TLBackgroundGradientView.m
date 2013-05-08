//
//  TLBackgroundGradientView.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-25.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLBackgroundGradientView.h"

@interface TLBackgroundGradientView ()

// Gradient layer to display the pretty colours.
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
// Normal layer to darken the gradient (ie: on touch down).
@property (nonatomic, strong) CALayer *darkenLayer;
// Inner shadow view (provided by a png) to give depth to the gradient.
@property (nonatomic, strong) UIImageView *innerShadowView;

@end

#define kNormalColors \
    @[(id)[[UIColor colorWithRed:42.0f / 255.0f green:64.0 / 255.0f blue:99.0f / 255.0f alpha:1.0f] CGColor], \
      (id)[[UIColor colorWithRed:79.0f / 255.0f green:122.0f / 255.0f blue:165.0f / 255.0f alpha:1.0f] CGColor], \
      (id)[[UIColor colorWithRed:163.0f / 255.0f green:219.0f / 255.0f blue:225.0f / 255.0f alpha:1.0f] CGColor], \
      (id)[[UIColor colorWithRed:217.0f / 255.0f green:236.0f / 255.0f blue:203.0f / 255.0f alpha:1.0f] CGColor], \
      (id)[[UIColor colorWithRed:201.0f / 255.0f green:142.0f / 255.0f blue:131.0f / 255.0f alpha:1.0f] CGColor]];


#define kAlertColors \
    @[(id)[[UIColor colorWithRed:18.0f / 255.0f green:27.0 / 255.0f blue:42.0f / 255.0f alpha:1.0f] CGColor], \
      (id)[[UIColor colorWithRed:53.0f / 255.0f green:81.0f / 255.0f blue:109.0f / 255.0f alpha:1.0f] CGColor], \
      (id)[[UIColor colorWithRed:184.0f / 255.0f green:226.0f / 255.0f blue:231.0f / 255.0f alpha:1.0f] CGColor], \
      (id)[[UIColor colorWithRed:247.0f / 255.0f green:180.0f / 255.0f blue:180.0f / 255.0f alpha:1.0f] CGColor], \
      (id)[[UIColor colorWithRed:195.0f / 255.0f green:60.0f / 255.0f blue:60.0f / 255.0f alpha:1.0f] CGColor]];

@implementation TLBackgroundGradientView

-(id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }

    self.innerShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inner-shadow"]];
    self.innerShadowView.frame = self.bounds;
    self.innerShadowView.contentMode = UIViewContentModeScaleToFill;
    self.innerShadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.innerShadowView];

    NSArray *locationsArray = @[@(0.0f), @(0.34f), @(0.64f), @(0.76f), @(0.95f)];
    NSArray *colorsArray = kNormalColors;

    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    self.gradientLayer.backgroundColor = [[UIColor clearColor] CGColor];
    self.gradientLayer.colors = colorsArray;
    self.gradientLayer.locations = locationsArray;
    [self.layer insertSublayer:self.gradientLayer atIndex:0];

    self.darkenLayer = [CALayer layer];
    self.darkenLayer.opacity = 0.0f;
    self.darkenLayer.frame = self.bounds;
    self.darkenLayer.backgroundColor = [[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor];
    [self.layer insertSublayer:self.darkenLayer above:self.gradientLayer];

    return self;
}

-(void)setAlertRatio:(CGFloat)ratio animated:(BOOL)animated {
    NSArray *fromColors = self.gradientLayer.colors;
    NSArray *normalColorsArray = kNormalColors;
    NSArray *alertColorsArray = kAlertColors;

    NSMutableArray *toColors = [NSMutableArray arrayWithCapacity:fromColors.count];

    for (NSInteger i = 0; i < fromColors.count; i++) {
        UIColor *alertColor = [UIColor colorWithCGColor:(CGColorRef)(alertColorsArray[i])];
        UIColor *normalColor = [UIColor colorWithCGColor:(CGColorRef)(normalColorsArray[i])];

        UIColor *newColor = [UIColor tl_interpolatedColorWithRatio:ratio color:normalColor color:alertColor];
        [toColors insertObject:(id)[newColor CGColor] atIndex:i];
    }

    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
        animation.fromValue = fromColors;
        animation.toValue = toColors;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.duration = 1.0f;

        self.gradientLayer.colors = toColors;
        [self.gradientLayer addAnimation:animation forKey:@"colors"];
    } else {
        self.gradientLayer.colors = toColors;
    }
}

-(void)setDarkened:(BOOL)darkened {
    if (darkened) {
        self.darkenLayer.opacity = 1.0f;
    } else {
        self.darkenLayer.opacity = 0.0f;
    }

    CATransition *transition = [CATransition animation];
    transition.duration = 0.2f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.darkenLayer addAnimation:transition forKey:nil];
}

@end
