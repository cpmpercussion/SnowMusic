//
//  SnowMusicViewController.m
//  SnowMusic
//
//  Created by Charles Martin on 11/02/12.
//  Copyright (c) 2012 Charles Martin Percussion. All rights reserved.
//

#import "SnowMusicViewController.h"
//#import "SnowMusicAppDelegate.h"
//#import "PdBase.h"
#import "PGMidi.h"
#import <CoreMIDI/CoreMIDI.h>

@interface SnowMusicViewController () <PGMidiDelegate, PGMidiSourceDelegate>

@end

@implementation SnowMusicViewController

@synthesize cymbalSwitchLabel;
@synthesize clusterSwitchLabel;
@synthesize snowSwitchLabel;
@synthesize clustersOn;
@synthesize backgroundSwitch;
@synthesize distanceLabel;
@synthesize snowSwitch;
@synthesize midiLabel;
@synthesize midiInterfaceLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [backgroundSwitch setOn:NO];
    [clustersOn setOn:NO];
    [snowSwitch setOn:NO];
    [distanceLabel setText:@"Snow Music ready."];
    [cymbalSwitchLabel setText:@"Cymbals"];
    [clusterSwitchLabel setText:@"Bells"];
    [snowSwitchLabel setText:@"Snow"];
    [midiLabel setText:@""];
    [midiInterfaceLabel setText:@""];
}

- (void)viewDidUnload
{
    [PdBase setDelegate:nil];
    [self setDistanceLabel:nil];
    [self setBackgroundSwitch:nil];
    [self setClustersOn:nil];
    [self setSnowSwitch:nil];
    [self setCymbalSwitchLabel:nil];
    [self setClusterSwitchLabel:nil];
    [self setSnowSwitchLabel:nil];
    [self setMidiLabel:nil];
    [self setMidiInterfaceLabel:nil];
    [self setMidiLabel:nil];
    [self setMidiInterfaceLabel:nil];
    [super viewDidUnload];

    self.clustersOn = nil;
    self.backgroundSwitch = nil;
    self.distanceLabel = nil;
    self.snowSwitch = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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
    [PdBase sendBangToReceiver:@"touch" ]; // makes a small sound
    [PdBase sendFloat:distance toReceiver:@"tapdistance" ];
    
    self.distanceLabel.text = [[NSString alloc] initWithFormat:@"Volume: %.2f", ((distance * 0.8) + 0.2)];
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
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [PdBase sendBangToReceiver:@"touchended" ];
}

// Interface responders

- (IBAction)backgroundsOn:(id)sender {
    if (backgroundSwitch.on) 
    {
        [PdBase sendFloat:1 toReceiver:@"cymbalSwitch"];
    } else {
        [PdBase sendFloat:0 toReceiver:@"cymbalSwitch"];
    }
}
- (IBAction)clustersSwitched:(id)sender {
    if (clustersOn.on) 
    {
        [PdBase sendFloat:1 toReceiver:@"clusterSwitch"];
    } else {
        [PdBase sendFloat:0 toReceiver:@"clusterSwitch"];
    }
    
}
- (IBAction)snowSwitched:(id)sender {
    if (snowSwitch.on) 
    {
        [PdBase sendFloat:1 toReceiver:@"snowSwitch"];
    } else {
        [PdBase sendFloat:0 toReceiver:@"snowSwitch"];
    }    
}



#pragma mark Midi
//
// MIDI Responders
//

-(void) attachToAllExistingSources
{
    for (PGMidiSource *source in midi.sources)
    {
        [source addDelegate:self];
    }
}

-(void) setMidi:(PGMidi*)m
{
    midi.delegate = nil;
    midi = m;
    midi.delegate = self;
    
    [self attachToAllExistingSources];
}

-(void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
    [midiLabel setText:@"MIDI:"];
    [midiInterfaceLabel setText:source.name];
    [source addDelegate:self];
}

-(void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    [midiLabel setText:@""];
    [midiInterfaceLabel setText:@""];
    
}

-(void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination
{
    
}

-(void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
    
}


-(void) midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)packetList
{
    const MIDIPacket *packet = &packetList->packet[0];
    //
    // Cycle through midi packets and do the parsing.
    //
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        if ((packet->length == 3) && ((packet->data[0] & 0xf0) == 0x90) && (packet->data[2] != 0)) {
            [PdBase sendNoteOn:1 pitch:packet->data[1] velocity:packet->data[2]];
        }
        packet = MIDIPacketNext(packet);
    }
}

@end






