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
    NSString *cipher;
    
    // "constants"
    NSArray *P;
    NSArray *IP;
    NSArray *IP_INVERSE;
    NSArray *EXPANSION;
    NSArray *PC1;
    NSArray *PC2;
    NSArray *LEFT_ROTATIONS;
    NSArray *SBOXES;
}

-(id)initWithKeyAndMessage: (NSString*)key
                            message: (NSString*) message;

-(id)initWithKeyAndCipher: (NSString*)key
                   cipherText: (NSString*) cipherText;

-(NSArray*) arrayOfBinaryNumbersForInt: (int) integer;

-(NSNumber*)binaryStringToDecimal: (NSString*) string;

-(void)generateSubkeys;
-(void)initNumbers;

-(NSArray*)permutate:  (NSArray*)message
                        permutation: (NSArray*) permutation;

-(NSString*)encrypt;
-(NSString*)decrypt;

-(NSArray*)xorTwoNSArrays: (NSArray*) first
                   second: (NSArray*) second;

-(NSArray*)deshi:   (NSArray*) chunk
                    type: (int) type;

static NSMutableArray *shiftArray(NSArray *array);

@end
