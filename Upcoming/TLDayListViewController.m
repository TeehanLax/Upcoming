//
//  TLViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLDayListViewController.h"
#import "TLTaskListCell.h"
#import "TLBackgroundGradientView.h"

#import <EXTScope.h>

@interface TLDayListViewController ()

@property (nonatomic, strong) TLTaskListLayout *taskListLayout;
@property (nonatomic, strong) UITapGestureRecognizer *individualTaskPanGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *taskListPanGestureRecognizer;

@property (nonatomic, strong) TLBackgroundGradientView *backgroundGradientView;

@end

@implementation TLDayListViewController

static NSString *CellIdentifier = @"Cell";

-(void)loadView
{
    self.taskListLayout = [[TLTaskListLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.taskListLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[TLTaskListCell class] forCellWithReuseIdentifier:CellIdentifier];
    self.collectionView = collectionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundGradientView = [[TLBackgroundGradientView alloc] initWithFrame:self.view.bounds];
    self.collectionView.backgroundView = self.backgroundGradientView;
    
    self.taskListPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    self.taskListPanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.taskListPanGestureRecognizer];
    
    self.individualTaskPanGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapTask:)];
    self.individualTaskPanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.individualTaskPanGestureRecognizer];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Assume we want to concentrate in the middle for now.
    self.taskListLayout.concentrationPoint = TLTaskListLayoutConcentrationPointNone;
}

#pragma mark - Gesture Recognizer Methods

-(void)userDidPan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.delegate userDidBeginInteractingWithDayListViewController:self];
        self.backgroundGradientView.drawInnserShadow = YES;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint location = [recognizer locationInView:self.view];
        
        if (CGRectContainsPoint(self.view.bounds, location))
        {
            self.taskListLayout.concentrationPoint = location.y;
            [self.delegate userDidInteractWithDayListView:self updatingTimeRatio:(location.y / CGRectGetHeight(self.collectionView.bounds))];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.delegate userDidEndInteractingWithDayListViewController:self];
        self.backgroundGradientView.drawInnserShadow = NO;
    }
}

-(void)userDidTapTask:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [recognizer locationInView:self.view];
        
        if (fabs(location.y - self.taskListLayout.concentrationPoint) < self.taskListLayout.hourSize)
        {
            NSLog(@"Panning task.");
        }
        else
        {
            self.taskListLayout.concentrationPoint = location.y;
        }
    }
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Always only one item per section. *ALWAYS*. 
    return 1;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // We *must* return a *minimum* of one section (for decoration views)
    NSInteger numberOfSections = 0;
    return MAX(numberOfSections, 1);
}

-(TLTaskListCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TLTaskListCell *cell = (TLTaskListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    return cell;
}

#pragma mark - TLTaskListLayoutDelegate Methods

-(BOOL)collectionView:(UICollectionView *)collectionView layout:(TLTaskListLayout *)collectionViewLayout hasEventForHour:(NSInteger)hour
{
    return NO;
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
