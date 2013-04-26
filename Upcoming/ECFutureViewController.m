//
//  ECFutureViewController.m
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "ECFutureViewController.h"

@interface ECFutureViewController ()

@end

@implementation ECFutureViewController

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 24;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FutureCell" forIndexPath:indexPath];
    
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

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_expanded == YES) {
        return CGSizeMake(320, (_parentHeight - 240) / 20);
    } else {
        return CGSizeMake(320, _parentHeight / 24);
    }
}

@end