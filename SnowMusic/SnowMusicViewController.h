//
//  SnowMusicViewController.h
//  SnowMusic
//
//  Created by Charles Martin on 11/02/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PdDispatcher.h"

@class PGMidi;

@interface SnowMusicViewController : UIViewController {
    void *patch;
    
    PGMidi *midi;
}

@property (nonatomic, assign) PGMidi *midi;

@property (retain, nonatomic) IBOutlet UISwitch *clustersOn;
- (IBAction)clustersSwitched:(id)sender;
@property (retain, nonatomic) IBOutlet UISwitch *backgroundSwitch;
- (IBAction)backgroundsOn:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *distanceLabel;
@property (retain, nonatomic) IBOutlet UISwitch *snowSwitch;
- (IBAction)snowSwitched:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *cymbalSwitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *clusterSwitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *snowSwitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *midiLabel;
@property (weak, nonatomic) IBOutlet UILabel *midiInterfaceLabel;

@end
