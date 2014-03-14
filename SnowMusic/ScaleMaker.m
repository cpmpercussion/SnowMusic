//
//  ScaleMaker.m
//  Metatone ENP
//
//  Created by Charles Martin on 6/07/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//

#import "ScaleMaker.h"

#define DEGREE @[@1,@2,@3,@4,@5,@6,@7]
#define LYDFIVE @[@0,@2,@4,@6,@8,@9,@11]
#define LYDIAN @[@0,@2,@4,@6,@7,@9,@11]
#define MAJOR @[@0,@2,@4,@5,@7,@9,@11]
#define MIXOLYDIAN @[@0,@2,@4,@5,@7,@9,@10]
#define DORIAN @[@0,@2,@3,@5,@7,@9,@10]
#define MINOR @[@0,@2,@3,@5,@7,@8,@10]
#define PHRYGIAN @[@0,@1,@3,@5,@7,@8,@10]
#define LOCHRIAN @[@0,@1,@3,@5,@6,@8,@10]

@implementation ScaleMaker

+(int)lydianSharpFive:(int)base withNote:(int)note {
    NSArray *scale = LYDFIVE;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return (octave * 12) + scalenote + base;
}

+(int)lydian:(int)base withNote:(int)note {
    NSArray *scale = LYDIAN;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)major:(int)base withNote:(int)note {
    NSArray *scale = MAJOR;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)dorian:(int)base withNote:(int)note {
    NSArray *scale = DORIAN;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)mixolydian:(int)base withNote:(int)note {
    NSArray *scale = MIXOLYDIAN;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)aeolian:(int)base withNote:(int)note {
    NSArray *scale = MINOR;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)phrygian:(int)base withNote:(int)note {
    NSArray *scale = PHRYGIAN;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}


+(int)lochrian:(int)base withNote:(int)note {
    NSArray *scale = @[@0,@1,@3,@5,@6,@8,@10];
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

@end
