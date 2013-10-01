//
//  TLHeaderViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLHeaderViewController.h"
#import "EKEventManager.h"
#import "TLLoveButton.h"
#import "TLEventViewModel.h"
#import "TLCalendarDotView.h"
#import "TLCalendarSelectCell.h"

#import <ViewUtils.h>
#import <ReactiveCocoaLayout.h>

const CGFloat kHeaderHeight = 72.0f;
const CGFloat kUpperHeaderHeight = 52.0f;

@interface TLHeaderViewController ()

@property (nonatomic, weak) IBOutlet UITableView *calendarTableView;

@property (nonatomic, weak) IBOutlet UIView *headerDetailView;
@property (nonatomic, weak) IBOutlet UIView *headerAlernateDetailView;

@property (nonatomic, weak) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventNowLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventRelativeTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventRelativeTimeUnitLabel;
@property (nonatomic, weak) IBOutlet UIImageView *eventLocationImageView;
@property (nonatomic, weak) IBOutlet TLCalendarDotView *calendarView;

// Alternate event used while scrubbing over collection view
@property (nonatomic, weak) IBOutlet UILabel *alternateEventTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *alternateEventLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *alternateEventTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *alternateAbsoluteTimeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *alternateEventLocationImageView;
@property (nonatomic, weak) IBOutlet TLCalendarDotView *alternateCalendarView;
@property (nonatomic, strong) RACSubject *alternateEventSubject;

// All-day event properties
@property (nonatomic, weak) IBOutlet UIPageControl *allDayEventPageControl;
@property (nonatomic, weak) IBOutlet UIScrollView *allDayEventScrollView;
@property (nonatomic, strong) NSArray *allDayEventViews;

@property (nonatomic, weak) IBOutlet UIView *tableMaskingView;

@property (nonatomic, weak) IBOutlet UIButton *arrowButton;

@end

