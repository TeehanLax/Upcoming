//
//  ECViewController.m
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-17.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLEventViewController.h"
#import "TLTouchDownGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>

#define HEADER_HEIGHT 72.f
#define CURRENT_VIEW_HEIGHT 240.f

static NSString *kPastCellIdentifier = @"PastCell";
static NSString *kCurrentCellIdentifier = @"CurrentCell";
static NSString *kFutureCellIdentifier = @"FutureCell";

@interface TLEventViewController ()

//- (NSInteger)currentHour;

@end

@implementation TLEventViewController {
    NSInteger currentHour;
    NSInteger lastHour;
    BOOL isPanning;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentHour = 0;
    isPanning = NO;
    
    [self.pastView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPastCellIdentifier];
    [self.currentView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCurrentCellIdentifier];
    [self.futureView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kFutureCellIdentifier];
    
    TLTouchDownGestureRecognizer *touchDown = [[TLTouchDownGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownHandler:)];
    [self.view addGestureRecognizer:touchDown];
}

- (void)viewWillAppear:(BOOL)animated {
    self.pastViewController = [[TLPastViewController alloc] init];
    self.pastViewController.expanded = NO;
    self.pastViewController.parentHeight = self.view.bounds.size.height - HEADER_HEIGHT;
    NSLog(@"PARENT HEIGHT: %f", self.pastViewController.parentHeight);
    self.pastView.delegate = self.pastViewController;
    self.pastView.dataSource = self.pastViewController;
    [self.pastView reloadData];
    
    self.futureViewController = [[TLFutureViewController alloc] init];
    self.futureViewController.expanded = NO;
    self.futureViewController.parentHeight = self.view.frame.size.height - HEADER_HEIGHT;
    self.futureView.delegate = self.futureViewController;
    self.futureView.dataSource = self.futureViewController;
    [self.futureView reloadData];
    
    self.currentView.hidden = YES;
    
    CGRect pastRect = self.pastView.frame;
    pastRect.origin.y = HEADER_HEIGHT;
    pastRect.size.height = self.view.frame.size.height - HEADER_HEIGHT;
    self.pastView.frame = pastRect;
    
    CGRect futureRect = self.futureView.frame;
    futureRect.origin.y = HEADER_HEIGHT;
    futureRect.size.height = self.view.frame.size.height - HEADER_HEIGHT;
    self.futureView.frame = futureRect;
}

- (void)touchDownHandler:(TLTouchDownGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate userDidBeginInteractingWithDayListViewController:self];
        self.currentView.hidden = NO;
        self.pastViewController.expanded = YES;
        self.futureViewController.expanded = YES;
        isPanning = YES;
        [_pastView reloadData];
        [_futureView reloadData];
//        [_pastView performBatchUpdates:nil completion:nil];
//        [_futureView performBatchUpdates:nil completion:nil];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.currentView.hidden = YES;
        self.pastViewController.expanded = NO;
        self.futureViewController.expanded = NO;
        isPanning = NO;
        [_pastView reloadData];
        [_futureView reloadData];
//        [_pastView performBatchUpdates:nil completion:nil];
//        [_futureView performBatchUpdates:nil completion:nil];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.delegate userDidEndInteractingWithDayListViewController:self];
        
        CGRect pastRect = self.pastView.frame;
        pastRect.origin.y = HEADER_HEIGHT;
        pastRect.size.height = self.view.frame.size.height - HEADER_HEIGHT;
        self.pastView.frame = pastRect;

        CGRect futureRect = self.futureView.frame;
        futureRect.origin.y = HEADER_HEIGHT;
        futureRect.size.height = self.view.frame.size.height - HEADER_HEIGHT;
        self.futureView.frame = futureRect;
    } else {
        CGPoint location = [recognizer locationInView:self.view];
        [self.delegate userDidInteractWithDayListView:self updatingTimeRatio:(location.y / CGRectGetHeight(self.view.bounds))];
        
        CGFloat offset = location.y - (CURRENT_VIEW_HEIGHT / 2);
        if (offset < HEADER_HEIGHT) offset = HEADER_HEIGHT;
        if (offset > self.view.frame.size.height - CURRENT_VIEW_HEIGHT) offset = self.view.frame.size.height - CURRENT_VIEW_HEIGHT;
        
        CGRect currentRect = self.currentView.frame;
        currentRect.origin.y = offset;
        
        self.currentView.frame = currentRect;
        
        CGRect pastRect = self.pastView.frame;
        pastRect.size.height = offset - HEADER_HEIGHT;
        self.pastView.frame = pastRect;
        
        CGRect futureRect = self.futureView.frame;
        futureRect.size.height = ((self.view.frame.size.height - HEADER_HEIGHT - CURRENT_VIEW_HEIGHT) / 20) * 24;
        futureRect.origin.y = self.view.frame.size.height - futureRect.size.height;
        self.futureView.frame = futureRect;
        
        CGFloat position = (offset - HEADER_HEIGHT) / (self.view.frame.size.height - HEADER_HEIGHT - CURRENT_VIEW_HEIGHT);
        if (position < 0) position = 0;
        
        self.currentView.contentOffset = CGPointMake(0, (self.currentView.contentSize.height - CURRENT_VIEW_HEIGHT) * position);
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 24;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (collectionView == _pastView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPastCellIdentifier forIndexPath:indexPath];
    } else if (collectionView == _currentView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCurrentCellIdentifier forIndexPath:indexPath];
    } else if (collectionView == _futureView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFutureCellIdentifier forIndexPath:indexPath];
    }
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 6) {
        cell.backgroundColor = [UIColor blueColor];
    } else if (indexPath.row == 11) {
        cell.backgroundColor = [UIColor redColor];
    } else if (indexPath.row == 14) {
        cell.backgroundColor = [UIColor greenColor];
    } else if (indexPath.row == 17) {
        cell.backgroundColor = [UIColor magentaColor];
    } else if (indexPath.row == 21) {
        cell.backgroundColor = [UIColor cyanColor];
    }
    
    return cell;
}

@end