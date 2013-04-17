//
//  TLRootViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLRootViewController.h"

#import "TLDayListViewController.h"
#import "TLHeaderViewController.h"

static const CGFloat headerHeight = 72.0f;

@interface TLRootViewController ()

@property (nonatomic, strong) TLDayListViewController *dayListViewController;
@property (nonatomic, strong) TLHeaderViewController *headerViewController;

@property (nonatomic, strong) RACSubject *panSubject;
@property (nonatomic, strong) RACSubject *dayListMovementSubject;

@end

@implementation TLRootViewController

static const CGFloat kMaximumTranslationThreshold = 88.0f;
static const CGFloat kMaximumShrinkTranslation = 0.15f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    
    self.dayListViewController = [[TLDayListViewController alloc] init];
    [self addChildViewController:self.dayListViewController];
    
    self.headerViewController = [[TLHeaderViewController alloc] initWithNibName:@"TLHeaderViewController" bundle:nil];
    [self addChildViewController:self.headerViewController];
    
    self.dayListMovementSubject = [RACSubject subject];
    [self.dayListMovementSubject subscribeNext:^(id x) {
        CGFloat ratio = [x floatValue];
        
        if (ratio < 0.01)
        {
            self.dayListViewController.view.transform = CGAffineTransformIdentity;
        }
        else
        {
            self.dayListViewController.view.transform = CGAffineTransformMakeScale(1.0f - ratio * kMaximumShrinkTranslation, 1.0f - ratio * kMaximumShrinkTranslation);
        }
    }];
    
    self.panSubject = [RACSubject subject];
    [self.panSubject subscribeNext:^(NSNumber *translation) {
        CGFloat verticalTranslation = [translation floatValue];
        
        if (verticalTranslation <= 0)
        {
            [self.dayListMovementSubject sendNext:@(0)];
        }
        else
        {
            [self.dayListMovementSubject sendNext:@(MIN(fabsf(verticalTranslation / kMaximumTranslationThreshold), 1))];
        }
    }];
    
    return self;
}

-(void)loadView
{
    [super loadView];
    
    self.dayListViewController.view.frame = CGRectMake(0, headerHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - headerHeight);
    self.dayListViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.dayListViewController.view];
    
    self.headerViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), headerHeight);
    self.headerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.headerViewController.view];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:33.0f/255.0f alpha:1.0f];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    [self.headerViewController.view addGestureRecognizer:panGestureRecognizer];
}

-(void)userDidPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self.panSubject sendNext:@(translation.y)];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.25f animations:^{
            [self.panSubject sendNext:@(0)];
        }];
    }
}

@end
