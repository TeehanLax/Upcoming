//
//  TLTaskListLayout.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLTaskListLayout.h"
#import "TLHourDecorationView.h"

static NSString *TLTaskListLayoutHourDecorationViewKind = @"TLTaskListLayoutHourDecorationViewKind";

@interface TLTaskListLayout ()

@property (nonatomic, assign) CGFloat collectionViewHeight;
@property (nonatomic, assign, readwrite) CGFloat hourSize;

@property (nonatomic, weak) id<TLTaskListLayoutDelegate> layoutDelegate;

@end

@implementation TLTaskListLayout

// These are only guidelines – the actual heights will vary.
static const CGFloat maxHeight = 60;
static const CGFloat minHeight = 15;

-(id)init
{
    if (!(self = [super init])) return nil;
    
    [self registerClass:[TLHourDecorationView class] forDecorationViewOfKind:TLTaskListLayoutHourDecorationViewKind];
        
    return self;
}

-(CGSize)collectionViewContentSize
{
    // We want to fill the bounds of the collection view exactly – no more and no less. 
    return self.collectionView.bounds.size;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    // For resizing due to status bar height change
    return YES;
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

// Documentation says we need to provide individual layout attributes, but it's lying.
// Our implementation of layoutAttributesForElementsInRect: is the only thing that ever
// calls this method. 
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // Calculate some constants. These are used to judge the distance from the concentration point.
    CGFloat minuteStartTime = indexPath.section * 60.0f;
    CGFloat hourStartTime = (CGFloat)minuteStartTime / 60.0f;
    CGFloat y = floorf(self.hourSize * hourStartTime);

    // This frame is only a guess. We'll set the real frames in layoutAttributesForElementsInRect:
    attributes.frame = CGRectMake(0, y, CGRectGetWidth(self.collectionView.bounds), self.hourSize);
    
    // We need to adjust our distance calculation because we're moving the frames around. 
    CGFloat midY = y + self.hourSize / 4.0f;
    CGFloat distance = fabsf(self.concentrationPoint - midY);

    // Used to distribute or concentrate distributions of heights. Determined experimentally. 
    const CGFloat distributionConstant = 1.0013;
    
    // This is a modified verion of the formula for a bell curve.
    CGFloat height = (maxHeight) / (powf(distributionConstant, powf((distance * 0.5), 2.0f))) + minHeight;
    
    // This is the most import line in this method. We set the height and it'll be used in calculations in layoutAttributesForElementsInRect:
    attributes.size = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), height);
    
    // Something high so we can put decoration views behind it.
    attributes.zIndex = 50;
        
    return attributes;
}

// Documentation says we need to provide individual layout attributes, but it's lying.
// No one calls this method ever. 
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

// This method is called every time the layout is invalidated. It should be as efficient as possible. 
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // Create a mutable array with 24 elements in it, representing the 24 hours of a day.
    NSMutableArray* layoutAttributesArray = [NSMutableArray arrayWithCapacity:24];
    NSMutableArray *decorationViewAttributesArray = [NSMutableArray arrayWithCapacity:24];

    // We need to keep track of the total height so we can adjust the heights of all the items
    // later to 
    CGFloat totalHeight = 0;
    
    // We'll calculate geometry for *all* 24 hours first then remove unwanted sections later
    for (NSInteger i = 0; i < 24; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        UICollectionViewLayoutAttributes *newAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        totalHeight += newAttributes.size.height;
        
        UICollectionViewLayoutAttributes *decorationViewLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:TLTaskListLayoutHourDecorationViewKind withIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [decorationViewAttributesArray addObject:decorationViewLayoutAttributes];
        
        // Populate the array.
        [layoutAttributesArray addObject:newAttributes];
    }
    
    
    CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.bounds);
    CGFloat heightToAdd = 0;
    
    if (totalHeight > collectionViewHeight)
    {
        heightToAdd = - (totalHeight - collectionViewHeight) / 24.0f;
    }
    else if (totalHeight < collectionViewHeight)
    {
        heightToAdd = (collectionViewHeight - totalHeight) / 24.0f;
    }
    
    // Now that we have all the sizes calculated, "stack" the items one on top of each other
    CGFloat maxY = 0.0f;
    NSMutableArray *sectionsToRemove = [NSMutableArray arrayWithCapacity:24];
    
    // Stack the index paths up one by one. 
    for (NSInteger i = 0; i < 24; i++)
    {
        UICollectionViewLayoutAttributes *attributes = layoutAttributesArray[i];
        UICollectionViewLayoutAttributes *decorationViewAttributes = decorationViewAttributesArray[i];
        attributes.frame = CGRectMake(0, maxY, CGRectGetWidth(self.collectionView.bounds), attributes.size.height + heightToAdd);
        decorationViewAttributes.frame = attributes.frame;
        
        maxY += (attributes.size.height);
        
        // Find out if we should keep this section.
        // Note that we call this with the *original* index path, not the adjusted one (below).
        BOOL keepAttribute = [self.layoutDelegate collectionView:self.collectionView layout:self hasEventForHour:attributes.indexPath.section];
        
        // The original index path was based on having 24 sections. We need to adjust it down to compensate for the
        // sections we've removed.
        attributes.indexPath = [NSIndexPath indexPathForItem:0 inSection:attributes.indexPath.section - sectionsToRemove.count];
        
        if (!keepAttribute)
        {
            [sectionsToRemove addObject:attributes];
        }
    }
    
    NSMutableArray *arrayToReturn = [layoutAttributesArray mutableCopy];
    
    // We need to remove sections not represented in collection view
    [arrayToReturn removeObjectsInArray:sectionsToRemove];
    
    // Finally, add our decoration views.
    [arrayToReturn addObjectsFromArray:decorationViewAttributesArray];
    
    return arrayToReturn;
}

#pragma mark - Overridden Properties

-(void)setConcentrationPoint:(CGFloat)concentrationPoint
{
    _concentrationPoint = concentrationPoint;
    
    [self invalidateLayout];
}

@end
