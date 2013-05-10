//
//  TLAppDelegate+Sounds.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-05-01.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLAppDelegate+Sounds.h"

#import <AudioToolbox/AudioToolbox.h>

static SystemSoundID touchDownSoundID;
static SystemSoundID touchUpSoundID;
static SystemSoundID touchNewHourSoundID;
static SystemSoundID touchNewEventSoundID;
static SystemSoundID pullMenuOutSoundID;
static SystemSoundID pushMenuInSoundID;

@implementation TLAppDelegate (Sounds)

-(void)playTouchDownSound {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"Click Pop (Medium 1)" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &touchDownSoundID);
    });
    AudioServicesPlaySystemSound(touchDownSoundID);
}

-(void)playTouchUpSound {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"Click Pop (Medium 2)" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &touchUpSoundID);
    });
    AudioServicesPlaySystemSound(touchUpSoundID);
}

-(void)playTouchNewHourSound {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSString *path  = [[NSBundle mainBundle] pathForResource:@"soundeffect" ofType:@"wav"];
//        NSURL *pathURL = [NSURL fileURLWithPath:path];
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &touchNewHourSoundID);
//    });
//    AudioServicesPlaySystemSound(touchNewHourSoundID);
}

-(void)playTouchNewEventSound {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"Click Pop (Subtle 1)" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &touchNewEventSoundID);
    });
    AudioServicesPlaySystemSound(touchNewEventSoundID);
}

-(void)playPullMenuOutSound {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"Pull Down (Light)" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &pullMenuOutSoundID);
    });
    AudioServicesPlaySystemSound(pullMenuOutSoundID);
}

-(void)playPushMenuInSound {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"Pull Down (Light)" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &pushMenuInSoundID);
    });
    AudioServicesPlaySystemSound(pushMenuInSoundID);
}

@end
