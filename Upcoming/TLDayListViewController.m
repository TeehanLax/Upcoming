//
//  TLViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLDayListViewController.h"

@interface TLDayListViewController ()

@property (nonatomic, strong) TLTaskListLayout *taskListLayout;

@end

@implementation TLDayListViewController

static NSString *CellIdentifier = @"Cell";

-(void)loadView
{
    self.taskListLayout = [[TLTaskListLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.taskListLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    self.view = collectionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    [self.view addGestureRecognizer:recognizer];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Assume we want to concentrate in the middle for now.
    self.taskListLayout.concentrationPoint = CGRectGetMidY(self.view.bounds);
}

#pragma mark - Gesture Recognizer Methods

-(void)userDidPan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        self.taskListLayout.concentrationPoint = [recognizer locationInView:self.view].y;
    }
}


#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Assume we have a 1-hour appointment every 2 hours
    return 12;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5f];
    
    return cell;
}

#pragma mark - TLTaskListLayoutDelegate Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minuteDurationForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView layout:(TLTaskListLayout *)collectionViewLayout minuteStartTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section * 60 * 2;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(TLTaskListLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Assume that we only have one appointment at a time (ie: full width).
//    return CGSizeMake(CGRectGetWidth(self.view.bounds), floorf(self.taskListLayout.hourSize * 1.0f)); // Assume each appointment is one hour long
//}

@end
