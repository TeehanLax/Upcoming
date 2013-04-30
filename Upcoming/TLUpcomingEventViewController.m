//
//  TLUpcomgingEventViewController.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLUpcomingEventViewController.h"
#import "EKEventManager.h"

#import <ReactiveCocoa.h>
#import <EXTScope.h>

const CGFloat TLUpcomingEventViewControllerHiddenHeight = 5.0f;
const CGFloat TLUpcomingEventViewControllerTotalHeight = 82.0f;

@interface TLUpcomingEventViewController ()

@property (nonatomic, weak) IBOutlet UILabel *eventNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventRelativeTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventRelativeTimeUnitLabel;

@end

@implementation TLUpcomingEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
    
    // Reload our table view whenever the sources change on the event manager
    @weakify(self);
    [[RACAble([EKEventManager sharedInstance], nextEvent) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self reloadData];
    }];
    
}
-(void)reloadData
{
    EKEvent *event = [[EKEventManager sharedInstance] nextEvent];
    
    NSString *title = event.title;
    NSString *location = event.location;
    NSDate *startDate = event.startDate;
    NSDate *endDate = event.endDate;
        
    self.eventNameLabel.text = title;
    self.eventLocationLabel.text = location;
}

@end
