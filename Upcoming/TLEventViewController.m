//
//  ECViewController.m
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-17.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLEventViewController.h"
#import "TLBackgroundGradientView.h"
#import "TLCollectionViewLayout.h"
#import <QuartzCore/QuartzCore.h>

#define NUMBER_OF_ROWS 24
#define EXPANDED_ROWS 4
#define MAX_ROW_HEIGHT 60.f

static NSString *kCellIdentifier = @"Cell";

@interface TLEventViewController ()

@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) BOOL touch;
@property (nonatomic, strong) TLBackgroundGradientView *backgroundGradientView;

@end

@implementation TLEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.touch = NO;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    
    self.touchDown = [[TLTouchDownGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownHandler:)];
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
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.touch = YES;
        [self.delegate userDidBeginInteractingWithDayListViewController:self];
        if (CGRectContainsPoint(recognizer.view.bounds, self.location)) {
            [self.delegate userDidInteractWithDayListView:self updatingTimeRatio:(self.location.y / CGRectGetHeight(recognizer.view.bounds)) event:nil]; //TODO: Should not be nil
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (CGRectContainsPoint(recognizer.view.bounds, self.location)) {
            [self.delegate userDidInteractWithDayListView:self updatingTimeRatio:(self.location.y / CGRectGetHeight(recognizer.view.bounds)) event:nil]; //TODO: Should not be nil
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.touch = NO;
        [self.delegate userDidEndInteractingWithDayListViewController:self];
    }
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.touch) {
        // default size
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
    
    if (size > MAX_ROW_HEIGHT) size = MAX_ROW_HEIGHT;
    if (size < minSize) size = minSize;
    
    return CGSizeMake(320, size);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NUMBER_OF_ROWS;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        cell.contentView.alpha = 0.5;
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.contentView.alpha = 0.5;
    }
    
    if (indexPath.row == 6) {
        cell.contentView.backgroundColor = [UIColor blueColor];
        cell.contentView.alpha = 0.7;
    } else if (indexPath.row == 11) {
        cell.contentView.backgroundColor = [UIColor redColor];
        cell.contentView.alpha = 0.7;
    } else if (indexPath.row == 14) {
        cell.contentView.backgroundColor = [UIColor greenColor];
        cell.contentView.alpha = 0.7;
    } else if (indexPath.row == 17) {
        cell.contentView.backgroundColor = [UIColor magentaColor];
        cell.contentView.alpha = 0.7;
    } else if (indexPath.row == 21) {
        cell.contentView.backgroundColor = [UIColor cyanColor];
        cell.contentView.alpha = 0.7;
    }
    
    return cell;
}

@end