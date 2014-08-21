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

#define HARDCORE_SWITCH_HIDING NO

#define OSC_LOGGING @YES
#define SNOWMUSIC_SNOW_MODE 0
#define SNOWMUSIC_NOTE_MODE 1
#define NEWIDEA_LIMIT 10

#define CLUSTERVOLUME @"clusterVolume"
#define CYMBALVOLUME @"cymbalVolume"
#define SNOWVOLUME @"snowVolume"
#define CROTALEVOLUME @"crotaleVolume"
#define SNOWTRIGGERED @"snowTriggered"
#define CYMBALTRIGGERED @"cymbalTriggered"
#define CLUSTERTRIGGERED @"clusterTriggered"

#define ASSIST_STATE_NOTHING 0
#define ASSIST_STATE_ASSISTING 1

#define SCREENCENTER 646.049533705

#define TAP_GESTURES @[@"ft",@"st",@"c"]
#define SWIPE_GESTURES @[@"fs",@"fsa"]
#define SWIRL_GESTURES @[@"ss",@"bs",@"vss"]


#define GESTURE_GROUPS @{@"n":@0,@"ft":@1,@"st":@1,@"c":@1,@"fs":@2,@"fsa":@2,@"ss":@3,@"bs":@3,@"vss":@3}

@interface UITouch (Private)
-(float)_pathMajorRadius;
@end

@interface SnowMusicViewController () <PGMidiDelegate, PGMidiSourceDelegate>
@property (strong,nonatomic) MetatoneNetworkManager *networkManager;
@property (nonatomic) float distanceToCentre;
@end

@implementation SnowMusicViewController

- (void)receiveBangFromSource:(NSString *)source {
    NSLog(@"PD BANG: %@",source);
}

- (void)receiveList:(NSArray *)list fromSource:(NSString *)source {
    NSLog(@"PD LIST: %@",source);

}

- (void)receiveFloat:(float)received fromSource:(NSString *)source {
    NSLog(@"PD FLOAT: %@ - %f",source,received);
    [self.touchView drawGenerativeNoteOfType:source];
}

- (void)receiveMessage:(NSString *)message withArguments:(NSArray *)arguments fromSource:(NSString *)source {
    NSLog(@"PD string: %@",source);

}

- (void)receivePrint:(NSString *)message {
//    NSLog(@"PD print: %@",message);

}

- (void)receiveSymbol:(NSString *)symbol fromSource:(NSString *)source {
    NSLog(@"PD symbol: %@",source);
}

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
    //self.tapMode = SNOWMUSIC_NOTE_MODE;
    self.oscLogging = OSC_LOGGING;
    self.sameGestureCount = 0;
    self.newIdeaNumber = 0;
    [self setupOscLogging];
    
//    [self.clustersOn setHidden:YES];
    [self.distanceLabel setHidden:YES];
    [self.cymbalSwitchLabel setHidden:NO];
    [self.snowSwitchLabel setHidden:NO];
    [self.clusterSwitchLabel setHidden:NO];
    [self.midiLabel setHidden:YES];
    [self.midiInterfaceLabel setHidden:YES];
    
    [PdBase setDelegate:self];
    [PdBase subscribe:CLUSTERTRIGGERED];
    [PdBase subscribe:SNOWTRIGGERED];
    [PdBase subscribe:CYMBALTRIGGERED];
    
    self.distanceToCentre = SCREENCENTER;
    self.gestureAssistState = ASSIST_STATE_NOTHING;
    self.gestureAssistGesture = @"n";
    self.gestureAssistGroup = @[@"n"];
    self.lastGestureClass = @0;
    self.lastGesture = @"n";
}

-(CGFloat)calculateDistanceFromCenter:(CGPoint)touchPoint {
    CGFloat xDist = (touchPoint.x - self.view.center.y);
    CGFloat yDist = (touchPoint.y - self.view.center.x);
    return sqrt((xDist * xDist) + (yDist * yDist));
}


-(void) hideSwitches {
    [self.cymbalSwitchLabel setHidden:YES];
    [self.snowSwitchLabel setHidden:YES];
    [self.clusterSwitchLabel setHidden:YES];
    [self.clustersOn setHidden:YES];
    [self.backgroundSwitch setHidden:YES];
    [self.snowSwitch setHidden:YES];
}

