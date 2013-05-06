//
//  ECViewController.m
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-17.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLEventViewController.h"
#import "TLBackgroundGradientView.h"
#import "EKEventManager.h"
#import "TLEventViewCell.h"
#import "TLAppDelegate.h"
#import "TLRootViewController.h"
#import "TLHourSupplementaryView.h"

#define NUMBER_OF_ROWS 24
#define EXPANDED_ROWS 4
#define MAX_ROW_HEIGHT 38.f

static NSString *kCellIdentifier = @"Cell";
static NSString *kSupplementaryViewIdentifier = @"HourView";

@interface TLEventViewController ()

@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) BOOL touch;
@property (nonatomic, strong) TLBackgroundGradientView *backgroundGradientView;
@property (nonatomic, strong) NSMutableSet *activeCells;

@property (nonatomic, strong) NSIndexPath *indexPathUnderFinger;
@property (nonatomic, strong) EKEvent *eventUnderFinger;

// Not completely OK to keep this around, but we can guarantee we only ever want one on screen, so it's OK. 
@property (nonatomic, strong) TLHourSupplementaryView *supplementaryView;

@end

@implementation TLEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    EKEventManager *eventManager = [EKEventManager sharedInstance];
    [eventManager addObserver:self forKeyPath:EKEventManagerEventsKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
    self.touch = NO;
    
    self.activeCells = [[NSMutableSet alloc] initWithCapacity:0];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TLEventViewCell" bundle:nil] forCellWithReuseIdentifier:kCellIdentifier];
    [self.collectionView registerClass:[TLHourSupplementaryView class] forSupplementaryViewOfKind:[TLHourSupplementaryView kind] withReuseIdentifier:kSupplementaryViewIdentifier];
    
    self.touchDown = [[TLTouchDownGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownHandler:)];
    self.touchDown.cancelsTouchesInView = NO;
    self.touchDown.delaysTouchesBegan = NO;
    self.touchDown.delaysTouchesEnded = NO;
    [self.collectionView addGestureRecognizer:self.touchDown];
    
    @weakify(self);
    [[[RACSignal interval:60.0f] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self updateBackgroundGradient];
    }];
        
    self.backgroundGradientView = [[TLBackgroundGradientView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.backgroundGradientView atIndex:0];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.collectionView reloadData];
    [self updateBackgroundGradient];
}

- (void)viewWillAppear:(BOOL)animated {
    TLCollectionViewLayout *layout = [[TLCollectionViewLayout alloc] init];
    
    [self.collectionView setCollectionViewLayout:layout animated:animated];
}

- (void)touchDownHandler:(TLTouchDownGestureRecognizer *)recognizer {
    self.location = [recognizer locationInView:recognizer.view];
    
    EKEvent *event = [self eventUnderPoint:self.location];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:self.location];    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    NSInteger hour = indexPath.row;
    NSInteger minute = ((self.location.y - attributes.frame.origin.y) / attributes.size.height) * 60;
    
    // Convert from 24-hour format
    if (hour > 12) hour -= 12;
    if (hour == 0) hour += 12;
    if (minute < 0) minute = 0; // Weird rounding error
    
    
    [self.collectionView performBatchUpdates:^{
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [self.backgroundGradientView setDarkened:YES];
            self.eventUnderFinger = nil;
            self.indexPathUnderFinger = indexPath;
            self.touch = YES;
            [self.delegate userDidBeginInteractingWithDayListViewController:self];
            if (CGRectContainsPoint(recognizer.view.bounds, self.location)) {
                [AppDelegate playTouchDownSound];
                [self.delegate userDidInteractWithDayListView:self updateTimeHour:hour minute:minute event:event];
            }
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            if ([self.eventUnderFinger compareStartDateWithEvent:event] != NSOrderedSame ||
                (self.eventUnderFinger == nil && event != nil) ||
                (self.eventUnderFinger != nil && event == nil))
            {
                [AppDelegate playTouchNewEventSound];
                self.eventUnderFinger = event;
            }
            else
            {
                if ([indexPath compare:self.indexPathUnderFinger] != NSOrderedSame)
                {
                    [AppDelegate playTouchNewHourSound];
                    self.indexPathUnderFinger = indexPath;
                }
            }
            
            if (CGRectContainsPoint(recognizer.view.bounds, self.location)) {
                [self.delegate userDidInteractWithDayListView:self updateTimeHour:hour minute:minute event:event];
            }
        } else if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self.backgroundGradientView setDarkened:NO];
            self.eventUnderFinger = nil;
            self.indexPathUnderFinger = nil;
            self.touch = NO;
            [self.delegate userDidEndInteractingWithDayListViewController:self];
            [AppDelegate playTouchUpSound];
        }
    } completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:EKEventManagerEventsKeyPath]) {
        NSLog(@"GOT %d EVENTS", [[EKEventManager sharedInstance].events count]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView performBatchUpdates:nil completion:nil];
        });
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TLEventViewCell *cell = (TLEventViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (!self.touch) {
        // default size
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (![self.activeCells containsObject:[NSNumber numberWithInt:indexPath.row]]) {
                cell.contentView.alpha = 0;
            }
            cell.titleLabel.alpha = 0;
        } completion:nil];
        return CGSizeMake(320, collectionView.frame.size.height / NUMBER_OF_ROWS);
    }
    
    CGFloat minSize = (collectionView.frame.size.height - (MAX_ROW_HEIGHT * EXPANDED_ROWS)) / 20;
    
    CGFloat dayLocation = (self.location.y / self.collectionView.frame.size.height) * 24;
    
    CGFloat diff = dayLocation - (float)indexPath.row;
    
    // prevent reducing size of min / max rows
    if (indexPath.row < EXPANDED_ROWS) {
        if (diff < 0) diff = 0;
    } else if (indexPath.row > NUMBER_OF_ROWS - EXPANDED_ROWS - 1) {
        if (diff > 0) diff = 0;
    }
    
    CGFloat size = (minSize + MAX_ROW_HEIGHT) * ((EXPANDED_ROWS - fabsf(diff)) / EXPANDED_ROWS);
    
    if (![self.activeCells containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        cell.contentView.alpha = (EXPANDED_ROWS - fabsf(diff)) / EXPANDED_ROWS;
    }
    cell.titleLabel.alpha = (EXPANDED_ROWS - fabsf(diff)) / EXPANDED_ROWS;
    
    if (size > MAX_ROW_HEIGHT) size = MAX_ROW_HEIGHT;
    if (size < minSize) size = minSize;
    
    return CGSizeMake(320, size);
}

