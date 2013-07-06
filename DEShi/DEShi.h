//
//  DEShi.h
//  DEShi
//
//  Created by Timo Josten on 06/07/13.
//  Copyright (c) 2013 Timo Josten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DEShi : NSObject {
    NSString *encKey;
    NSString *message;
    NSArray *keyBinary;
    NSMutableArray *subKeys;
    
    // "constants"
    /*int *IP[16];
    int *IP_INVERSE[16];
    int *EXPANSION[12];
    int *P[8];
    int *PC1[14];
    int *PC2[14];
    int *LEFT_ROTATIONS[16];*/
    
    NSArray *IP;
    NSArray *IP_INVERSE;
    NSArray *EXPANSION;
    NSArray *PC1;
    NSArray *PC2;
    NSArray *LEFT_ROTATIONS;
}

-(id)initWithKeyAndMessage: (NSString*)key
                            message: (NSString*) message;

-(NSArray*) arrayOfBinaryNumbersForInt: (int) integer;

-(void)generateSubkeys;

-(NSArray*)permutate:  (NSArray*)message
                        permutation: (NSArray*) permutation;

-(NSString*)encrypt;
-(NSArray*)xorTwoNSArrays: (NSArray*) first
                   second: (NSArray*) second;

-(NSArray*)deshi:   (NSArray*) chunk
                    type: (int) type;

static NSMutableArray *shiftArray(NSArray *array);

@end
