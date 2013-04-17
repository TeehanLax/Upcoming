//
//  TLHeaderViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHeaderViewController.h"
#import "EKEventManager.h"

#import <EXTScope.h>

@interface TLHeaderViewController ()

@property (nonatomic, weak) IBOutlet UITableView *calendarTableView;

@end

@implementation TLHeaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    
    @weakify(self);
    [RACAble([EKEventManager sharedInstance], sources) subscribeNext:^(id x) {
        @strongify(self);
        [self.calendarTableView reloadData];
    }];
        
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [UIColor clearColor];
    self.calendarTableView.backgroundView = backgroundView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    EKSource *source = [EKEventManager sharedInstance].sources[section];
    
    return source.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EKSource *source = [EKEventManager sharedInstance].sources[section];
    
    return [[source calendarsForEntityType:EKEntityTypeEvent] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[EKEventManager sharedInstance].sources count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EKEventManager *eventManager = [EKEventManager sharedInstance];
    EKSource *source = eventManager.sources[indexPath.section];
    NSArray *calendars = [[source calendarsForEntityType:EKEntityTypeEvent ] allObjects];
    EKCalendar *calendar = calendars[indexPath.row];
    
    cell.textLabel.text = calendar.title;
    if ([eventManager.selectedCalendars containsObject:calendar.calendarIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
