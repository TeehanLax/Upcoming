//
//  TouchDownGestureRecognizer.m
//  EventCollectionView
//
//  Created by Brendan Lynch on 13-04-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLTouchDownGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation TLTouchDownGestureRecognizer

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.state = UIGestureRecognizerStateEnded;
}

@end