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

static const CGFloat headerHeight = 88.0f;

@interface TLRootViewController ()

@property (nonatomic, strong) TLDayListViewController *dayListViewController;
@property (nonatomic, strong) TLHeaderViewController *headerViewController;

@end

@implementation TLRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    
    self.dayListViewController = [[TLDayListViewController alloc] init];
    [self addChildViewController:self.dayListViewController];
    
    self.headerViewController = [[TLHeaderViewController alloc] initWithNibName:@"TLHeaderViewController" bundle:nil];
    [self addChildViewController:self.headerViewController];
    
    return self;
}

-(void)loadView
{
    [super loadView];
    
    self.dayListViewController.view.frame = CGRectMake(0, headerHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - headerHeight);
    [self.view addSubview:self.dayListViewController.view];
    
    self.headerViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), headerHeight);
    [self.view addSubview:self.headerViewController.view];
}

@end
