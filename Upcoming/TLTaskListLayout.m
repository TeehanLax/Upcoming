//
//  TLTaskListLayout.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLTaskListLayout.h"

CGFloat kHourSize;

@interface TLTaskListLayout ()

@property (nonatomic, assign) CGFloat collectionViewHeight;
@property (nonatomic, assign, readwrite) CGFloat hourSize;

@property (nonatomic, weak) id<TLTaskListLayoutDelegate> layoutDelegate;

@end

@implementation TLTaskListLayout

-(id)init
{
    if (!(self = [super init])) return nil;
        
    return self;
}

-(CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

-(void)prepareLayout
{
    [super prepareLayout];
    
    if ([self.collectionView.delegate conformsToProtocol:@protocol(TLTaskListLayoutDelegate)])
    {
        self.layoutDelegate = (id<TLTaskListLayoutDelegate>)(self.collectionView.delegate);
    }
    else
    {
        self.layoutDelegate = nil;
    }
    
    self.collectionViewHeight = CGRectGetHeight(self.collectionView.bounds);
    self.hourSize = self.collectionViewHeight / 24.0f; // We represent 24 hours
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSInteger minuteDuration = [self.layoutDelegate collectionView:self.collectionView layout:self minuteDurationForItemAtIndexPath:indexPath];
    CGFloat hourDuration = (CGFloat)minuteDuration / 60.0f;
    CGFloat height = floorf(self.hourSize * hourDuration);
    NSInteger minuteStartTime = [self.layoutDelegate collectionView:self.collectionView layout:self minuteStartTimeForItemAtIndexPath:indexPath];
    CGFloat hourStartTime = (CGFloat)minuteStartTime / 60.0f;
    CGFloat y = floorf(self.hourSize * hourStartTime);
    
    attributes.frame = CGRectMake(0, y, CGRectGetWidth(self.collectionView.bounds), height);
    
    NSLog(@"%@", indexPath);
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    NSMutableArray* layoutAttributesArray = [NSMutableArray arrayWithCapacity:numberOfSections];
    
    for (NSInteger i = 0; i < numberOfSections; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        UICollectionViewLayoutAttributes *newAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [layoutAttributesArray addObject:newAttributes];
    }
    
    return layoutAttributesArray;
}

#pragma mark - Overridden Properties

-(void)setConcentrationPoint:(CGFloat)concentrationPoint
{
    _concentrationPoint = concentrationPoint;
    
    [self invalidateLayout];
}

@end
