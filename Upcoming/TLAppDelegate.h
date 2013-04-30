//
//  TLAppDelegate.h
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLRootViewController;

typedef enum{
    TLAppDelegateDeviceIPhone3GS,
    TLAppDelegateDeviceIPhone4,
    TLAppDelegateDeviceIPhone4S,
    TLAppDelegateDeviceIPhone5
}TLAppDelegateDevice;

@interface TLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TLRootViewController *viewController;

@property (nonatomic, readonly) TLAppDelegateDevice device;

@end
