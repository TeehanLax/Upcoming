//
//  TLHeaderViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHeaderViewController.h"
#import "EKEventManager.h"
#import "TLCalendarSelectCell.h"

#import <EXTScope.h>

const CGFloat kHeaderHeight = 72.0f;

@interface TLHeaderViewController ()

@property (nonatomic, weak) IBOutlet UITableView *calendarTableView;

@property (nonatomic, weak) IBOutlet UILabel *meetingNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *meetingLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *meetingTimeLabel;

@property (nonatomic, weak) IBOutlet UIView *tableMaskingView;

@end

@implementation TLHeaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    
    // Reload our table view whenever the sources change on the event manager
    @weakify(self);
    [[RACAble([EKEventManager sharedInstance], sources) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.calendarTableView reloadData];
    }];
        
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Update our header labels with the next event whenever it changes. 
    @weakify(self);
    [[RACAbleWithStart([EKEventManager sharedInstance], nextEvent) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(EKEvent *event) {
        @strongify(self);
        NSLog(@"New Event: %@", event);
        
        self.meetingNameLabel.text = event.title;
        self.meetingLocationLabel.text = event.location;
    }];
    
    // Set up the table view mask
    [self setupTableViewMask];
    
    // Remove the default table view background
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [UIColor clearColor];
    self.calendarTableView.backgroundView = backgroundView;
}

-(void)setupTableViewMask
{
    // This method sets up the mask for the view which contains the table view,
    // making it appear to "fade out" as it reaches the bottom.
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.tableMaskingView.bounds;
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    
    const CGFloat scrollIndicatorWidth = 8.0f;
    CALayer *scrollIndicatorBoxLayer = [CALayer layer];
    scrollIndicatorBoxLayer.frame = CGRectMake(CGRectGetWidth(self.tableMaskingView.bounds) - scrollIndicatorWidth, 0, scrollIndicatorWidth, CGRectGetHeight(self.tableMaskingView.bounds));
    scrollIndicatorBoxLayer.backgroundColor = [[UIColor blackColor] CGColor];
    [maskLayer addSublayer:scrollIndicatorBoxLayer];
    
    const CGFloat fadeOutHeight = 7.0f;
    CALayer *boxLayer = [CALayer layer];
    boxLayer.backgroundColor = [[UIColor blackColor] CGColor];
    boxLayer.frame = CGRectMake(0, 0, CGRectGetWidth(maskLayer.bounds), CGRectGetHeight(maskLayer.bounds) - fadeOutHeight);
    [maskLayer addSublayer:boxLayer];
    
    CAGradientLayer *maskingGradientLayer = [CAGradientLayer layer];
    [maskingGradientLayer setColors:@[(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor]]];
    maskingGradientLayer.frame = CGRectMake(0, CGRectGetHeight(maskLayer.bounds) - fadeOutHeight, CGRectGetWidth(maskLayer.bounds), fadeOutHeight);
    [maskLayer addSublayer:maskingGradientLayer];
    
    self.tableMaskingView.layer.mask = maskLayer;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    EKSource *source = [EKEventManager sharedInstance].sources[section];
    
    return source.title;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 37;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), [self tableView:tableView heightForHeaderInSection:section])];
    
    header.backgroundColor = [UIColor clearColor];
    
    const CGFloat leftMargin = 10.0f;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(header.bounds, leftMargin, 0)];
    [label setText:[self tableView:tableView titleForHeaderInSection:section]];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    
    [header addSubview:label];
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EKSource *source = [EKEventManager sharedInstance].sources[section];
    
    return [[source calendarsForEntityType:EKEntityTypeEvent] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[EKEventManager sharedInstance].sources count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[TLCalendarSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EKEventManager *eventManager = [EKEventManager sharedInstance];
    EKSource *source = eventManager.sources[indexPath.section];
    NSArray *calendars = [[source calendarsForEntityType:EKEntityTypeEvent] allObjects];
    EKCalendar *calendar = calendars[indexPath.row];
    
    cell.textLabel.text = calendar.title;
    if ([eventManager.selectedCalendars containsObject:calendar.calendarIdentifier])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKEventManager *eventManager = [EKEventManager sharedInstance];
    EKSource *source = eventManager.sources[indexPath.section];
    NSArray *calendars = [[source calendarsForEntityType:EKEntityTypeEvent] allObjects];
    EKCalendar *calendar = calendars[indexPath.row];
    
    [eventManager toggleCalendarWithIdentifier:calendar.calendarIdentifier];
}

-(void)scrollTableViewToTop
{
    [self.calendarTableView scrollRectToVisible:CGRectMake(1, 1, 1, 1) animated:NO];
}

@end
