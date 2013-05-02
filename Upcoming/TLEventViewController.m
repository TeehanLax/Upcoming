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
    
    self.backgroundGradientView = [[TLBackgroundGradientView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.backgroundGradientView atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    TLCollectionViewLayout *layout = [[TLCollectionViewLayout alloc] init];
    
    [self.collectionView setCollectionViewLayout:layout animated:animated];
}

- (void)touchDownHandler:(TLTouchDownGestureRecognizer *)recognizer {
    self.location = [recognizer locationInView:recognizer.view];
    
    EKEvent *event = [self eventUnderPoint:self.location];
        
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.touch = YES;
        [self.delegate userDidBeginInteractingWithDayListViewController:self];
        if (CGRectContainsPoint(recognizer.view.bounds, self.location)) {
            [self.delegate userDidInteractWithDayListView:self updatingTimeRatio:(self.location.y / CGRectGetHeight(recognizer.view.bounds)) event:event];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (CGRectContainsPoint(recognizer.view.bounds, self.location)) {
            [self.delegate userDidInteractWithDayListView:self updatingTimeRatio:(self.location.y / CGRectGetHeight(recognizer.view.bounds)) event:event];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.touch = NO;
        [self.delegate userDidEndInteractingWithDayListViewController:self];
    }
    [self.collectionView performBatchUpdates:nil completion:nil];
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
            cell.title.alpha = 0;
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
    cell.title.alpha = (EXPANDED_ROWS - fabsf(diff)) / EXPANDED_ROWS;
    
    if (size > MAX_ROW_HEIGHT) size = MAX_ROW_HEIGHT;
    if (size < minSize) size = minSize;
    
    return CGSizeMake(320, size);
}

-(CGRect)collectionView:(UICollectionView *)collectionView frameForHourViewInLayout:(TLCollectionViewLayout *)layout {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    const CGFloat viewHeight = 44.0f;
    NSInteger currentHour = components.hour;
    NSInteger currentMinute = components.minute;
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:currentHour inSection:0]];
    CGFloat minuteAdjustment = attributes.size.height * (CGFloat)(currentMinute / 60);
    
    return CGRectMake(0, attributes.frame.origin.y + minuteAdjustment - viewHeight, CGRectGetWidth(self.view.bounds), viewHeight);
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
            cell.title.text = event.title;
        }
    }
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {    
    TLHourSupplementaryView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSupplementaryViewIdentifier forIndexPath:indexPath];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    supplementaryView.timeString = [NSString stringWithFormat:@"%d:%02d", components.hour % 12, components.minute];
    
    return supplementaryView;
}

#pragma mark - Private Methods
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