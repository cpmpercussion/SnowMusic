//
//  SnowMusicAppDelegate.h
//  SnowMusic
//
//  Created by Charles Martin on 11/02/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnowMusicViewController.h"
#import "PdAudioController.h"
#import "PDBase.h"

@class PGMidi;

@interface SnowMusicAppDelegate : UIResponder <UIApplicationDelegate, PdReceiverDelegate> {
    PGMidi *midi;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SnowMusicViewController *viewController;
@property (strong, nonatomic, readonly) PdAudioController *audioController;

@end
