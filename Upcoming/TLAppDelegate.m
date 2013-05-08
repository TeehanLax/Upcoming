//
//  TLAppDelegate.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-11.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLAppDelegate.h"
#import "TLRootViewController.h"
#import "EKEventManager.h"
#import "TLDefines.h"

#import <TestFlight.h>

#include <sys/types.h>
#include <sys/sysctl.h>

@interface TLAppDelegate ()

@property (nonatomic, strong) TLSplashViewController *splashViewController;

@end

@implementation TLAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([TEST_FLIGHT_TOKEN length] > 0) {
        [TestFlight takeOff:TEST_FLIGHT_TOKEN];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[TLRootViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    self.splashViewController = [[TLSplashViewController alloc] init];
    self.splashViewController.view.frame = self.viewController.view.bounds;
    [self.viewController.view addSubview:self.splashViewController.view];

    [self setupDevice];

    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    // Update the content of the event manager, and thus the collection view. 
    [[EKEventManager sharedInstance] refresh];
}

-(void)setupDevice {
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);

    if ([platform hasPrefix:@"iPhone2"] || [platform hasPrefix:@"iPod2"] || [platform hasPrefix:@"iPod3"]) {
        _device = TLAppDelegateDeviceIPhone3GS;
    } else if ([platform hasPrefix:@"iPhone3"] || [platform hasPrefix:@"iPod4"]) {
        _device = TLAppDelegateDeviceIPhone4;
    } else if ([platform hasPrefix:@"iPhone4"] || [platform hasPrefix:@"iPod5"]) {
        _device = TLAppDelegateDeviceIPhone4S;
    } else if ([platform hasPrefix:@"iPhone5"]) {
        _device = TLAppDelegateDeviceIPhone5;
    } else {
        // We're going to assume it's the iPhone 5 if none of the other comparisons worked.
        // Likely, this is new hardware that's at least as capable as the iPhone 5.
        _device = TLAppDelegateDeviceIPhone5;
    }
}

-(void)splashScreenControllerFinishedTransition:(TLSplashViewController *)controller {
    [self.splashViewController.view removeFromSuperview];
    self.splashViewController = nil;
}

@end
