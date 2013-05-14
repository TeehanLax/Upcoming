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

const CGFloat TLUpcomingEventViewControllerHiddenHeight = 0.0f;
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

@end

@implementation TLUpcomingEventViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundImageView.layer.shadowColor = [[UIColor colorWithWhite:0.0f alpha:1.0f] CGColor];
    self.backgroundImageView.layer.shadowOffset = CGSizeMake(0, 0);
    self.backgroundImageView.layer.shadowOpacity = 0.4f;
    self.backgroundImageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.backgroundImageView.bounds] CGPath];
    self.backgroundImageView.layer.shadowRadius = 22.0f;
    
    // Reload our table view whenever the sources change on the event manager, or every 60 seconds.
    // Throttle the nextEvent so it doesn't go all flashy. 
    RACSignal *newEventsSignal = [[[EKEventManager sharedInstance] nextEventSignal] throttle:0.25f];
    RACSignal *timeSignal = [[[RACSignal interval:60] startWith:[NSDate date]] deliverOn:[RACScheduler mainThreadScheduler]];
    
    
    RACSignal *nextEventSignal = [RACSignal combineLatest:@[timeSignal, newEventsSignal]
                      reduce:^id(NSDate *now, EKEvent *nextEvent){
                          return nextEvent;
                      }];
    RAC(self.eventNameLabel.text) = [nextEventSignal map:^id(EKEvent *event) {
        return event == nil ? NSLocalizedString(@"No upcoming event", @"Empty upcoming event message") : event.title;
    }];
    
    RAC(self.eventLocationLabel.text) = [nextEventSignal map:^id(EKEvent *event) {
        return event.location.length == 0 ? @"" : event.location;
    }];
    
    RAC(self.eventLocationImageView.alpha) = [nextEventSignal map:^id(EKEvent *event) {
        return event.location.length == 0 ? @(0.0f) : @(1.0f);
    }];
    
    RAC(self.eventTimeLabel.text) = [nextEventSignal map:^id(EKEvent *event) {
        if (!event) return @"";
        NSDate *startDate = event.startDate;
        NSDate *endDate = event.endDate;
        BOOL isAllDayEvent = event.isAllDay;
        
        // Next, transform that data into the information we need to display to the user
        NSCalendar *calendar = [[EKEventManager sharedInstance] calendar];
        
        NSString *timeString;
        NSString *dateString;
        
        if (isAllDayEvent) {
            timeString = NSLocalizedString(@"All Day", @"All day date string");
        } else {
            NSDateComponents *differenceComponents = [calendar components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
            
            NSString *startDateString = [[NSDateFormatter localizedStringFromDate:startDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle] lowercaseString];
            
            if (differenceComponents.day > 0) {
                // This event spans multiple days.
                
                timeString = [NSString stringWithFormat:@"%@ – %@",
                              startDateString,
                              [NSDateFormatter localizedStringFromDate:endDate
                                                             dateStyle:NSDateFormatterShortStyle
                                                             timeStyle:NSDateFormatterNoStyle]];
            } else {
                timeString = [[NSString stringWithFormat:@"%@ – %@",
                               startDateString,
                               [NSDateFormatter localizedStringFromDate:endDate
                                                              dateStyle:NSDateFormatterNoStyle
                                                              timeStyle:NSDateFormatterShortStyle]] lowercaseString];
            }
        }
        
        if ([startDate isToday]) {
            // This shouldn't really happen, but we'll check just in case
            dateString = NSLocalizedString(@"Today", @"Today time string");
        } else if ([startDate isTomorrow]) {
            dateString = NSLocalizedString(@"Tomorrow", @"Tomorrow time string");
        } else if ([startDate daysAfterDate:[NSDate date]] < 7) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale currentLocale];
            dateFormatter.dateFormat = @"EEEE";
            dateString = [dateFormatter stringFromDate:event.startDate];
        } else {
            dateString = [NSDateFormatter localizedStringFromDate:startDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        }
        
        return [NSString stringWithFormat:@"%@, %@", dateString, timeString];
    }];
    
    RAC(self.eventRelativeTimeLabel.text) = [nextEventSignal map:^id(EKEvent *event) {
        if (!event) return @"";
        NSDate *startDate = event.startDate;        
        
        // Next, transform that data into the information we need to display to the user
        NSCalendar *calendar = [[EKEventManager sharedInstance] calendar];
        
        unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *startTimeComponents = [calendar components:unitFlags fromDate:[NSDate date] toDate:startDate options:0];
        
        NSString *eventRelativeTime = @"";
        
        // Check for descending unit lengths being greater than zero for the largest, non-zero component.
        if (startTimeComponents.month > 0) {
            NSInteger numberOfMonths = startTimeComponents.month;
            
            if (startTimeComponents.day > 15) {
                numberOfMonths++;
            }
            
            eventRelativeTime = [NSString stringWithFormat:@"%d", numberOfMonths];
            
        } else if (startTimeComponents.day > 0) {
            NSInteger numberOfDays = [[NSDate date] daysBeforeDate:event.startDate];
            
            eventRelativeTime = [NSString stringWithFormat:@"%d", numberOfDays];
            
        } else if (startTimeComponents.hour > 0) {
            NSInteger numberOfHours = startTimeComponents.hour;
            
            if (startTimeComponents.minute > 30) {
                numberOfHours++;
            }
            
            eventRelativeTime = [NSString stringWithFormat:@"%d", numberOfHours];
            
        } else if (startTimeComponents.minute > 0) {
            eventRelativeTime = [NSString stringWithFormat:@"%d", startTimeComponents.minute];
        }
        
        return eventRelativeTime;
    }];
    
    RAC(self.eventRelativeTimeUnitLabel.text) = [nextEventSignal map:^id(EKEvent *event) {
        if (!event) return @"";
        NSDate *startDate = event.startDate;        
        
        // Next, transform that data into the information we need to display to the user
        NSCalendar *calendar = [[EKEventManager sharedInstance] calendar];
        
        unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *startTimeComponents = [calendar components:unitFlags fromDate:[NSDate date] toDate:startDate options:0];
        
        NSString *eventRelativeTimeUnit = @"";
        
        // Check for descending unit lengths being greater than zero for the largest, non-zero component.
        if (startTimeComponents.month > 0) {
            NSInteger numberOfMonths = startTimeComponents.month;
            
            if (startTimeComponents.day > 15) {
                numberOfMonths++;
            }
                        
            if (numberOfMonths == 1) {
                eventRelativeTimeUnit = NSLocalizedString(@"Month", @"Month unit singular");
            } else {
                eventRelativeTimeUnit = NSLocalizedString(@"Months", @"Month unit plural");
            }
        } else if (startTimeComponents.day > 0) {
            NSInteger numberOfDays = [[NSDate date] daysBeforeDate:event.startDate];
            
            if (numberOfDays == 1) {
                eventRelativeTimeUnit = NSLocalizedString(@"DAY", @"Day unit singular");
            } else {
                eventRelativeTimeUnit = NSLocalizedString(@"DAYS", @"Day unit plural");
            }
        } else if (startTimeComponents.hour > 0) {
            NSInteger numberOfHours = startTimeComponents.hour;
            
            if (startTimeComponents.minute > 30) {
                numberOfHours++;
            }
            
            if (numberOfHours == 1) {
                eventRelativeTimeUnit = NSLocalizedString(@"HOUR", @"Hour unit singular");
            } else {
                eventRelativeTimeUnit = NSLocalizedString(@"HOURS", @"Hour unit plural");
            }
        } else if (startTimeComponents.minute > 0) {
            
            if (startTimeComponents.minute == 1) {
                eventRelativeTimeUnit = NSLocalizedString(@"MINUTE", @"Minute unit singular");
            } else {
                eventRelativeTimeUnit = NSLocalizedString(@"MINUTES", @"Minute unit plural");
            }
        }
        
        return eventRelativeTimeUnit;
        
    }];
    
    RAC(self.calendarView.alpha) = [nextEventSignal map:^id(id value) {
        return value == nil ? @(0.0f) : @(1.0f);
    }];
    
    RAC(self.calendarView.dotColor) = [nextEventSignal map:^id(EKEvent *event) {
        return [UIColor colorWithCGColor:event.calendar.CGColor];
    }];    
}

@end
