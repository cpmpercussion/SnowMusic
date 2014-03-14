//
//  SnowMusicViewController.m
//  SnowMusic
//
//  Created by Charles Martin on 11/02/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import "SnowMusicViewController.h"
#import "PGMidi.h"
#import <CoreMIDI/CoreMIDI.h>

#define OSC_LOGGING @YES
#define SNOWMUSIC_SNOW_MODE 0
#define SNOWMUSIC_NOTE_MODE 1


@interface SnowMusicViewController () <PGMidiDelegate, PGMidiSourceDelegate>
@property (strong,nonatomic) MetatoneNetworkManager *networkManager;
@end

@implementation SnowMusicViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.backgroundSwitch setOn:NO];
    [self.clustersOn setOn:NO];
    [self.snowSwitch setOn:NO];
    [self.distanceLabel setText:@"Snow Music ready."];
    [self.cymbalSwitchLabel setText:@"Cymbals"];
    [self.clusterSwitchLabel setText:@"Bells"];
    [self.snowSwitchLabel setText:@"Snow"];
    [self.midiLabel setText:@""];
    [self.midiInterfaceLabel setText:@""];
    
    self.tapMode = SNOWMUSIC_SNOW_MODE;
    self.oscLogging = OSC_LOGGING;
    self.sameGestureCount = 0;
    [self setupOscLogging];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ((interfaceOrientation == UIInterfaceOrientationPortrait) | (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            return YES;
        } else {
            return NO;
        }
    } else {
        if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) | (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            return YES;
        } else {
            return NO;
        }
    }
}

#pragma mark - Touch
// probably use gesture recognisers for these items:
// really need:
//  - taps (snow taps)
//  - drags (snow drags)
//  - pinches (snow squishes)

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{   
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];  

    // calculate distance from the center
    CGFloat xDist = (touchPoint.x - self.view.center.x);
    CGFloat yDist = (touchPoint.y - self.view.center.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist)) / 600;

    // Send to Pd
    if (self.tapMode == SNOWMUSIC_SNOW_MODE) {
        distance = 0.5 * distance;
    }
    [PdBase sendBangToReceiver:@"touch" ]; // makes a small sound
    [PdBase sendFloat:distance toReceiver:@"tapdistance" ];
    
    if (self.oscLogging) [self.networkManager sendMessageWithTouch:touchPoint Velocity:0.0]; // osc logging
    
    self.distanceLabel.text = [[NSString alloc] initWithFormat:@"Volume: %.2f", ((distance * 0.8) + 0.2)];
    
    if (self.tapMode == SNOWMUSIC_NOTE_MODE) {
        //int vel = floor(128 * ((distance * 0.8) + 0.2));
        [self sendMidiNoteFromPoint:touchPoint withVelocity:120];
    }
}

-(void)touchesMoved:(NSSet *) touches withEvent:(UIEvent *)event
{
    // a moving touch.
    // take distance from center
    // take delta from previous location (proportional to velocity)
    UITouch *touch = [touches anyObject];
    CGFloat xVelocity = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x;
    CGFloat yVelocity = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
    CGFloat velocity = sqrt((xVelocity * xVelocity) + (yVelocity * yVelocity));
    
    // send vel to pd program
    [PdBase sendFloat:velocity toReceiver:@"touchvelocity" ];
    self.distanceLabel.text = [[NSString alloc] initWithFormat:@"Volume: %.2f", ((velocity * 0.07) + 0.1)];
    
    if (self.oscLogging) [self.networkManager sendMessageWithTouch:[touch locationInView:self.view] Velocity:velocity];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [PdBase sendBangToReceiver:@"touchended" ];
    if (self.oscLogging) [self.networkManager sendMessageTouchEnded];
}

// Interface responders

- (IBAction)backgroundsOn:(UISwitch *)sender {
    float value = (sender.on) ? 1 : 0;
    [PdBase sendFloat:value toReceiver:@"cymbalSwitch"];
    if (self.oscLogging) [self.networkManager sendMesssageSwitch:@"fieldsOn" On:sender.on];
//    if (self.backgroundSwitch.on)
//    {
//        [PdBase sendFloat:1 toReceiver:@"cymbalSwitch"];
//    } else {
//        [PdBase sendFloat:0 toReceiver:@"cymbalSwitch"];
//    }
}

- (IBAction)clustersSwitched:(UISwitch *)sender {
    float value = (sender.on) ? 1 : 0;
    [PdBase sendFloat:value toReceiver:@"clusterSwitch"];
    if (self.oscLogging) [self.networkManager sendMesssageSwitch:@"clusterSwitch" On:sender.on];
//    if (self.clustersOn.on)
//    {
//        [PdBase sendFloat:1 toReceiver:@"clusterSwitch"];
//    } else {
//        [PdBase sendFloat:0 toReceiver:@"clusterSwitch"];
//    }
}

- (IBAction)snowSwitched:(UISwitch *)sender {
    float value = (sender.on) ? 1 : 0;
    [PdBase sendFloat:value toReceiver:@"snowSwitch"];
    if (self.oscLogging) [self.networkManager sendMesssageSwitch:@"snowSwitch" On:sender.on];
//    if (self.snowSwitch.on)
//    {
//        [PdBase sendFloat:1 toReceiver:@"snowSwitch"];
//    } else {
//        [PdBase sendFloat:0 toReceiver:@"snowSwitch"];
//    }    
}