@implementation TLHeaderViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        return nil;
    }
    
    // Reload our table view whenever the sources change on the event manager
    @weakify(self);
    [[RACObserve([EKEventManager sharedInstance], sources) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.calendarTableView reloadData];
    }];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    RACSignal *timerSignal = [[[RACSignal interval:60] startWith:[NSDate date]] deliverOn:[RACScheduler mainThreadScheduler]];
    
    @weakify(self);
    
    RACSignal *todayAllDayEventsSignal = [[[EKEventManager sharedInstance] eventsSignal] map:^id(NSArray *eventArray) {
        NSArray *allDayEvents = [eventArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent *event, NSDictionary *bindings) {
            return event.isAllDay;
        }]];
        return allDayEvents;
    }];
    
    RACSignal *allDayEventSignal = [[RACSignal combineLatest:@[todayAllDayEventsSignal, timerSignal] reduce:^id (NSArray *allDayEventArray, NSDate *fireDate) {
        return allDayEventArray;
    }] deliverOn:[RACScheduler mainThreadScheduler]];
    
    // Bind the number of pages to the number of all-day events, plus one for the upcoming event
    RAC(self.allDayEventPageControl, numberOfPages) = [allDayEventSignal map:^id(id value) {
        return @([value count] + 1);
    }];
    
    // Hide the page control when there is only one page
    RAC(self.allDayEventPageControl, alpha) = [[allDayEventSignal map:^id(id value) {
        if ([value count] == 0) return @(0.0f);
        else return @(1.0f);
    }] animate];
    
    // Bind the content size of the scroll view to a mapping of the number of events. 
    RAC(self.allDayEventScrollView, contentSize) = [allDayEventSignal map:^id(id value) {
        @strongify(self);
        return [NSValue valueWithCGSize:CGSizeMake(CGRectGetWidth(self.allDayEventScrollView.frame) * ([value count] + 1), CGRectGetHeight(self.allDayEventScrollView.frame))];
    }];
    
    // Bind the content offset to the page control's current page, and vice versa
    [[self.allDayEventPageControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UIPageControl *pageControl) {
        @strongify(self);
        [self.allDayEventScrollView scrollRectToVisible:CGRectMake(self.allDayEventPageControl.currentPage * CGRectGetWidth(self.allDayEventScrollView.frame), 0, CGRectGetWidth(self.allDayEventScrollView.frame), CGRectGetHeight(self.allDayEventScrollView.frame)) animated:YES];
    }];
    RAC(self.allDayEventPageControl, currentPage) = [[RACObserve(self.allDayEventScrollView, contentOffset) distinctUntilChanged] map:^id(id value) {
        @strongify(self);
        
        CGPoint contentOffset = [value CGPointValue];
        NSInteger currentPage = contentOffset.x / CGRectGetWidth(self.allDayEventScrollView.frame);
        
        return @(currentPage);
    }];
    
    [allDayEventSignal subscribeNext:^(NSArray *eventArray) {
        @strongify(self);
        for (UIView *view in self.allDayEventViews) {
            [view removeFromSuperview];
        }
        self.allDayEventViews = nil;
        
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:eventArray.count];
        
        CGFloat width = CGRectGetWidth(self.allDayEventScrollView.frame);
        CGFloat height = CGRectGetHeight(self.allDayEventScrollView.frame);
        for (NSInteger i = 0; i < eventArray.count; i++) {
            EKEvent *event = eventArray[i];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(width * (i+1), 0, width, height)];
            
            UILabel *eventNameLabel = [[UILabel alloc] initWithFrame:CGRectOffset(CGRectInset(view.bounds, 0, 20), 0, -5)];
            eventNameLabel.font = [[UIFont tl_mediumAppFont] fontWithSize:16];
            eventNameLabel.backgroundColor = [UIColor clearColor];
            eventNameLabel.text = event.title;
            eventNameLabel.textColor = [UIColor whiteColor];
            eventNameLabel.textAlignment = NSTextAlignmentCenter;
            [view addSubview:eventNameLabel];
            
            UILabel *allDayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            allDayLabel.font = [[UIFont tl_demiBoldAppFont] fontWithSize:14];
            allDayLabel.backgroundColor = [UIColor clearColor];
            allDayLabel.text = NSLocalizedString(@"All Day", @"All Day event byline");
            allDayLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
            allDayLabel.textAlignment = NSTextAlignmentCenter;
            [allDayLabel sizeToFit];
            allDayLabel.center = CGPointMake(width / 2.0f + 5, 55);
            [view addSubview:allDayLabel];
            
            TLCalendarDotView *dotView = [[TLCalendarDotView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
            dotView.dotColor = [UIColor colorWithCGColor:event.calendar.CGColor];
            dotView.center = CGPointMake(CGRectGetMinX(allDayLabel.frame) - 10, allDayLabel.center.y);
            [view addSubview:dotView];
            
            [mutableArray addObject:view];
            [self.allDayEventScrollView addSubview:view];
        }
        
        self.allDayEventViews = [NSArray arrayWithArray:mutableArray];
    }];
    
    // Update our header labels with the next event whenever it changes.
    EKEventManager *eventManager = [EKEventManager sharedInstance];
    
    RACSignal *nextEventSignal = [[RACSignal combineLatest:@[eventManager.eventsSignal, eventManager.nextEventSignal, timerSignal] reduce:^id (NSArray *eventArray, EKEvent *nextEvent, NSDate *fireDate){
        NSArray *filteredArray = [[eventArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (EKEvent *event, NSDictionary *bindings) {
            return [event.endDate isLaterThanDate:[NSDate date]] && !event.isAllDay;
        }]] sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2) {
            return [[obj1 startDate] compare:[obj2 startDate]];
        }];
        
        if (filteredArray.count == 0) {
            if (nextEvent.isAllDay) {
                return  nil;
            }
            else {
                return nextEvent;
            }
        } else {
            return filteredArray[0];
        }
    }] throttle:0.25f];
    
    RAC(self.eventTitleLabel, text) = [nextEventSignal map:^id(EKEvent *event) {
        return event == nil ? NSLocalizedString(@"No Upcoming Event", @"No upcoming event header text") : event.title;
    }];
    
    RAC(self.eventLocationLabel, text) = [nextEventSignal map:^id(EKEvent *event) {
        return event == nil ? @"" : event.location;
    }];
    
    RAC(self.eventLocationImageView, alpha) = [nextEventSignal map:^id(EKEvent *event) {
        return event.location.length == 0 ? @(0.0f) : @(1.0f);
    }];
    
    RAC(self.eventTimeLabel, text) = [nextEventSignal map:^id(EKEvent *event) {
        if (!event) return @"";
        
        return [[NSString stringWithFormat:@"%@ – %@",
                 [NSDateFormatter localizedStringFromDate:event.startDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle],
                 [NSDateFormatter localizedStringFromDate:event.endDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]] lowercaseString];
    }];
    
    id (^transformBlock)(id) = ^id(EKEvent *event) {
        if (event.location.length > 0) {
            return [NSValue valueWithCGAffineTransform:CGAffineTransformIdentity];
        }
        else {
            return [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(0, -24)];
        }
    };
    
    RAC(self.eventRelativeTimeLabel, text) = [nextEventSignal map:^id(EKEvent *event) {
        if (!event) return @"";
        
        NSCalendar *calendar = [[EKEventManager sharedInstance] calendar];
        
        unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *startTimeComponents = [calendar components:unitFlags fromDate:[NSDate date] toDate:event.startDate options:0];
        
        NSString *eventRelativeTime = @"";
        
        if (startTimeComponents.minute < 0) {
            eventRelativeTime = @"";
        }
        // Check for descending unit lengths being greater than zero for the largest, non-zero component.
        else if (startTimeComponents.month > 0) {
            NSInteger numberOfMonths = startTimeComponents.month;
            
            if (startTimeComponents.day > 15) {
                numberOfMonths++;
            }
            
            eventRelativeTime = [NSString stringWithFormat:@"%d", numberOfMonths];
        } else if (startTimeComponents.day > 0) {
            eventRelativeTime = [NSString stringWithFormat:@"%d", startTimeComponents.day];
        } else if (startTimeComponents.hour > 0 && !(startTimeComponents.hour == 1 && startTimeComponents.minute < 30)) {
            NSInteger numberOfHours = startTimeComponents.hour;
            
            if (startTimeComponents.minute > 30) {
                numberOfHours++;
            }
            
            eventRelativeTime = [NSString stringWithFormat:@"%d", numberOfHours];
        } else {
            NSInteger numberOfMinutes = [event.startDate
                                         minutesAfterDate:[NSDate date]];
            
            eventRelativeTime = [NSString stringWithFormat:@"%d", numberOfMinutes];
        }
        
        return eventRelativeTime;
    }];
    
    RAC(self.eventRelativeTimeUnitLabel, text) = [nextEventSignal map:^id(EKEvent *event) {
        if (event == nil) return @"";
        
        NSCalendar *calendar = [[EKEventManager sharedInstance] calendar];
        
        unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *startTimeComponents = [calendar components:unitFlags fromDate:[NSDate date] toDate:event.startDate options:0];
        
        NSString *eventRelativeTimeUnit = @"";
        
        // Check for descending unit lengths being greater than zero for the largest, non-zero component.
        if (startTimeComponents.month > 0) {
            NSInteger numberOfMonths = startTimeComponents.month;
            
            if (startTimeComponents.day > 15) {
                numberOfMonths++;
            }
            
            if (numberOfMonths == 1) {
                eventRelativeTimeUnit = NSLocalizedString(@"MONTH", @"Month unit singular");
            } else {
                eventRelativeTimeUnit = NSLocalizedString(@"MONTHS", @"Month unit plural");
            }
        } else if (startTimeComponents.day > 0) {
            
            if (startTimeComponents.day == 1) {
                eventRelativeTimeUnit = NSLocalizedString(@"DAY", @"Day unit singular");
            } else {
                eventRelativeTimeUnit = NSLocalizedString(@"DAYS", @"Day unit plural");
            }
        } else if (startTimeComponents.hour > 0 && !(startTimeComponents.hour == 1 && startTimeComponents.minute < 30)) {
            NSInteger numberOfHours = startTimeComponents.hour;
            
            if (startTimeComponents.minute > 30) {
                numberOfHours++;
            }
            
            if (numberOfHours == 1) {
                eventRelativeTimeUnit = NSLocalizedString(@"HOUR", @"Hour unit singular");
            } else {
                eventRelativeTimeUnit = NSLocalizedString(@"HOURS", @"Hour unit plural");
            }
        } else {
            NSInteger numberOfMinutes = [event.startDate minutesAfterDate:[NSDate date]];
            
            if (numberOfMinutes == 1) {
                eventRelativeTimeUnit = NSLocalizedString(@"MIN", @"Minute unit singular");
            } else {
                eventRelativeTimeUnit = NSLocalizedString(@"MINS", @"Minute unit plural");
            }
        }

        return eventRelativeTimeUnit;
    }];
    
    RAC(self.calendarView, alpha) = [nextEventSignal map:^id(EKEvent *event) {
        return event == nil ? @(0.0f) : @(1.0f);
    }];
    
    RAC(self.calendarView, dotColor) = [nextEventSignal map:^id(EKEvent *event) {
        return [UIColor colorWithCGColor:event.calendar.CGColor];
    }];
    
    RACSignal *eventNowHiddenSignal = [nextEventSignal map:^id(EKEvent *event) {
        if (event == nil) return @(YES);
        
        NSCalendar *calendar = [[EKEventManager sharedInstance] calendar];
        
        unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *startTimeComponents = [calendar components:unitFlags fromDate:[NSDate date] toDate:event.startDate options:0];
        
        if (startTimeComponents.minute < 0) {
            return @(NO);
        }
        else {
            return @(YES);
        }
    }];
    
    RAC(self.eventNowLabel, hidden) = eventNowHiddenSignal;
    RAC(self.eventRelativeTimeUnitLabel, hidden) = [eventNowHiddenSignal not];
    
    RAC(self.eventTimeLabel, transform) = [nextEventSignal map:transformBlock];
    RAC(self.calendarView, transform) = [nextEventSignal map:transformBlock];
    
    // This subject is sent new items in updateHour:minute:event:
    self.alternateEventSubject = [RACSubject subject];
    
    RAC(self.alternateEventTitleLabel, text) = [self.alternateEventSubject map:^id(EKEvent *event) {
        return event == nil ? @"" : event.title;
    }];
    
    RAC(self.alternateEventLocationLabel, text) = [self.alternateEventSubject map:^id(EKEvent *event) {
        return event.location.length == 0 ? @"" : event.location;
    }];
    
    RAC(self.alternateEventLocationImageView, alpha) = [self.alternateEventSubject map:^id(EKEvent *event) {
        return event.location.length == 0 ? @(0.0f) : @(1.0f);
    }];
    
    RAC(self.alternateEventTimeLabel, text) = [self.alternateEventSubject map:^id(EKEvent *event) {
        if (event == nil) return @"";
        
        return [[NSString stringWithFormat:@"%@ – %@",
                 [NSDateFormatter localizedStringFromDate:event.startDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle],
                 [NSDateFormatter localizedStringFromDate:event.endDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]] lowercaseString];
    }];
    
    RAC(self.alternateCalendarView, alpha) = [self.alternateEventSubject map:^id(EKEvent *event) {
        return event == nil ? @(0.0f) : @(1.0f);
    }];
    
    RAC(self.alternateCalendarView, dotColor) = [self.alternateEventSubject map:^id(EKEvent *event) {
        return [UIColor colorWithCGColor:event.calendar.CGColor];
    }];
    
    RAC(self.alternateEventTimeLabel, transform) = [self.alternateEventSubject map:transformBlock];
    RAC(self.alternateCalendarView, transform) = [self.alternateEventSubject map:transformBlock];
    
    [[self.alternateEventSubject distinctUntilChanged] subscribeNext:^(EKEvent *event) {
        [self.headerAlernateDetailView crossfadeWithDuration:0.1f];
    }];
    
    // Remove the default table view background
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [UIColor clearColor];
    self.calendarTableView.backgroundView = backgroundView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the table view mask
    [self setupTableViewMask];
}

