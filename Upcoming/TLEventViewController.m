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
#import "TLHourCell.h"
#import "TLAppDelegate.h"
#import "TLRootViewController.h"
#import "TLHourLineSupplementaryView.h"
#import "TLEventSupplementaryView.h"
#import "TLEventViewModel.h"

// Collection View reusable views' identifiers
static NSString *kCellIdentifier = @"Cell";
static NSString *kHourSupplementaryViewIdentifier = @"HourView";
static NSString *kEventSupplementaryViewIdentifier = @"EventView";

@interface TLEventViewController ()

// Latest updated location under finder.
@property (nonatomic, assign) CGPoint location;
// Latest hour cell index path under user's finger.
@property (nonatomic, strong) NSIndexPath *indexPathUnderFinger;
// Latest event under finger (used to play "new event" sound).
@property (nonatomic, strong) TLEventViewModel *eventViewModelUnderFinger;

// Background gradient view for self.view (*not* the collection view's backgroundView).
@property (nonatomic, strong) TLBackgroundGradientView *backgroundGradientView;
// View model currently being displayed *as supplementary views* by the collection view. 
@property (nonatomic, strong) NSArray *viewModelArray;

// Not completely OK to keep this around, but we can guarantee we only ever want one on screen, so it's OK.
@property (nonatomic, strong) TLHourLineSupplementaryView *hourSupplementaryView;

@property (nonatomic, strong) NSDateComponents *currentDateComponents;

@end

// This collection view displays *hours* as cells – the events themselves are supplementary views.
// Which kind of makes sense, since events are kind of like metadata about a day. Neat. 
@implementation TLEventViewController

