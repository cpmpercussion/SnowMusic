//
//  SnowMusicViewController.h
//  SnowMusic
//
//  Created by Charles Martin on 11/02/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDBase.h"
#import "MetatoneNetworkManager.h"
#import "ScaleMaker.h"
#import "MetatoneTouchView.h"

@class PGMidi;

@interface SnowMusicViewController : UIViewController <MetatoneNetworkManagerDelegate, PdReceiverDelegate> {}

@property (weak, nonatomic) PGMidi *midi;
@property (weak, nonatomic) IBOutlet UISwitch *clustersOn;
@property (weak, nonatomic) IBOutlet UISwitch *backgroundSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *snowSwitch;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cymbalSwitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *clusterSwitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *snowSwitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *midiLabel;
@property (weak, nonatomic) IBOutlet UILabel *midiInterfaceLabel;
@property (weak, nonatomic) IBOutlet MetatoneTouchView *touchView;

@property (nonatomic) bool oscLogging;
@property (nonatomic) int scaleMode;
@property (nonatomic) int tapMode;
@property (nonatomic) int newIdeaNumber;

@property (nonatomic) int sameGestureCount;
@property (strong, nonatomic) NSString *lastGesture;
@property (nonatomic) int gestureAssistState;
@property (strong, nonatomic) NSString* gestureAssistGesture;
@property (strong, nonatomic) NSArray* gestureAssistGroup;

- (IBAction)snowSwitched:(UISwitch *)sender;
- (IBAction)backgroundsOn:(UISwitch *)sender;
- (IBAction)clustersSwitched:(UISwitch *)sender;
- (void)setupOscLogging;
- (void)stopOscLogging;

- (void)receiveBangFromSource:(NSString *)source;



@end
