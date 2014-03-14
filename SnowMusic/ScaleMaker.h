//
//  ScaleMaker.h
//  Metatone ENP
//
//  Created by Charles Martin on 6/07/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScaleMaker : NSObject

+(int) lochrian:(int)base withNote:(int)note;
+(int) phrygian:(int)base withNote:(int)note;
+(int) aeolian:(int)base withNote:(int)note;
+(int) dorian:(int)base withNote:(int)note;
+(int) mixolydian:(int)base withNote:(int)note;
+(int) major:(int)base withNote:(int)note;
+(int) lydian:(int)base withNote:(int)note;
+(int) lydianSharpFive:(int)base withNote:(int)note;

@end