#pragma mark - View Lifecycle Methods

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    
    RAC(self.currentDateComponents) = [[[RACSignal interval:60] startWith:[NSDate date]] map:^id(id value) {
        return [[[EKEventManager sharedInstance] calendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    }];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
        
    EKEventManager *eventManager = [EKEventManager sharedInstance];
    
    // Wrap our eventManager events property as a RACSignal so we can react to changes.
    RACSignal *newEventsSignal = [RACAbleWithStart(eventManager, events) deliverOn:[RACScheduler mainThreadScheduler]];
    
    @weakify(self);
    // Bind our viewModelArray to a mapped newEventSignal
    RAC(self.viewModelArray) = [[[newEventsSignal distinctUntilChanged] map:^id (NSArray *eventsArray) {
        // First, sort the array first by size then by start time.
        
        NSArray *sortedArray = [eventsArray sortedArrayUsingComparator:^NSComparisonResult (EKEvent *obj1, EKEvent *obj2) {
            NSTimeInterval interval1 = [obj1.endDate
                                        timeIntervalSinceDate:obj1.startDate];
            NSTimeInterval interval2 = [obj2.endDate
                                        timeIntervalSinceDate:obj2.startDate];
            
            if (interval1 > interval2) {
                return NSOrderedAscending;
            } else if (interval1 < interval2) {
                return NSOrderedDescending;
            } else {
                if ([obj1.startDate
                     isEarlierThanDate:obj2.startDate]) {
                    return NSOrderedAscending;
                } else if ([obj1.startDate
                            isLaterThanDate:obj2.startDate]) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        
        return sortedArray;
    }] map:^id (NSArray *sortedEventArray) {
        // Then, create an array of TLEventViewModel objects based on that array.
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:sortedEventArray.count];
        
        for (EKEvent * event in sortedEventArray) {
            // Exclude all-day events
            if (event.isAllDay) {
                continue;
            }
            
            // Create our view model.
            TLEventViewModel *viewModel = [TLEventViewModel new];
            viewModel.event = event;
            viewModel.eventSpan = TLEventViewModelEventSpanFull;
            
            // Now determine if we're overlapping an existing event.
            // Note: this isn't that efficient, but our data sets are small enough to warrant an n^2 algorithm.
            for (TLEventViewModel * otherModel in mutableArray) {
                BOOL overlaps = [viewModel overlapsWith:otherModel];
                
                if (overlaps) {
                    if (otherModel.eventSpan == TLEventViewModelEventSpanTooManyWarning) {
                        otherModel.extraEventsCount++;
                        viewModel = nil;
                    } else if (otherModel.eventSpan == TLEventViewModelEventSpanRight) {
                        // Now we need to determine if the viewModel can float to the left.
                        // Assume no conflicts until we find one. 
                        BOOL conflicts = NO;
                        
                        for (TLEventViewModel * possiblyConflictingModel in mutableArray) {
                            // Ignore this model – we already know it overlaps
                            if (possiblyConflictingModel == otherModel) {
                                continue;
                            }
                            
                            if (possiblyConflictingModel.eventSpan != TLEventViewModelEventSpanLeft) {
                                continue;
                            }
                            
                            if ([possiblyConflictingModel overlapsWith:viewModel]) {
                                conflicts = YES;
                                break;
                            }
                        }
                        
                        if (conflicts) {
                            otherModel.eventSpan = TLEventViewModelEventSpanTooManyWarning;
                            otherModel.extraEventsCount = 2;
                            viewModel = nil;
                        } else {
                            viewModel.eventSpan = TLEventViewModelEventSpanLeft;
                        }
                    } else if (otherModel.eventSpan == TLEventViewModelEventSpanLeft) {
                        viewModel.eventSpan = TLEventViewModelEventSpanRight;
                    } else if (otherModel.eventSpan == TLEventViewModelEventSpanFull) {
                        otherModel.eventSpan = TLEventViewModelEventSpanLeft;
                        viewModel.eventSpan = TLEventViewModelEventSpanRight;
                    }
                }
            }
            
            if (viewModel) {
                [mutableArray addObject:viewModel];
            }
        }
        
        NSLog(@"Constructed array of %d events. ", mutableArray.count);
        
        return mutableArray;
    }];
    
    // Whenever our viewModelArray changes, reload our data and invalidate the layout. 
    [RACAble(self.viewModelArray) subscribeNext:^(id x) {
        [self.collectionView reloadData];
        [self.collectionView.collectionViewLayout invalidateLayout];
    }];
    
    // Register our reusable views for the collection view
    [self.collectionView registerNib:[UINib nibWithNibName:@"TLHourCell" bundle:nil] forCellWithReuseIdentifier:kCellIdentifier];
    [self.collectionView registerClass:[TLEventSupplementaryView class] forSupplementaryViewOfKind:[TLEventSupplementaryView kind] withReuseIdentifier:kEventSupplementaryViewIdentifier];
    [self.collectionView registerClass:[TLHourLineSupplementaryView class] forSupplementaryViewOfKind:[TLHourLineSupplementaryView kind] withReuseIdentifier:kHourSupplementaryViewIdentifier];
    
    // Create our gesture recognizer. 
    self.touchDown = [[TLTouchDownGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownHandler:)];
    self.touchDown.cancelsTouchesInView = NO;
    self.touchDown.delaysTouchesBegan = NO;
    self.touchDown.delaysTouchesEnded = NO;
    [self.collectionView addGestureRecognizer:self.touchDown];
    
    // Updat eour background gradient every minute. 
    [[[RACSignal interval:60.0f] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self updateBackgroundGradient];
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.collectionView reloadData];
    [self updateBackgroundGradient];
}

-(void)viewWillAppear:(BOOL)animated {
    TLCollectionViewLayout *layout = [[TLCollectionViewLayout alloc] init];
    
    [self.collectionView setCollectionViewLayout:layout animated:animated];
    
    // We need to insert our background gradient here since we can't rely on self.view's
    // geometry in viewDidLoad and the background gradient view doesn't resize well, so
    // autoresizing won't work easily. 
    if (!self.backgroundGradientView) {
        self.backgroundGradientView = [[TLBackgroundGradientView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:self.backgroundGradientView atIndex:0];
    }
}

#pragma mark - Gesture Recognizer Methods

-(void)touchDownHandler:(TLTouchDownGestureRecognizer *)recognizer {
    self.location = [recognizer locationInView:recognizer.view];
    
    if (self.location.y < 0) {
        self.location = CGPointMake(self.location.x, 0);
    }
    
    TLEventViewModel *eventViewModel = [self eventViewModelUnderPoint:self.location];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:self.location];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    NSInteger hour = indexPath.item;
    NSInteger minute = ((self.location.y - attributes.frame.origin.y) / attributes.size.height) * 60;
    
    // Convert from 24-hour format
    if (hour > 12) {
        hour -= 12;
    }
    if (hour == 0) {
        hour += 12;
    }
    if (minute < 0) {
        // Weird rounding error sometimes results in a negative number
        minute = 0;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.collectionView
         performBatchUpdates:^{
             [self.backgroundGradientView
              setDarkened:YES];
             self.eventViewModelUnderFinger = nil;
             self.indexPathUnderFinger = indexPath;
             self.touching = YES;
             [self.delegate
              userDidBeginInteractingWithDayListViewController:self];
             
             if (CGRectContainsPoint(recognizer.view.bounds, self.location)) {
                 [AppDelegate playTouchDownSound];
                 [self.delegate
                  userDidInteractWithDayListView:self
                  updateTimeHour:hour
                  minute:minute
                  eventViewModel:eventViewModel];
             }
             
             for (NSInteger i = 0; i < 3; i++) {
                 double delayInSeconds = i * 0.1;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                     [self.collectionView.collectionViewLayout invalidateLayout];
                 });
             }
         }
         
         completion:^(BOOL finished) {
             [self.collectionView.collectionViewLayout invalidateLayout];
         }];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self.collectionView.collectionViewLayout invalidateLayout];
        
        if (eventViewModel != nil && eventViewModel != self.eventViewModelUnderFinger) {
            [AppDelegate playTouchNewEventSound];
        } else {
            if ([indexPath compare:self.indexPathUnderFinger] != NSOrderedSame) {
                [AppDelegate playTouchNewHourSound];
                self.indexPathUnderFinger = indexPath;
            }
        }
        self.eventViewModelUnderFinger = eventViewModel;
        
        if (CGRectContainsPoint(recognizer.view.bounds, self.location)) {
            [self.delegate userDidInteractWithDayListView:self updateTimeHour:hour minute:minute eventViewModel:eventViewModel];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.collectionView
         performBatchUpdates:^{
             [self.backgroundGradientView setDarkened:NO];
             self.eventViewModelUnderFinger = nil;
             self.indexPathUnderFinger = nil;
             self.touching = NO;
             [self.delegate
              userDidEndInteractingWithDayListViewController:self];
             [AppDelegate playTouchUpSound];
             
             for (NSInteger i = 0; i < 3; i++) {
                 double delayInSeconds = i * 0.1;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                     [self.collectionView.collectionViewLayout invalidateLayout];
                 });
             }
         }
         
         completion:^(BOOL finished) {
             [self.collectionView.collectionViewLayout invalidateLayout];
         }];
    }
}