#pragma mark - Note Methods

-(void)sendMidiNoteFromPoint:(CGPoint) point withVelocity:(int) vel {
    CGFloat distance = [self calculateDistanceFromCenter:point]/600;
    int velocity = ((int) 25 + 100 * (point.y / 800));
    velocity = (int) (velocity * 0.2) + (vel * 0.8);
    int note = (int) (distance * 35);
    
    note = [ScaleMaker mixolydian:36 withNote:note];
    [PdBase sendNoteOn:1 pitch:note velocity:velocity];
}

-(CGFloat)calculateDistanceFromCenter:(CGPoint)touchPoint {
    CGFloat xDist = (touchPoint.x - self.view.center.y);
    CGFloat yDist = (touchPoint.y - self.view.center.x);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

-(void)changeTapMode {
    if (self.tapMode == SNOWMUSIC_NOTE_MODE) {
        self.tapMode = SNOWMUSIC_SNOW_MODE;
    } else {
        self.tapMode = SNOWMUSIC_NOTE_MODE;
    }
    NSLog(@"Tap Mode Changed to %d", self.tapMode);
}

#pragma mark - Network

- (void)setupOscLogging
{
    self.networkManager = [[MetatoneNetworkManager alloc] initWithDelegate:self shouldOscLog:self.oscLogging];
    if (!self.networkManager) {
        self.oscLogging = NO;
        [self.midiLabel setText:@"OSC:"];
        [self.midiInterfaceLabel setText:@"OSC Logging: Not Connected"];
        NSLog(@"OSC Logging: Not Connected");
    }
}

-(void)stopOscLogging
{
    [self.networkManager stopSearches];
}

- (void) searchingForLoggingServer {
    if (self.oscLogging) {
        [self.midiLabel setText:@"OSC"];
        [self.midiInterfaceLabel setText:@"Searching for Logging Server..."];
    }
}

-(void) loggingServerFoundWithAddress:(NSString *)address andPort:(int)port andHostname:(NSString *)hostname {
    [self.midiLabel setText:@"OSC"];
    [self.midiInterfaceLabel setText:[NSString stringWithFormat:@"Logging to %@\n %@:%d", hostname, address,port]];
}

-(void) stoppedSearchingForLoggingServer {
    if (self.oscLogging) {
        [self.midiLabel setText:@"OSC"];
        [self.midiInterfaceLabel setText: @"Logging Server Not Found!"];
    }
}

-(void) didReceiveMetatoneMessageFrom:(NSString *)device withName:(NSString *)name andState:(NSString *)state {}

-(void)didReceiveGestureMessageFor:(NSString *)device withClass:(NSString *)class {
    if ([class isEqualToString:self.lastGesture]) {
        self.sameGestureCount++;
    } else {
        self.sameGestureCount = 0;
    }
    
    if (self.sameGestureCount > 3 && arc4random_uniform(100)>85) {
        self.sameGestureCount = 0;
        if (arc4random_uniform(10)>5) {
            [self.snowSwitch setOn:!self.snowSwitch.on animated:YES];
            [self snowSwitched:self.snowSwitch];
            NSLog(@"Loops Changed by Classifier");
        } else {
            [self.backgroundSwitch setOn:!self.backgroundSwitch.on animated:YES];
            [self backgroundsOn:self.backgroundSwitch];
            NSLog(@"Fields Changed by Classifier");
        }
    }
    self.lastGesture = class;
}

-(void)didReceiveEnsembleState:(NSString *)state withSpread:(NSNumber *)spread withRatio:(NSNumber *)ratio {
    
}

-(void)didReceiveEnsembleEvent:(NSString *)event forDevice:(NSString *)device withMeasure:(NSNumber *)measure {
    if (arc4random_uniform(100)>50) {
        [self changeTapMode];
        NSLog(@"Ensemble Event Received: Reset.");
    } else {
        NSLog(@"Ensemble Event Received: No Action.");
    }
}

#pragma mark Midi
-(void) attachToAllExistingSources
{
    for (PGMidiSource *source in self.midi.sources)
    {
        [source addDelegate:self];
    }
}

-(void) setMidi:(PGMidi*)m {
    _midi = m;
    self.midi.delegate = self;
    [self attachToAllExistingSources];
}

-(void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source {
    [self.midiLabel setText:@"MIDI:"];
    [self.midiInterfaceLabel setText:source.name];
    [source addDelegate:self];
}

-(void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source {
    [self.midiLabel setText:@""];
    [self.midiInterfaceLabel setText:@""];
}

-(void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination{}

-(void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination {}


-(void) midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)packetList
{
    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i) {
        if ((packet->length == 3) && ((packet->data[0] & 0xf0) == 0x90) && (packet->data[2] != 0)) {
            [PdBase sendNoteOn:1 pitch:packet->data[1] velocity:packet->data[2]];
        }
        packet = MIDIPacketNext(packet);
    }
}


@end






