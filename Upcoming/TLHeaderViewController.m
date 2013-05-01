//
//  TLHeaderViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHeaderViewController.h"
#import "EKEventManager.h"
#import "TLClockHeaderView.h"
#import "TLCalendarDotView.h"
#import "TLCalendarSelectCell.h"

#import <EXTScope.h>

const CGFloat kHeaderHeight = 72.0f;

@interface TLHeaderViewController ()

@property (nonatomic, weak) IBOutlet UITableView *calendarTableView;

@property (nonatomic, weak) IBOutlet UIView *headerDetailView;
@property (nonatomic, weak) IBOutlet TLClockHeaderView *headerClockView;

@property (nonatomic, weak) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventRelativeTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventRelativeTimeUnitLabel;
@property (nonatomic, weak) IBOutlet UIImageView *eventLocationImageView;
@property (nonatomic, weak) IBOutlet TLCalendarDotView *calendarView;

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
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Update our header labels with the next event whenever it changes. 
    //    @weakify(self);
    [[[[[RACSignal combineLatest:@[RACAbleWithStart([EKEventManager sharedInstance], events), RACAbleWithStart([EKEventManager sharedInstance], nextEvent)]
                        reduce:^id(NSArray *eventArray, EKEvent *nextEvent)
       {
           
           NSArray *filteredArray = [[[eventArray.rac_sequence filter:^BOOL(EKEvent *event) {
               return [event.startDate compare:[NSDate date]] == NSOrderedDescending;
           }] array] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
               return [[obj1 startDate] compare:[obj2 startDate]];
           }];
           
           if (filteredArray.count == 0)
           {
               return nextEvent;
           }
           else
           {
               return filteredArray[0];
           }
           
       }] deliverOn:[RACScheduler mainThreadScheduler]] distinctUntilChanged] throttle:0.25f]
     subscribeNext:^(EKEvent *event) {
         
         if (event == nil)
         {
             
             self.eventTitleLabel.text = NSLocalizedString(@"No Upcoming Event", @"No upcoming event header text");
             self.eventLocationLabel.text = @"";
             self.eventTimeLabel.text = @"";
             self.eventRelativeTimeLabel.text = @"";
             self.eventRelativeTimeUnitLabel.text = @"";
             self.eventLocationImageView.alpha = 0.0f;
             self.calendarView.alpha = 0.0f;
             
             return;
         }
         
         NSCalendar *calendar = [NSCalendar currentCalendar];
         
         unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
         NSDateComponents *startTimeComponents = [calendar components:unitFlags fromDate:[NSDate date] toDate:event.startDate options:0];
         
         // Check for descending unit lengths being greater than zero for the largest, non-zero component.
         if (startTimeComponents.month > 0)
         {
             NSInteger numberOfMonths = startTimeComponents.month;
             
             if (startTimeComponents.day > 15)
             {
                 numberOfMonths++;
             }
             
             self.eventRelativeTimeLabel.text = [NSString stringWithFormat:@"%d", numberOfMonths];
             
             if (numberOfMonths == 1)
             {
                 self.eventRelativeTimeUnitLabel.text = NSLocalizedString(@"Month", @"Month unit singular");
             }
             else
             {
                 self.eventRelativeTimeUnitLabel.text = NSLocalizedString(@"Months", @"Month unit plural");
             }
         }
         else if (startTimeComponents.day > 0)
         {
             self.eventRelativeTimeLabel.text = [NSString stringWithFormat:@"%d", startTimeComponents.day];
             
             if (startTimeComponents.day == 1)
             {
                 self.eventRelativeTimeUnitLabel.text = NSLocalizedString(@"Day", @"Day unit singular");
             }
             else
             {
                 self.eventRelativeTimeUnitLabel.text = NSLocalizedString(@"Days", @"Day unit plural");
             }
         }
         else if (startTimeComponents.hour > 0)
         {
             NSInteger numberOfHours = startTimeComponents.hour;
             
             if (startTimeComponents.minute > 30)
             {
                 numberOfHours++;
             }
             
             self.eventRelativeTimeLabel.text = [NSString stringWithFormat:@"%d", numberOfHours];
             
             if (numberOfHours == 1)
             {
                 self.eventRelativeTimeUnitLabel.text = NSLocalizedString(@"Hour", @"Hour unit singular");
             }
             else
             {
                 self.eventRelativeTimeUnitLabel.text = NSLocalizedString(@"Hours", @"Hour unit plural");
             }
         }
         else if (startTimeComponents.minute > 0)
         {
             self.eventRelativeTimeLabel.text = [NSString stringWithFormat:@"%d", startTimeComponents.minute];
             
             if (startTimeComponents.minute == 1)
             {
                 self.eventRelativeTimeUnitLabel.text = NSLocalizedString(@"Minute", @"Minute unit singular");
             }
             else
             {
                 self.eventRelativeTimeUnitLabel.text = NSLocalizedString(@"Minutes", @"Minute unit plural");
             }
         }
         
         self.eventTitleLabel.text = event.title;
         self.eventLocationLabel.text = event.location;
         self.eventTimeLabel.text = [NSString stringWithFormat:@"%@ – %@",
                                       [NSDateFormatter localizedStringFromDate:event.startDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle],
                                       [NSDateFormatter localizedStringFromDate:event.endDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
         
         if ([self.eventLocationLabel.text length] > 0)
         {
             self.eventLocationImageView.alpha = 1.0f;
         }
         else
         {
             self.eventLocationImageView.alpha = 0.0f;
         }
         
         self.calendarView.alpha = 1.0f;
         self.calendarView.dotColor = [UIColor colorWithCGColor:event.calendar.CGColor];
     }];
    
    // Set up the table view mask
    [self setupTableViewMask];
    
    // Set our custom colours
    self.eventTitleLabel.textColor = [UIColor headerTextColor];
    self.eventLocationLabel.textColor = [UIColor headerTextColor];
    self.eventTimeLabel.textColor = [UIColor headerTextColor];
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
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
    label.font = [[UIFont tl_mediumAppFont] fontWithSize:32];
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
    TLCalendarSelectCell *cell = (TLCalendarSelectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    }
    else
    {
        cell.accessoryView = nil;
    }
    
    cell.dotColor = [UIColor colorWithCGColor:calendar.CGColor];

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

#pragma mark - Public Methods

-(void)flashScrollBars
{
    [self.calendarTableView flashScrollIndicators];
}

-(void)scrollTableViewToTop
{
    [self.calendarTableView scrollRectToVisible:CGRectMake(1, 1, 1, 1) animated:NO];
}

/*
 Each of the following two animations is actually made up of four discrete animations. 
 First, we pull down by some distange, then pull back up to hide the view completely. 
 A delay occurs, then another view falls back down to the pulled-down distance
 then returns to its resting state. 
 */

static CGFloat pullDownDistance = 7.0f;

static CGFloat pullDownAnimationDuration = 0.075f;
static CGFloat pullUpAnimationDuration = 0.15f;
static CGFloat fallDownAnimationDuration = 0.15f;
static CGFloat interAnimationDelay = 0.05f;

-(void)hideHeaderView
{
    [UIView animateWithDuration:pullDownAnimationDuration animations:^{
        self.headerDetailView.transform = CGAffineTransformMakeTranslation(0, pullDownDistance);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:pullUpAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.headerDetailView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.headerDetailView.frame));
        } completion:^(BOOL finished) {
            self.headerClockView.alpha = 1.0f;
            self.headerClockView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.headerClockView.frame));
            [UIView animateWithDuration:fallDownAnimationDuration delay:interAnimationDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.headerClockView.transform = CGAffineTransformMakeTranslation(0, pullDownDistance);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:pullDownAnimationDuration animations:^{
                    self.headerClockView.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
    }];
}

-(void)showHeaderView
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:pullDownAnimationDuration animations:^{
        self.headerClockView.transform = CGAffineTransformMakeTranslation(0, pullDownDistance);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:pullUpAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.headerClockView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.headerDetailView.frame));
        } completion:^(BOOL finished) {
            self.headerClockView.alpha = 0.0f;
            [UIView animateWithDuration:fallDownAnimationDuration delay:interAnimationDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.headerDetailView.transform = CGAffineTransformMakeTranslation(0, pullDownDistance);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:pullDownAnimationDuration animations:^{
                    self.headerDetailView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }];
            }];
        }];
    }];
}

-(void)updateTimeRatio:(CGFloat)timeRatio
{
    self.headerClockView.timeRatio = timeRatio;
}

@end