#pragma mark - TLCollectionViewLayoutDelegate Methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TLHourCell *cell = (TLHourCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    // Position sampled background image
    CGFloat yDistance = cell.maxY - cell.minY;
    CGFloat yDelta = cell.frame.origin.y - cell.minY;
    
    // Avoid nan in below calculation
    if (yDistance == 0) {
        yDistance = 1.0f;
    }
    
    CGRect backgroundImageFrame = cell.backgroundImage.frame;
    backgroundImageFrame.origin.y = (cell.frame.size.height - backgroundImageFrame.size.height) * (yDelta / yDistance);
    cell.backgroundImage.frame = backgroundImageFrame;
    
    if (!self.touching) {
        // default size
        return CGSizeMake(CGRectGetWidth(self.view.bounds), collectionView.frame.size.height / NUMBER_OF_ROWS);
    }
    
    CGFloat effectiveHour = indexPath.item;
        
    return CGSizeMake(CGRectGetWidth(self.view.bounds), [self heightForHour:effectiveHour]);
}

-(CGRect)collectionView:(UICollectionView *)collectionView frameForHourLineViewInLayout:(TLCollectionViewLayout *)layout {
    NSDateComponents *components = self.currentDateComponents;
    
    NSInteger currentHour = components.hour;
    NSInteger currentMinute = components.minute;
    
    // Instead of re-calculating geometry for events, rely on the calculations for hour views. 
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:currentHour inSection:0]];
    
    CGFloat viewHeight = attributes.size.height;
    CGFloat minuteAdjustment = attributes.size.height * (CGFloat)(currentMinute / 60);
        
    return CGRectMake(0, attributes.frame.origin.y + minuteAdjustment - viewHeight / 2.0f, CGRectGetWidth(self.view.bounds), viewHeight);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView alphaForHourLineViewInLayout:(TLCollectionViewLayout *)layout {
    // Don't show the hour line while touching
    if (self.touching) {
        return 0.0f;
    } else {
        return 1.0f;
    }
}