-(void)setupTableViewMask {
    // This method sets up the mask for the view which contains the table view,
    // making it appear to "fade out" as it reaches the bottom.
    
    if (self.tableMaskingView.layer.mask) {
        return;
    }
    
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    EKSource *source = [EKEventManager sharedInstance].sources[section];
    
    return source.title;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 37;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), [self tableView:tableView heightForHeaderInSection:section])];
    
    header.backgroundColor = [UIColor clearColor];
    
    const CGFloat leftMargin = 10.0f;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectOffset(CGRectInset(header.bounds, leftMargin, 0), 0, 5)];
    [label setText:[self tableView:tableView titleForHeaderInSection:section]];
    label.font = [[UIFont tl_mediumAppFont] fontWithSize:16];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    
    [header addSubview:label];
    
    return header;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    EKSource *source = [EKEventManager sharedInstance].sources[section];
    
    return [[source calendarsForEntityType:EKEntityTypeEvent] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[EKEventManager sharedInstance].sources count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    TLCalendarSelectCell *cell = (TLCalendarSelectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[TLCalendarSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EKEventManager *eventManager = [EKEventManager sharedInstance];
    EKSource *source = eventManager.sources[indexPath.section];
    NSArray *calendars = [[source calendarsForEntityType:EKEntityTypeEvent] allObjects];
    EKCalendar *calendar = calendars[indexPath.row];
    
    cell.textLabel.text = calendar.title;
    
    if ([eventManager.selectedCalendars containsObject:calendar.calendarIdentifier]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    } else {
        cell.accessoryView = nil;
    }
    
    cell.dotColor = [UIColor colorWithCGColor:calendar.CGColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EKEventManager *eventManager = [EKEventManager sharedInstance];
    EKSource *source = eventManager.sources[indexPath.section];
    NSArray *calendars = [[source calendarsForEntityType:EKEntityTypeEvent] allObjects];
    EKCalendar *calendar = calendars[indexPath.row];
    
    [eventManager toggleCalendarWithIdentifier:calendar.calendarIdentifier];
}

#pragma mark - Public Methods

-(void)flashScrollBars {
    [self.calendarTableView flashScrollIndicators];
}

-(void)scrollTableViewToTop {
    [self.calendarTableView scrollRectToVisible:CGRectMake(1, 1, 1, 1) animated:NO];
}

/*
 Each of the following two animations is actually made up of four discrete animations.
 First, we pull down by some distange, then pull back up to hide the view completely.
 A delay occurs, then another view falls back down to the pulled-down distance
 then returns to its resting state.
 */

static CGFloat pullDownDistance = 7.0f;

static CGFloat pullDownAnimationDuration = 0.05f;
static CGFloat pullUpAnimationDuration = 0.1f;
static CGFloat fallDownAnimationDuration = 0.1f;
static CGFloat interAnimationDelay = 0.05f;

// Obviously these two methods aren't ideal. However, they work great so there's no
// real point in moving over to a CAKeyFrameAnimation. 

-(void)hideHeaderView {
    [UIView animateWithDuration:pullDownAnimationDuration animations:^{
        self.allDayEventScrollView.transform = CGAffineTransformMakeTranslation(0, pullDownDistance);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:pullUpAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.allDayEventScrollView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.headerDetailView.frame));
        } completion:^(BOOL finished) {
            [self.allDayEventScrollView setContentOffset:CGPointZero];
            self.headerAlernateDetailView.alpha = 1.0f;
            [UIView animateWithDuration:fallDownAnimationDuration delay:interAnimationDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.headerAlernateDetailView.transform = CGAffineTransformMakeTranslation(0, pullDownDistance);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:pullDownAnimationDuration animations:^{
                    self.headerAlernateDetailView.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
    }];
}

-(void)showHeaderView {
    [UIView animateWithDuration:pullDownAnimationDuration animations:^{
        self.headerAlernateDetailView.transform = CGAffineTransformMakeTranslation(0, pullDownDistance);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:pullUpAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.headerAlernateDetailView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.headerDetailView.frame));
        } completion:^(BOOL finished) {
            self.headerAlernateDetailView.alpha = 0.0f;
            [UIView animateWithDuration:fallDownAnimationDuration delay:interAnimationDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.allDayEventScrollView.transform = CGAffineTransformMakeTranslation(0, pullDownDistance);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:pullDownAnimationDuration animations:^{
                    self.allDayEventScrollView.transform = CGAffineTransformIdentity;
                } completion:nil];
            }];
        }];
    }];
}

-(void)updateHour:(NSInteger)hours minute:(NSInteger)minutes event:(TLEventViewModel *)eventViewModel {
    if (eventViewModel.eventSpan == TLEventViewModelEventSpanTooManyWarning) {
        [self.alternateEventSubject sendNext:nil];
    }
    else {
        [self.alternateEventSubject sendNext:eventViewModel.event];
    }
    
    self.alternateAbsoluteTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", hours, minutes];
}

-(void)setArrowRotationRatio:(CGFloat)arrowRotationRatio {
    _arrowRotationRatio = arrowRotationRatio;
    
    self.arrowButton.transform = CGAffineTransformMakeRotation(M_PI * arrowRotationRatio + M_PI);
}

#pragma mark - IBAction Methods

-(IBAction)userDidPressDismissButton {
    [self.delegate userDidTapDismissHeaderButton];
}

-(IBAction)userDidPressTLButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.teehanlax.com/"]];
}

@end