-(void) disableSwitches {
    NSLog(@"Switches Disabled");
    [self.cymbalSwitchLabel setHidden:YES];
    [self.snowSwitchLabel setHidden:YES];
    [self.clusterSwitchLabel setHidden:YES];
    [self.clustersOn setUserInteractionEnabled:NO];
    [self.backgroundSwitch setUserInteractionEnabled:NO];
    [self.snowSwitch setUserInteractionEnabled:NO];
}

-(void) showSwitches {
    [self.cymbalSwitchLabel setHidden:NO];
    [self.snowSwitchLabel setHidden:NO];
    [self.clusterSwitchLabel setHidden:NO];
    [self.clustersOn setHidden:NO];
    [self.backgroundSwitch setHidden:NO];
    [self.snowSwitch setHidden:NO];
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
    
    [self.touchView drawTouchCircleAt:touchPoint];
    
    CGFloat ratioToCentre = [self calculateDistanceFromCenter:touchPoint] / self.distanceToCentre;
    CGFloat distance = ratioToCentre;
    int sliceToPlay = floorf(100 * ratioToCentre);
//    NSLog(@"Next Slice to Play: %d",sliceToPlay);

    // velocity from touch point
    int velocity = floorf(15 + (((touch._pathMajorRadius - 5.0)/16) * 115));
    if (velocity > 127) velocity = 127;
    if (velocity < 0) velocity = 0;
    
    // Send to Pd
    if (self.tapMode == SNOWMUSIC_NOTE_MODE) {
        if (self.newIdeaNumber > 0) {
            distance = distance / self.newIdeaNumber;
        }
    }
    
    
    
    [PdBase sendBangToReceiver:@"touch" ]; // makes a small sound
    [PdBase sendFloat:sliceToPlay toReceiver:@"snowStepSlice"];
    [PdBase sendFloat:distance toReceiver:@"tapdistance" ];
    
    if (self.oscLogging) [self.networkManager sendMessageWithTouch:touchPoint Velocity:0.0]; // osc logging
    
    [self.distanceLabel setText:[NSString stringWithFormat:@"Volume: %.2f", ((distance * 0.8) + 0.2)]];
    
    if (self.tapMode == SNOWMUSIC_NOTE_MODE) {
        [self sendMidiNoteFromPoint:touchPoint withVelocity:velocity];
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
    
    [self.touchView drawMovingTouchCircleAt:[touch locationInView:self.view]];
    
    // send vel to pd program
    [PdBase sendFloat:velocity toReceiver:@"touchvelocity" ];
    self.distanceLabel.text = [[NSString alloc] initWithFormat:@"Volume: %.2f", ((velocity * 0.07) + 0.1)];
    
    if (self.oscLogging) [self.networkManager sendMessageWithTouch:[touch locationInView:self.view] Velocity:velocity];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [PdBase sendBangToReceiver:@"touchended" ];
    if (self.oscLogging) [self.networkManager sendMessageTouchEnded];
    
    [self.touchView hideMovingTouchCircle];
}

// Interface responders

- (IBAction)backgroundsOn:(UISwitch *)sender {
    float value = (sender.on) ? 1 : 0;
    [PdBase sendFloat:value toReceiver:@"cymbalSwitch"];
    if (self.oscLogging) [self.networkManager sendMesssageSwitch:@"fieldsOn" On:sender.on];
}

- (IBAction)clustersSwitched:(UISwitch *)sender {
    float value = (sender.on) ? 1 : 0;
    [PdBase sendFloat:value toReceiver:@"clusterSwitch"];
    if (self.oscLogging) [self.networkManager sendMesssageSwitch:@"clusterSwitch" On:sender.on];
}

- (IBAction)snowSwitched:(UISwitch *)sender {
    float value = (sender.on) ? 1 : 0;
    [PdBase sendFloat:value toReceiver:@"snowSwitch"];
    if (self.oscLogging) [self.networkManager sendMesssageSwitch:@"snowSwitch" On:sender.on];
    
//    if (self.snowSwitch.on)
//    {
//        self.tapMode = SNOWMUSIC_NOTE_MODE;
//    } else {
//        self.tapMode = SNOWMUSIC_SNOW_MODE;
//    }    
}

#pragma mark - Note Methods
-(void)sendMidiNoteFromPoint:(CGPoint) point withVelocity:(int) vel {
    CGFloat distance = [self calculateDistanceFromCenter:point]/600;
    int velocity = ((int) 25 + 100 * (point.y / 800));
    velocity = (int) (velocity * 0.2) + (vel * 0.8);
    int note = (int) (distance * 35);
    
//    note = [ScaleMaker mixolydian:36 + (self.newIdeaNumber * 3) withNote:note];
    note = [ScaleMaker mixolydian:36 + (self.newIdeaNumber) withNote:note];
    [PdBase sendNoteOn:1 pitch:note velocity:velocity];
}

-(void)changeTapMode {
    if (self.tapMode == SNOWMUSIC_NOTE_MODE) {
        self.tapMode = SNOWMUSIC_SNOW_MODE;
    } else {
        self.tapMode = SNOWMUSIC_NOTE_MODE;
    }
    NSLog(@"Tap Mode Changed to %d", self.tapMode);
}

-(void)changeTapModeTo: (int) newTapMode {
    self.tapMode = newTapMode;
    NSLog(@"Tap Mode Changed to %d", self.tapMode);
}

#pragma mark - Network

- (void)setupOscLogging
{
    self.networkManager = [[MetatoneNetworkManager alloc] initWithDelegate:self shouldOscLog:self.oscLogging];
    if (!self.networkManager) {
        self.oscLogging = NO;
        [self.midiInterfaceLabel setHidden:NO];
        [self.midiInterfaceLabel setText:@"not classifying! 😰"];
        NSLog(@"OSC Logging: Not Connected");
        [self showSwitches];
    }
}

-(void)stopOscLogging
{
    [self.networkManager stopSearches];
}

- (void) searchingForLoggingServer {
    if (self.oscLogging) {
        [self.midiInterfaceLabel setHidden:NO];
        [self.midiInterfaceLabel setText:@"searching for classifier 😒"];
        [self showSwitches];
    }
}

-(void) loggingServerFoundWithAddress:(NSString *)address andPort:(int)port andHostname:(NSString *)hostname {
    [self.midiInterfaceLabel setHidden:NO];
    [self.midiInterfaceLabel setText:[NSString stringWithFormat:@"connected to %@ 👍", hostname]];
    
    if (HARDCORE_SWITCH_HIDING) {
        [self hideSwitches];
    } else {
        NSLog(@"Disabling switches...");
        [self disableSwitches];
    }
}

-(void) stoppedSearchingForLoggingServer {
    if (self.oscLogging) {
        [self.midiInterfaceLabel setHidden:NO];
        [self.midiInterfaceLabel setText: @"classifier not found! 😰"];
        [self showSwitches];
    }
}

-(void) didReceiveMetatoneMessageFrom:(NSString *)device withName:(NSString *)name andState:(NSString *)state {}


-(void)didReceiveGestureMessageFor:(NSString *)device withClass:(NSString *)class {
    NSLog(@"Gesture: %@",class);
    
    // Can this count somehow work with the gesture classes instead??
    
//    if ([class isEqualToString:self.lastGesture]) {
//        self.sameGestureCount++;
//    } else {
//        self.sameGestureCount = 0;
//    }
    if ([[GESTURE_GROUPS objectForKey:class] isEqualToNumber:self.lastGestureClass]) {
        self.sameGestureCount++;
        NSLog(@"Same Gesture Inc: %d",self.sameGestureCount);
    } else {
        self.sameGestureCount = 0;
        NSLog(@"Same Gesture reset 0");
    }
    
    
    if (self.sameGestureCount > 2) {
        // Possible start or stop of gesture assist.
        NSLog(@"ASSIST: possible gesture change");
        
        if (![self.gestureAssistGroup containsObject:class]) {
            // new gesture focus, turn off assist.
            NSLog(@"ASSIST: New gesture focus, turn off assist.");
            [self allBackgroundsOff];
            self.gestureAssistState = ASSIST_STATE_NOTHING;
            self.gestureAssistGesture = @"n";
            self.gestureAssistGroup = @[@"n"];
        }
        
        if (arc4random_uniform(100)>65) {
            NSLog(@"ASSIST: going to assist with new gesture");
            // OK let's assist
            self.sameGestureCount = 0;
            self.gestureAssistGesture = class;
            
            
            if ([TAP_GESTURES containsObject:class]) {
                self.gestureAssistState = ASSIST_STATE_ASSISTING;
                NSLog(@"ASSIST: Assisting with Tap Gestures.");
                self.gestureAssistGroup = TAP_GESTURES;
                if (arc4random_uniform(10)>5) {
                    self.tapMode = SNOWMUSIC_NOTE_MODE;
                } else {
                    [self.clustersOn setOn:YES animated:YES];
                    [self clustersSwitched:self.clustersOn];
                }
            }
            
            if ([SWIRL_GESTURES containsObject:class]) {
                self.gestureAssistState = ASSIST_STATE_ASSISTING;
                NSLog(@"ASSIST: Assisting with swirl Gestures.");
                self.gestureAssistGroup = SWIRL_GESTURES;
                
                if (arc4random_uniform(10)>5) {
                    [self.snowSwitch setOn:YES animated:YES];
                    [self snowSwitched:self.snowSwitch];
                } else {
                    [self.clustersOn setOn:YES animated:YES];
                    [self clustersSwitched:self.clustersOn];
                }
            }
            
            if ([SWIPE_GESTURES containsObject:class]) {
                self.gestureAssistState = ASSIST_STATE_ASSISTING;
                NSLog(@"ASSIST: Assisting with swipe Gestures.");
                self.gestureAssistGroup = SWIPE_GESTURES;
                
                if (arc4random_uniform(10)>5) {
                    [self.snowSwitch setOn:YES animated:YES];
                    [self snowSwitched:self.snowSwitch];
                } else {
                    [self.backgroundSwitch setOn:YES animated:YES];
                    [self backgroundsOn:self.backgroundSwitch];
                }
            }
            
            if ([class isEqualToString:@"n"]) {
                // N gesture gets nothing.
                NSLog(@"ASSIST: Not assisting with nil gesture");
                self.gestureAssistGesture = @"n";
                self.gestureAssistGroup = @[@"n"];
                [self allBackgroundsOff];
            }
        }
    }
    self.lastGesture = class;
    self.lastGestureClass = [GESTURE_GROUPS objectForKey:class];
}

-(void) allBackgroundsOff {
    [self.snowSwitch setOn:NO animated:YES];
    [self snowSwitched:self.snowSwitch];
    [self.backgroundSwitch setOn:NO animated:YES];
    [self backgroundsOn:self.backgroundSwitch];
    [self.clustersOn setOn:NO animated:YES];
    [self clustersSwitched:self.clustersOn];
    self.tapMode = SNOWMUSIC_SNOW_MODE;
}


-(void)didReceiveEnsembleState:(NSString *)state withSpread:(NSNumber *)spread withRatio:(NSNumber *)ratio {
    // use spread to balance the snow vs the background sounds.
}

-(void)didReceiveEnsembleEvent:(NSString *)event forDevice:(NSString *)device withMeasure:(NSNumber *)measure {
    // threshold starts at 10
    // 1 - 30
    // 2 - 50
    // 3 - 70
    // 4 - 90
    // 5 - 110
    
    
    int threshold = self.newIdeaNumber * floor(100 / NEWIDEA_LIMIT) + floor(50 / NEWIDEA_LIMIT);
    
    if (self.newIdeaNumber > NEWIDEA_LIMIT) {
        [self changeTapModeTo:SNOWMUSIC_NOTE_MODE];
    } else if (arc4random_uniform(100) < threshold) {
        [self changeTapModeTo:SNOWMUSIC_NOTE_MODE];
    } else {
        [self changeTapModeTo:SNOWMUSIC_SNOW_MODE];
    }

    NSLog(@"Threshold was: %d",threshold);
    self.newIdeaNumber++;
}


-(void) metatoneClientFoundWithAddress:(NSString *)address andPort:(int)port andHostname:(NSString *)hostname {}
-(void) metatoneClientRemovedwithAddress:(NSString *)address andPort:(int)port andHostname:(NSString *)hostname {}


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

// View type.

- (BOOL)prefersStatusBarHidden
{
    return YES;
}



@end






