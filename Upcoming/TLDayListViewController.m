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
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userdidTap:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
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
    //TODO: What if the location leaves self.view.bounds?
//    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        self.taskListLayout.concentrationPoint = [recognizer locationInView:self.view].y;
    }
}

-(void)userdidTap:(UITapGestureRecognizer *)recognizer
{
    self.taskListLayout.concentrationPoint = [recognizer locationInView:self.view].y;
}


#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Assume we have a 1-hour appointment every hour
    return 13;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
    
    return cell;
}

#pragma mark - TLTaskListLayoutDelegate Methods

-(BOOL)collectionView:(UICollectionView *)collectionView layout:(TLTaskListLayout *)collectionViewLayout hasEventForHour:(NSInteger)hour
{
    if (hour % 2 == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