-(NSUInteger)collectionView:(UICollectionView *)collectionView numberOfEventSupplementaryViewsInLayout:(TLCollectionViewLayout *)layout {
    return self.viewModelArray.count;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout alphaForCellContentAtIndexPath:(NSIndexPath *)indexPath {
    // Cells are invisible while not touching. 
    if (self.touching) {
        return [self alphaForElementInHour:indexPath.item];
    } else {
        return 0.0f;
    }
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout alphaForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    // Supplementary views' contentViews are visible only while touching. 
    if (self.touching) {
        TLEventViewModel *model = self.viewModelArray[indexPath.item];
        
        NSDateComponents *components = [[[EKEventManager sharedInstance] calendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:model.event.startDate];
        NSInteger hour = components.hour;
        
        return [self alphaForElementInHour:hour];
    } else {
        return 0.0f;
    }
}

-(CGRect)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout frameForEventSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    TLEventViewModel *model = self.viewModelArray[indexPath.item];
        
    // Grab the date components from the startDate and use the to find the hour and minutes of the event
    NSDateComponents *components = [[[EKEventManager sharedInstance] calendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:model.event.startDate];
    NSInteger hour = components.hour;
    
    CGFloat startY = 0;
    CGFloat endY = 0;
    CGFloat x;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    // Use the collection view's calculations for the hour cell representing the start hour, and adjust based on minutes if necessary
    UICollectionViewLayoutAttributes *startHourAttributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:hour inSection:0]];
    startY = CGRectGetMinY(startHourAttributes.frame);
    
    if (components.minute >= 30) {
        startY += CGRectGetHeight(startHourAttributes.frame) / 2.0f;
    }
    
    // Now grab the components of the end hour ...
    components = [[[EKEventManager sharedInstance] calendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:model.event.endDate];
    hour = components.hour;
    
    // And do the same calculation for the max Y.
    UICollectionViewLayoutAttributes *endHourAttributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:hour inSection:0]];
    endY = CGRectGetMinY(endHourAttributes.frame);
    
    if (components.minute >= 30) {
        endY += CGRectGetHeight(endHourAttributes.frame) / 2.0f;
    }
    
    // Finally, we need to calculate the X value and the width of the supplementary view.
    if (model.eventSpan == TLEventViewModelEventSpanFull ||  model.eventSpan == TLEventViewModelEventSpanLeft) {
        x = 0;
    } else { // implicitly, this is true: (model.eventSpan == TLEventViewModelEventSpanRight || model.eventSpan == TLEventViewModelEventSpanTooManyWarning)
        x = CGRectGetMidX(self.view.bounds) + 1;
    }
    
    // All other event spans are half the horizontal size.
    if (model.eventSpan != TLEventViewModelEventSpanFull) {
        width /= 2.0f;
    }
    
    return CGRectMake(x, startY, width, endY - startY);
}

-(TLCollectionViewLayoutAttributesBackgroundState)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout backgroundStateForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    TLEventViewModel *model = self.viewModelArray[indexPath.item];
    
    if (self.isTouching) {
        // The user is touching. Either represented by the index path is under the finger (highlighted) or not (unhighlited)
        if (model == self.eventViewModelUnderFinger) {
            return TLCollectionViewLayoutAttributesBackgroundStateHighlighted;
        } else {
            return TLCollectionViewLayoutAttributesBackgroundStateUnhighlighted;
        }
    } else {
        
        NSDate *now = [NSDate date];
        if ([model.event.startDate isEarlierThanDate:now] && [model.event.endDate isLaterThanDate:now]) {
            return TLCollectionViewLayoutAttributesBackgroundStateImmediate;
        }
        else if ([model.event.endDate isEarlierThanDate:now]) {
            return TLCollectionViewLayoutAttributesBackgroundStatePast;
        }
        else { // implicitly, ([model.event.startDate isLaterThanDate:now]) 
            return TLCollectionViewLayoutAttributesBackgroundStateFuture;
        }
    }
}