-(CGRect)collectionView:(UICollectionView *)collectionView frameForHourViewInLayout:(TLCollectionViewLayout *)layout {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSHourCalendarUnit fromDate:[NSDate date]];
    
    NSInteger currentHour = components.hour;
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:currentHour inSection:0]];
    
    CGFloat viewHeight = attributes.size.height;
       
    return CGRectMake(0, attributes.frame.origin.y, CGRectGetWidth(self.view.bounds), viewHeight);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView heightForHourLineViewInLayout:(TLCollectionViewLayout *)layout
{
    if (self.touch)
    {
        return 2.0f;
    }
    else
    {
        return 1.0f;
    }
}

-(CGFloat)collectionView:(UICollectionView *)collectionView hourProgressionForHourLineViewInLayout:(TLCollectionViewLayout *)layout{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSMinuteCalendarUnit fromDate:[NSDate date]];
    
    NSInteger currentMinute = components.minute;
    
    return (float)currentMinute / 60.0f;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NUMBER_OF_ROWS;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TLEventViewCell *cell = (TLEventViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.contentView.alpha = 0;
    
    for (EKEvent *event in [EKEventManager sharedInstance].events) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:event.startDate];
        NSInteger hour = [components hour];
        if (hour == indexPath.row) {
            [self.activeCells addObject:[NSNumber numberWithInt:indexPath.row]];
            cell.contentView.alpha = 1;
            cell.titleLabel.text = event.title;
        }
    }
    [cell setNeedsDisplay];
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    // We only ever have one supplementary view. 
    if (!self.supplementaryView)
    {
        self.supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSupplementaryViewIdentifier forIndexPath:indexPath];
        
        RACSubject *updateSubject = [RACSubject subject];
                
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSSecondCalendarUnit fromDate:[NSDate date]];
        
        NSInteger delay = 60 - components.second;
        
        NSLog(@"Scheduling subscription every minute for supplementary view in %d seconds", delay);
        
        double delayInSeconds = delay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            NSLog(@"Creating initial subscription for supplementary view.");
            [updateSubject sendNext:[NSDate date]];
            
            [[RACSignal interval:60] subscribeNext:^(id x) {
                NSLog(@"Updating minute of supplementary view.");
                [updateSubject sendNext:x];
            }];
        });
        
        RAC(self.supplementaryView.timeString) = [updateSubject map:^id(NSDate *date) {
            
            NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
            
            NSInteger hours = components.hour % 12;
            if (hours == 0) hours = 12;
            
            return [NSString stringWithFormat:@"%d:%02d", hours, components.minute];
        }];
        
        [updateSubject sendNext:[NSDate date]];
    }
    
    return self.supplementaryView;
}

#pragma mark - Private Methods
-(void)updateBackgroundGradient
{
    NSArray *events = [[EKEventManager sharedInstance] events];
    
    CGFloat soonestEvent = NSIntegerMax;
    for (EKEvent *event in events)
    {
        if (!event.isAllDay)
        {
            if ([event.startDate isEarlierThanDate:[NSDate date]] && ![event.endDate isEarlierThanDate:[NSDate date]])
            {
                // There's an event going on NOW.
                soonestEvent = 0;
            }
            else if (![event.startDate isEarlierThanDate:[NSDate date]])
            {
                NSTimeInterval interval = [event.startDate timeIntervalSinceNow];
                NSInteger numberOfMinutes = interval / 60;
                
                soonestEvent = MIN(soonestEvent, numberOfMinutes);
            }
        }
    }
    
    const CGFloat fadeTime = 30.0f;
    
    if (soonestEvent == 0)
    {
        [self.backgroundGradientView setAlertRatio:1.0f animated:YES];
    }
    else if (soonestEvent > fadeTime)
    {
        [self.backgroundGradientView setAlertRatio:0.0f animated:YES];
    }
    else
    {
        CGFloat ratio = (fadeTime - soonestEvent) / fadeTime;
        
        [self.backgroundGradientView setAlertRatio:ratio animated:YES];
    }
    
    // save copy of gradient as image
    TLAppDelegate *appDelegate = (TLAppDelegate *)[UIApplication sharedApplication].delegate;
    TLRootViewController *rootViewController = appDelegate.viewController;
    UIGraphicsBeginImageContext(self.backgroundGradientView.bounds.size);
    [self.backgroundGradientView.layer renderInContext:UIGraphicsGetCurrentContext()];
    rootViewController.gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(EKEvent *)eventUnderPoint:(CGPoint)point
{
    EKEvent *eventUnderTouch;
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    if ([self.activeCells containsObject:@(indexPath.row)])
    {
        for (EKEvent *event in [EKEventManager sharedInstance].events) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:event.startDate];
            NSInteger hour = [components hour];
            if (hour == indexPath.row) {
                eventUnderTouch = event;
            }
        }
    }
    
    return eventUnderTouch;
}

@end
