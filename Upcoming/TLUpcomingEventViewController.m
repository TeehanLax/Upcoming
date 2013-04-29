//
//  TLUpcomgingEventViewController.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLUpcomingEventViewController.h"

const CGFloat TLUpcomingEventViewControllerHiddenHeight = 5.0f;
const CGFloat TLUpcomingEventViewControllerTotalHeight = 59.0f;

@interface TLUpcomingEventViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation TLUpcomingEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upcomingEventBackground"]];
    [self.view addSubview:self.backgroundImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
