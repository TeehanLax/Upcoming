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

- (id)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateEnded;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.state = UIGestureRecognizerStateEnded;
}

@end