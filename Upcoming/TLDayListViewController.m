//
//  TLViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLDayListViewController.h"
#import "TLTaskListLayout.h"

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
    
}

#pragma mark - Gesture Recognizer Methods

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 20; 
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0) return UIEdgeInsetsZero;
    return UIEdgeInsetsMake(arc4random()%10, 0, 0, 0);
}

@end
