//
//  TLHourLineSupplementaryViewLayoutAttributes.h
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-03.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TLCollectionViewLayoutAttributesBackgroundStatePast = 0,
    TLCollectionViewLayoutAttributesBackgroundStateImmediate,
    TLCollectionViewLayoutAttributesBackgroundStateFuture,
    TLCollectionViewLayoutAttributesBackgroundStateHighlighted,
    TLCollectionViewLayoutAttributesBackgroundStateUnhighlighted
}TLCollectionViewLayoutAttributesBackgroundState;

typedef enum {
    TLCollectionViewLayoutAttributesAlignmentLeft = 0,
    TLCollectionViewLayoutAttributesAlignmentFull,
    TLCollectionViewLayoutAttributesAlignmentRight
}TLCollectionViewLayoutAttributesAlignment;

@interface TLCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) CGFloat contentAlpha;
@property (nonatomic, assign) TLCollectionViewLayoutAttributesBackgroundState backgroundState;
@property (nonatomic, assign) TLCollectionViewLayoutAttributesAlignment alignment;

@end
