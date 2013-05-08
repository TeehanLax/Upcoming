//
//  TLSplashViewController.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-08.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLSplashViewController.h"
#import <BlocksKit.h>

@interface TLSplashViewController ()

@property (nonatomic, strong) NSArray *splashImageViews;
@property (nonatomic, strong) UIImageView *shadowImageView;

@end

@implementation TLSplashViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:5];
    
    CGFloat height = lrint(CGRectGetHeight(self.view.bounds) / 6);
    for (NSInteger i = 1; i <= 6; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"splash-%d", i]]];
        CGFloat y = lrint((CGRectGetHeight(self.view.bounds) / 6) * (i - 1));
        imageView.frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), height);
        
        if (i == 3) {
            UILabel *label = [[UILabel alloc] initWithFrame:imageView.bounds];
            label.backgroundColor = [UIColor clearColor];
            label.text = NSLocalizedString(@"Upcoming", @"Splash screen app name.");
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [[UIFont tl_boldAppFont] fontWithSize:36];
            label.textColor = [UIColor whiteColor];
            
            [imageView addSubview:label];
        }
        else if (i == 6) {
            const CGFloat logoMargin = 36.0f;
            
            UILabel *label = [[UILabel alloc] initWithFrame:imageView.bounds];
            label.backgroundColor = [UIColor clearColor];
            label.text = NSLocalizedString(@"Made with love by Teehan+Lax", @"Splash screen byline.");
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [[UIFont tl_mediumAppFont] fontWithSize:12];
            label.textColor = [UIColor whiteColor];
            [label sizeToFit];
            label.center = CGPointMake(lrint(CGRectGetMidX(imageView.bounds)) + logoMargin / 2.0f, lrint(CGRectGetMidY(imageView.bounds)));
            [imageView addSubview:label];
            
            UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
            CGSize imageSize = logoImageView.image.size;
            logoImageView.frame = CGRectMake(CGRectGetMinX(label.frame) - logoMargin, lrint(CGRectGetMidY(imageView.bounds)) - imageSize.height / 2.0f, imageSize.width, imageSize.height);
            [imageView addSubview:logoImageView];
        }
        
        [self.view addSubview:imageView];
        [mutableArray addObject:imageView];
    }
    
    self.shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inner-shadow"]];
    self.shadowImageView.frame = self.view.bounds;
    self.shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.shadowImageView];
    
    self.splashImageViews = [NSArray arrayWithArray:mutableArray];
    
    NSString *appearedBeforeString = @"Appeared";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:appearedBeforeString]) {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self removeImageViews];
        });
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:appearedBeforeString];
        
        [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [self removeImageViews];
        }]];
    }
}

-(void)removeImageViews {
    for (NSInteger i = 0; i < self.splashImageViews.count; i++) {
        UIImageView *imageView = self.splashImageViews[i];
        
        [UIView animateWithDuration:0.8f animations:^{
            [UIView animateWithDuration:0.2f animations:^{
                self.shadowImageView.alpha = 0.0f;
            }];
        }];
        
        [UIView animateWithDuration:0.1f delay:(i * 0.1f) options:UIViewAnimationOptionCurveEaseInOut animations:^{
            imageView.transform = CGAffineTransformMakeTranslation(-10, 0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                imageView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(imageView.frame), 0);
            } completion:^(BOOL finished) {
                if (i == 5) {
                    [self.delegate splashScreenControllerFinishedTransition:self];
                }
            }];
        }];
    }
}

@end