-(TLCollectionViewLayoutAttributesAlignment)collectionView:(UICollectionView *)collectionView layout:(TLCollectionViewLayout *)layout alignmentForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    TLEventViewModel *model = self.viewModelArray[indexPath.item];
    
    if (model.eventSpan == TLEventViewModelEventSpanFull) {
        return TLCollectionViewLayoutAttributesAlignmentFull;
    }
    else if (model.eventSpan == TLEventViewModelEventSpanLeft) {
        return TLCollectionViewLayoutAttributesAlignmentLeft;
    }
    else if (model.eventSpan == TLEventViewModelEventSpanRight) {
        return TLCollectionViewLayoutAttributesAlignmentRight;
    }
    else {
        return TLCollectionViewLayoutAttributesAlignmentNoTime;
    }
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NUMBER_OF_ROWS;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TLHourCell *cell = (TLHourCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    [self configureBackgroundCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:[TLHourLineSupplementaryView kind]]) {
        // We only ever have one hour supplementary view for the hour. 
        if (!self.hourSupplementaryView) {
            self.hourSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHourSupplementaryViewIdentifier forIndexPath:indexPath];
            
            RACSubject *updateSubject = [RACSubject subject];
            
            NSDateComponents *components = [[[EKEventManager sharedInstance] calendar] components:NSSecondCalendarUnit fromDate:[NSDate date]];
            
            // TODO: This is negative.
            // Find out when the next minute change is and start a recurring RACSignal when that happens. 
            NSInteger delay = 60 - components.second;
            
            NSLog(@"Scheduling subscription every minute for supplementary view in %d seconds", delay);
            
            double delayInSeconds = delay;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                NSLog(@"Creating initial subscription for supplementary view.");
                [updateSubject sendNext:[NSDate date]];
                
                [[RACSignal interval:60] subscribeNext:^(id x) {
                    NSLog(@"Updating minute of supplementary view.");
                    [updateSubject sendNext:x];
                }];
            });
            
            // Finally, bind the value of the supplementary view's timeString property to a mapped signal.
            RAC(self.hourSupplementaryView.timeString) = [updateSubject map:^id (NSDate *date) {
                NSDateComponents *components = [[[EKEventManager sharedInstance] calendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                           fromDate:date];
                
                NSInteger hours = components.hour % 12;
                
                // Convert to 12-hour time.
                if (hours == 0) {
                    hours = 12;
                }
                
                return [NSString stringWithFormat:@"%d:%02d", hours, components.minute];
            }];
            
            [updateSubject sendNext:[NSDate date]];
        }
        
        return self.hourSupplementaryView;
    } else { // implicitly ([kind isEqualToString:[TLEventSupplementaryView kind]])
        TLEventSupplementaryView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kEventSupplementaryViewIdentifier forIndexPath:indexPath];
        
        TLEventViewModel *model = self.viewModelArray[indexPath.item];
        
        if (model.eventSpan == TLEventViewModelEventSpanTooManyWarning) {
            supplementaryView.titleString = [NSString stringWithFormat:@"%d more events", model.extraEventsCount];
            supplementaryView.timeString = @"";
        }
        else {
            NSDateComponents *components = [[[EKEventManager sharedInstance] calendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:model.event.startDate];
            
            NSInteger hours = components.hour % 12;
            NSInteger minutes = components.minute;
            
            // Convert to 12-hour time.
            if (hours == 0) {
                hours = 12;
            }
            
            NSString *timeString = [NSString stringWithFormat:@"%d:%02d", hours, minutes];
            
            supplementaryView.titleString = model.event.title;
            supplementaryView.timeString = timeString;
        }
        
        return supplementaryView;
    } 
}

#pragma mark - Private Methods

