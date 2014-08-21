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

void arraysize_setup();

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.idleTimerDisabled = YES; // we don't want the screen to sleep.
    self.viewController = (SnowMusicViewController *) self.window.rootViewController;
    self.audioController = [[PdAudioController alloc] init];
    
    if([self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:NO mixingEnabled:NO] != PdAudioOK) {
        NSLog(@"failed to initialise audioController");
    }
    arraysize_setup();
	[PdBase openFile:@"snowapp2.pd" path:[[NSBundle mainBundle] resourcePath]];
	[self.audioController setActive:YES];
	[self.audioController print];
    
    //Configure MIDI
    midi = [[PGMidi alloc] init];
    midi.networkEnabled = YES;
    self.viewController.midi = midi;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application
{}

- (void)applicationWillEnterForeground:(UIApplication *)application
{}

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
