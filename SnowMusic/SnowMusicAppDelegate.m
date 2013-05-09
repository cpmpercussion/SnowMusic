//
//  SnowMusicAppDelegate.m
//  SnowMusic
//
//  Created by Charles Martin on 11/02/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import "SnowMusicAppDelegate.h"
#import "SnowMusicViewController.h"

#import "PGMidi.h"
#import "PGArc.h"

@implementation SnowMusicAppDelegate

@synthesize window = _window;
@synthesize viewController = viewController_;
@synthesize audioController = _audioController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.idleTimerDisabled = YES; // we don't want the screen to sleep.
    self.viewController = (SnowMusicViewController *) self.window.rootViewController;
    
    _audioController = [[PdAudioController alloc] init];
    
    if([self.audioController configurePlaybackWithSampleRate:22050 numberChannels:2 inputEnabled:NO mixingEnabled:NO] != PdAudioOK) {
        NSLog(@"failed to initialise audioController");
    }
    
    [PdBase setDelegate:self];

    
    //[self.audioController configureTicksPerBuffer:128];
	[PdBase openFile:@"snowapp2.pd" path:[[NSBundle mainBundle] resourcePath]];
	[self.audioController setActive:YES];
	[self.audioController print];
    
    //Configure MIDI
    midi = [[PGMidi alloc] init];
    midi.networkEnabled = YES;
    self.viewController.midi = midi;
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
