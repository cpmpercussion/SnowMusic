//
//  MetatoneTouchView.m
//  Metatone
//
//  Created by Charles Martin on 17/04/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//  Modified 18/7/2014 for Snow Music

#import "MetatoneTouchView.h"
#import <QuartzCore/QuartzCore.h>

#define SNOWTRIGGERED @"snowTriggered"
#define CYMBALTRIGGERED @"cymbalTriggered"
#define CLUSTERTRIGGERED @"clusterTriggered"

@interface MetatoneTouchView()

@property (strong, nonatomic) UIImage *lastFrame;
@property (strong, nonatomic) UIColor *touchColour;
@property (strong, nonatomic) UIColor *loopColour;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSDictionary *generativeColours;

@end

@implementation MetatoneTouchView

- (NSMutableArray *) touchCirclePoints {
    if (!_touchCirclePoints) _touchCirclePoints = [[NSMutableArray alloc] init];
    return _touchCirclePoints;
}

- (NSMutableArray *)noteCirclePoints {
    if (!_noteCirclePoints) _noteCirclePoints = [[NSMutableArray alloc] init];
    return _noteCirclePoints;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.generativeColours = @{SNOWTRIGGERED: [UIColor colorWithRed:0.69 green:0.784 blue:0.894 alpha:0.8],
                                       CLUSTERTRIGGERED: [UIColor colorWithRed:0.356 green:0.631 blue:0.827 alpha:0.8],
                                       CYMBALTRIGGERED: [UIColor colorWithRed:0.952 green:0.862 blue:0.709 alpha:0.8]};
        
        self.deviceID = [[UIDevice currentDevice].identifierForVendor UUIDString];
        if ([self.deviceID isEqual:@"1D7BCDC1-5AAB-441B-9C92-C3F00B6FF930"]) {
            self.touchColour = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.8];
        } else if ([self.deviceID isEqual:@"6769FE40-5F64-455B-82D4-814E26986A99"]) {
            self.touchColour = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:0.8];
        } else if ([self.deviceID isEqual:@"2678456D-9AE7-4DCC-A561-688A4766C325"]) {
            self.touchColour = [UIColor colorWithRed:0.1 green:0.9 blue:0.4 alpha:0.8];
        } else if ([self.deviceID isEqual:@"97F37307-2A95-4796-BAC9-935BF417AC42"]) {
            self.touchColour = [UIColor colorWithRed:0.9 green:0.8 blue:0.1 alpha:0.8];
        } else {
            self.touchColour = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        }
        self.loopColour = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.8];

        // init code.
        self.movingTouchCircleLayer = [self makeCircleLayerWithColour:self.touchColour];
        [self.layer addSublayer:self.movingTouchCircleLayer];
        self.movingTouchCircleLayer.hidden = YES;
        [self.layer addSublayer:self.touchCirclesLayer];
        self.touchCirclesLayer.hidden = NO;
        [self.layer addSublayer:self.loopCirclesLayer];
        self.loopCirclesLayer.hidden = NO;
        NSLog(@"Metatone Touch View Loaded");
    }
    return self;
}

- (void)drawGenerativeNoteOfType:(NSString *)type {
    UIColor *colour = [self.generativeColours valueForKey:type];
    if (!colour) colour = self.loopColour;
    CALayer *layer = [self makeCircleLayerWithColour:colour];
    [self.layer addSublayer:layer];
    [self.noteCirclePoints addObject:layer];
    
    [CATransaction setAnimationDuration:0.0];
//    CGFloat newX = arc4random_uniform(1024);
//    CGFloat newY = arc4random_uniform(768);
    
    CGFloat newX = arc4random_uniform(self.bounds.size.width);
    CGFloat newY = arc4random_uniform(self.bounds.size.height);
    
    layer.position = CGPointMake(newX, newY);
    layer.hidden = NO;
    
    float scaleFactor = 1.3 + arc4random_uniform(100)/33;
    
    CABasicAnimation *expand = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    expand.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    expand.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)];
    expand.duration = 2.0;
    [layer addAnimation:expand forKey:@"expandAnimation"];

    
    [CATransaction setCompletionBlock:^{
        [CATransaction setCompletionBlock:^{
            [self.noteCirclePoints removeObject:layer];
            [layer removeFromSuperlayer];
        }];
        [CATransaction setAnimationDuration:3.0];
        layer.hidden = YES;
    }];
}


-(void) drawTouchCircleAt:(CGPoint) point {
    CALayer *layer = [self makeCircleLayerWithColour:self.touchColour];
    [self.layer addSublayer:layer];
    [self.touchCirclePoints addObject:layer];
    
    CABasicAnimation *expand = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    expand.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    expand.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)];
    expand.duration = 2.0;
    [layer addAnimation:expand forKey:@"expandAnimation"];
    
    [CATransaction setAnimationDuration:0.0];
    layer.position = point;
    layer.hidden = NO;
    [CATransaction setCompletionBlock:^{
        [CATransaction setCompletionBlock:^{
            [layer removeFromSuperlayer];
            [self.touchCirclePoints removeObject:layer];
        }];
        [CATransaction setAnimationDuration:2.0];
        layer.hidden = YES;
    }];
}


-(void) drawNoteCircleAt:(CGPoint) point {
    CALayer *layer = [self makeCircleLayerWithColour:self.loopColour];
    //[self.loopCirclesLayer addSublayer:layer];
    [self.layer addSublayer:layer];
    [self.noteCirclePoints addObject:layer];
    
    [CATransaction setAnimationDuration:0.0];
    layer.position = point;
    layer.hidden = NO;
    [CATransaction setCompletionBlock:^{
        [CATransaction setCompletionBlock:^{
            [self.noteCirclePoints removeObject:layer];
            [layer removeFromSuperlayer];
        }];
        [CATransaction setAnimationDuration:2.0];
        layer.hidden = YES;
    }];
}

-(CALayer *) makeCircleLayerWithColour:(UIColor *) colour {
    CALayer *layer = [[CALayer alloc] init];
    
    layer.backgroundColor = colour.CGColor;
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.shadowRadius = 5.0;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.8;
    layer.frame = CGRectMake(0, 0, 50, 50);
    layer.cornerRadius = 25.0;
    layer.hidden = YES;
    return layer;
}

-(void) drawMovingTouchCircleAt:(CGPoint)point {
    [CATransaction setAnimationDuration:0.0];
    self.movingTouchCircleLayer.position = point;
    self.movingTouchCircleLayer.hidden = NO;
}

-(void) hideMovingTouchCircle {
    [CATransaction setAnimationDuration:1.0];
    self.movingTouchCircleLayer.hidden = YES;
}

@end