-(CGFloat)heightForHour:(NSInteger)hour {
    
    CGFloat minSize = (self.collectionView.frame.size.height - (MAX_ROW_HEIGHT * EXPANDED_ROWS)) / (NUMBER_OF_ROWS - EXPANDED_ROWS);
    
    CGFloat dayLocation = (self.location.y / self.collectionView.frame.size.height) * NUMBER_OF_ROWS;
    
    
    CGFloat diff = dayLocation - hour;
    
    // prevent reducing size of min / max rows
    if (hour < EXPANDED_ROWS) {
        if (diff < 0) {
            diff = 0;
        }
    } else if (hour > NUMBER_OF_ROWS - EXPANDED_ROWS - 1) {
        if (diff > 0) {
            diff = 0;
        }
    }
    
    CGFloat delta = ((EXPANDED_ROWS - fabsf(diff)) / EXPANDED_ROWS);
    
    CGFloat size = (minSize + MAX_ROW_HEIGHT) * delta;
    if (size > MAX_ROW_HEIGHT) {
        size = MAX_ROW_HEIGHT;
    }
    
    if (size < minSize) {
        size = minSize;
    }
    
    return size;
}

-(CGFloat)alphaForElementInHour:(NSInteger)hour {
    CGFloat dayLocation = (self.location.y / self.collectionView.frame.size.height) * 24;
    
    CGFloat effectiveHour = hour;
    
    CGFloat diff = dayLocation - effectiveHour;
    
    CGFloat delta = ((EXPANDED_ROWS - fabsf(diff)) / EXPANDED_ROWS);
    
    if (delta < 0) {
        delta = 0.0f;
    } else if (delta > 1) {
        delta = 1.0f;
    }
    
    return delta;
}

-(void)updateBackgroundGradient {
    // Determine if the soonest event is within a half hour to change the colour of the background gradient.
    NSArray *events = [[EKEventManager sharedInstance] events];
    
    CGFloat soonestEvent = NSIntegerMax;
    
    for (EKEvent *event in events) {
        if (!event.isAllDay) {
            if ([event.startDate isEarlierThanDate:[NSDate date]] && ![event.endDate isEarlierThanDate:[NSDate date]]) {
                // There's an event going on NOW.
                soonestEvent = 0;
            } else if (![event.startDate isEarlierThanDate:[NSDate date]]) {
                NSTimeInterval interval = [event.startDate timeIntervalSinceNow];
                NSInteger numberOfMinutes = interval / 60;
                
                soonestEvent = MIN(soonestEvent, numberOfMinutes);
            }
        }
    }
    
    const CGFloat fadeTime = 30.0f;
    
    if (soonestEvent == 0) {
        [self.backgroundGradientView setAlertRatio:1.0f animated:YES];
    } else if (soonestEvent > fadeTime) {
        [self.backgroundGradientView setAlertRatio:0.0f animated:YES];
    } else {
        CGFloat ratio = (fadeTime - soonestEvent) / fadeTime;
        
        [self.backgroundGradientView setAlertRatio:ratio animated:YES];
    }
    
    // Save copy of gradient as image.
    TLAppDelegate *appDelegate = (TLAppDelegate *)[UIApplication sharedApplication].delegate;
    TLRootViewController *rootViewController = appDelegate.viewController;
    UIGraphicsBeginImageContext(self.backgroundGradientView.bounds.size);
    [self.backgroundGradientView.gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    rootViewController.gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(TLEventViewModel *)eventViewModelUnderPoint:(CGPoint)point {
    //Find the event under a specific point
    TLEventViewModel *eventUnderTouch;
    
    for (NSInteger i = 0; i < self.viewModelArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CGRect frame = [self collectionView:self.collectionView layout:(TLCollectionViewLayout *)self.collectionView.collectionViewLayout frameForEventSupplementaryViewAtIndexPath:indexPath];
        
        if (CGRectContainsPoint(frame, point)) {            
            eventUnderTouch = self.viewModelArray[i];
        }
    }
    
    return eventUnderTouch;
}

#pragma mark - Private Methods

-(void)configureBackgroundCell:(TLHourCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSInteger hour = indexPath.row % 12;
    if (hour == 0) hour = 12;
    
    [cell setHour:hour];
}

@end
