//
//  TLUpcomgingEventViewController.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLUpcomingEventViewController.h"
#import "EKEventManager.h"
#import "TLCalendarDotView.h"

const CGFloat TLUpcomingEventViewControllerHiddenHeight = 5.0f;
const CGFloat TLUpcomingEventViewControllerTotalHeight = 82.0f;

@interface TLUpcomingEventViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *eventNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventLocationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *eventLocationImageView;
@property (nonatomic, weak) IBOutlet TLCalendarDotView *calendarView;
@property (nonatomic, weak) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventRelativeTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventRelativeTimeUnitLabel;

@property (nonatomic, strong) RACSubject *nextEventSubject;

@end

@implementation TLUpcomingEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.layer.shadowColor = [[UIColor colorWithWhite:0.0f alpha:1.0f] CGColor];
    self.backgroundImageView.layer.shadowOffset = CGSizeMake(0, 0);
    self.backgroundImageView.layer.shadowOpacity = 0.4f;
    self.backgroundImageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.backgroundImageView.bounds] CGPath];
    self.backgroundImageView.layer.shadowRadius = 22.0f;
        
    // Reload our table view whenever the sources change on the event manager
    @weakify(self);
    [[RACAble([EKEventManager sharedInstance], nextEvent) deliverOn:[RACScheduler mainThreadScheduler]]  subscribeNext:^(EKEvent *event) {
        @strongify(self);
        [self.nextEventSubject sendNext:event];
    }];
    
    // Update the data once per minute
    [[[[RACSignal interval:60] map:^id(id value) {
        return [[EKEventManager sharedInstance] nextEvent];
    }] deliverOn:[RACScheduler mainThreadScheduler] ] subscribeNext:^(EKEvent *event) {
        @strongify(self);
        [self.nextEventSubject sendNext:event];
    }];
    
    self.nextEventSubject = [RACSubject subject];
    [self.nextEventSubject subscribeNext:^(EKEvent *event) {
        @strongify(self);
        if (event == nil)
        {
            self.eventNameLabel.text = NSLocalizedString(@"No upcoming event", @"Empty upcoming event message");
            self.eventLocationLabel.text = @"";
            self.eventTimeLabel.text = @"";
            self.eventRelativeTimeLabel.text = @"";
            self.eventRelativeTimeUnitLabel.text = @"";
            self.eventLocationImageView.alpha = 0.0f;
            self.calendarView.alpha = 0.0f;
        }
        else
        {
            [self reloadData:event];
        }
    }];
    
    [self.nextEventSubject sendNext:[[EKEventManager sharedInstance] nextEvent]];
}
-(void)reloadData:(EKEvent *)event
{    
    // First, extract relevent data out of the event
    NSString *title = event.title;
    NSString *location = event.location;
    BOOL isAllDayEvent = event.isAllDay;
    NSDate *startDate = event.startDate;
    NSDate *endDate = event.endDate;
    
    // Next, transform that data into the information we need to display to the user
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *startTimeComponents = [calendar components:unitFlags fromDate:[NSDate date] toDate:startDate options:0];
    
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
        NSInteger numberOfDays = [[NSDate date] daysBeforeDate:event.startDate];
                
        self.eventRelativeTimeLabel.text = [NSString stringWithFormat:@"%d", numberOfDays];
        
        if (numberOfDays == 1)
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
    
    NSString *timeString;
    NSString *dateString;
    if (isAllDayEvent)
    {
        timeString = NSLocalizedString(@"All Day", @"All day date string");
    }
    else
    {
        NSDateComponents *differenceComponents = [calendar components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
        
        NSString *startDateString = [NSDateFormatter localizedStringFromDate:startDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        
        if (differenceComponents.day > 0)
        {
            // This event spans multiple days.
            
            timeString = [NSString stringWithFormat:@"%@ – %@",
                          startDateString,
                          [NSDateFormatter localizedStringFromDate:endDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%@ – %@",
                          startDateString,
                          [NSDateFormatter localizedStringFromDate:endDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
        }
    }
    
    if ([startDate isToday])
    {
        // This shouldn't really happen, but we'll check just in case
        dateString = NSLocalizedString(@"Today", @"Today time string");
    }
    else if ([startDate isTomorrow])
    {
        dateString = NSLocalizedString(@"Tomorrow", @"Tomorrow time string");
    }
    else if ([startDate daysAfterDate:[NSDate date]] < 7)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.dateFormat = @"EEEE";
        dateString = [dateFormatter stringFromDate:event.startDate];
    }
    else
    {
        dateString = [NSDateFormatter localizedStringFromDate:startDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    }
    
    self.eventTimeLabel.text = [NSString stringWithFormat:@"%@, %@", dateString, timeString];
    
    self.eventNameLabel.text = title;
    self.eventLocationLabel.text = location;
    if ([location length] > 0)
    {
        self.eventLocationImageView.alpha = 1.0f;
    }
    else
    {
        self.eventLocationImageView.alpha = 0.0f;
    }
    
    self.calendarView.alpha = 1.0f;
    self.calendarView.dotColor = [UIColor colorWithCGColor:event.calendar.CGColor];
}

@end
