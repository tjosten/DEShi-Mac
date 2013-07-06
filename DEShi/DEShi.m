//
//  DEShi.m
//  DEShi
//
//  Created by Timo Josten on 06/07/13.
//  Copyright (c) 2013 Timo Josten. All rights reserved.
//

#import "DEShi.h"

@implementation DEShi

-(id)initWithKeyAndMessage: (NSString*)varKey
                   message: (NSString*) varMessage {
    if (self = [super init]) {
        
        //11, 15, 4, 13, 7, 9, 3, 2, 5, 14, 6, 10, 12, 1
        self->PC1 = [NSArray arrayWithObjects:  [NSNumber numberWithInt:11],
                                                [NSNumber numberWithInt:15],
                                                [NSNumber numberWithInt:4],
                                                [NSNumber numberWithInt:13],
                                                [NSNumber numberWithInt:7],
                                                [NSNumber numberWithInt:9],
                                                [NSNumber numberWithInt:3],
                                                [NSNumber numberWithInt:2],
                                                [NSNumber numberWithInt:5],
                                                [NSNumber numberWithInt:14],
                                                [NSNumber numberWithInt:6],
                                                [NSNumber numberWithInt:10],
                                                [NSNumber numberWithInt:12],
                                                [NSNumber numberWithInt:1],
                                                nil];
        
        //6, 11, 4, 8, 13, 3, 12, 5, 1, 10, 2, 9
        self->PC2 = [NSArray arrayWithObjects:  [NSNumber numberWithInt:6],
                                                [NSNumber numberWithInt:11],
                                                [NSNumber numberWithInt:4],
                                                [NSNumber numberWithInt:8],
                                                [NSNumber numberWithInt:13],
                                                [NSNumber numberWithInt:3],
                                                [NSNumber numberWithInt:12],
                                                [NSNumber numberWithInt:5],
                                                [NSNumber numberWithInt:1],
                                                [NSNumber numberWithInt:10],
                                                [NSNumber numberWithInt:2],
                                                [NSNumber numberWithInt:9],
                                                nil];
        
        //{1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1}
        self->LEFT_ROTATIONS = [NSArray arrayWithObjects:   [NSNumber numberWithInt:1],
                                                            [NSNumber numberWithInt:1],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:1],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:2],
                                                            [NSNumber numberWithInt:1],
                                                            nil];
        
        //{10, 6, 14, 2, 8, 16, 12, 4, 1, 13, 7, 9, 5, 11, 3, 15}
        self->IP = [NSArray arrayWithObjects:
                                [NSNumber numberWithInt:10],
                                [NSNumber numberWithInt:6],
                                [NSNumber numberWithInt:14],
                                [NSNumber numberWithInt:2],
                                [NSNumber numberWithInt:8],
                                [NSNumber numberWithInt:16],
                                [NSNumber numberWithInt:12],
                                [NSNumber numberWithInt:4],
                                [NSNumber numberWithInt:1],
                                [NSNumber numberWithInt:13],
                                [NSNumber numberWithInt:7],
                                [NSNumber numberWithInt:9],
                                [NSNumber numberWithInt:5],
                                [NSNumber numberWithInt:11],
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:15],
                                nil];
        
        //{9, 4, 15, 8, 13, 2, 11, 5, 12, 1, 14, 7, 10, 3, 16, 6}
        self->IP_INVERSE = [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:9],
                    [NSNumber numberWithInt:4],
                    [NSNumber numberWithInt:15],
                    [NSNumber numberWithInt:8],
                    [NSNumber numberWithInt:13],
                    [NSNumber numberWithInt:2],
                    [NSNumber numberWithInt:11],
                    [NSNumber numberWithInt:5],
                    [NSNumber numberWithInt:12],
                    [NSNumber numberWithInt:1],
                    [NSNumber numberWithInt:14],
                    [NSNumber numberWithInt:7],
                    [NSNumber numberWithInt:10],
                    [NSNumber numberWithInt:3],
                    [NSNumber numberWithInt:16],
                    [NSNumber numberWithInt:6],
                    nil];
        
        //{8, 1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 1}
        self->EXPANSION = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:8],
                            [NSNumber numberWithInt:1],
                            [NSNumber numberWithInt:2],
                            [NSNumber numberWithInt:3],
                            [NSNumber numberWithInt:4],
                            [NSNumber numberWithInt:5],
                            [NSNumber numberWithInt:4],
                            [NSNumber numberWithInt:5],
                            [NSNumber numberWithInt:6],
                            [NSNumber numberWithInt:7],
                            [NSNumber numberWithInt:8],
                            [NSNumber numberWithInt:1],
                            nil];
        
        /*int IP_[16] = {10, 6, 14, 2, 8, 16, 12, 4, 1, 13, 7, 9, 5, 11, 3, 15};
        int IP_INVERSE[16] = {9, 4, 15, 8, 13, 2, 11, 5, 12, 1, 14, 7, 10, 3, 16, 6};
        int EXPANSION[14] = {8, 1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 1};
        int P[8] = {6, 4, 7, 3, 5, 1, 8, 2};
        int PC2[14] = {6, 11, 4, 8, 13, 3, 12, 5, 1, 10, 2, 9};
        int LEFT_ROTATIONS[16] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};*/
        
        self->encKey = [varKey copy];
        self->message = [varMessage copy];
        
        NSLog(@"Initialized DEShi with key: %@, message: %@", self->encKey, self->message);
        
        // converting the key to binary notation
        NSMutableArray *keyBinaryTmp = [NSMutableArray arrayWithCapacity:([self->encKey length]*8)];
        size_t i;
        for (i = 0; i < [self->encKey length]; i++) {
            [keyBinaryTmp addObjectsFromArray:[self arrayOfBinaryNumbersForInt:[self->encKey characterAtIndex:i]]];
        }
        
        self->keyBinary = keyBinaryTmp;
        
        NSLog(@"Converted key to binary array: %@", self->keyBinary);
        
        self->subKeys = [NSMutableArray arrayWithCapacity:16];
        
        // generate subkeys
        [self generateSubkeys];
    }
    return (self);
}

-(NSArray*) arrayOfBinaryNumbersForInt: (int) integer {
    NSLog(@"%d", integer);
    
    NSMutableString *string = [NSMutableString string];
    for(NSInteger numberCopy = integer; numberCopy > 0; numberCopy >>= 1)
    {
        // Prepend "0" or "1", depending on the bit
        [string insertString:((numberCopy & 1) ? @"1," : @"0,") atIndex:0];
    }

    if ([string length]/2 != 8) {
        int requiredShifts = 8 - [string length]/2;
        for (size_t i = 0; i < requiredShifts; i++) {
            [string insertString: @"0," atIndex: 0];
        }
    }
    
    NSString *finalString = [NSString stringWithString:string];
    finalString = [finalString substringToIndex:([string length] - 1)];
    NSArray *result = [finalString componentsSeparatedByString:@","];
    NSLog(@"arrayOfBinaryNumbersForInt: %@", result);
    
    return (result);
}

-(NSArray*)permutate:  (NSArray *)message
                        permutation:(NSArray*)permutation{
    
    NSMutableArray *permutatedArray = [NSMutableArray arrayWithCapacity:[permutation count]];
    for (size_t i = 0; i < [permutation count]; i++) {
        NSNumber *newIndexNumber = [permutation objectAtIndex:i];
        int newIndex = [newIndexNumber intValue] - 1;
        [permutatedArray insertObject:[message objectAtIndex:newIndex] atIndex:i];
    }
    
    return permutatedArray;
}

-(void)generateSubkeys {
    
    self->subKeys = [[NSMutableArray alloc] initWithCapacity:16];
    
    NSArray *permutatedKey = [self permutate:self->keyBinary permutation:self->PC1];
    
    NSArray *leftPart = [permutatedKey subarrayWithRange:NSMakeRange(0, 7)];
    NSArray *rightPart = [permutatedKey subarrayWithRange:NSMakeRange(7, 7)];
    
    // calculate the 16 subkeys
    int i = 0;
    while (i < 16) {
        // left shifts
    
        NSInteger shifts = [[self->LEFT_ROTATIONS objectAtIndex: i] integerValue];
        
        NSLog(@"round %d", i);
        NSLog(@"before: L: %@ R: %@", leftPart, rightPart);
        
        int j = 0;
        while (j < shifts) {
            leftPart = shiftArray(leftPart);
            rightPart = shiftArray(rightPart);
            j++;
        }
    
        NSLog(@"after: L: %@ R: %@", leftPart, rightPart);
        
        NSArray *leftRight = [leftPart arrayByAddingObjectsFromArray: rightPart];
        
        NSLog(@"LR: %@", leftRight);
        
        [self->subKeys insertObject:[self permutate:leftRight permutation:self->PC2] atIndex:i];
        
        i++;
    }
    
    NSLog(@"1st subkey: %@", [self->subKeys objectAtIndex:0]);
}

-(NSString*) encrypt {
    
    NSMutableString *result = [NSMutableString string];
    
    // read the ascii message in blocks of 16 bit
    int i = 0;
    while (i < [self->message length]) {
        // convert parts of the ascii message to a bit array
    
        NSArray *firstArray = [self arrayOfBinaryNumbersForInt: [self->message characterAtIndex:i]];
        NSArray *secondArray = [firstArray arrayByAddingObjectsFromArray: [self arrayOfBinaryNumbersForInt:[self->message characterAtIndex:i+1]]];
        
        NSLog(@"--------------------- encryption ------------------------");
        NSLog(@"%@", secondArray);
        
        NSArray *data = [self permutate:secondArray permutation:self->IP];
        NSArray *encrypted_data = [self deshi:data type:0];
        
        i+=2;
    }
    
    return (result);
}

-(NSArray*) deshi:(NSArray *)chunk type:(int)type {
    
    int iterationNr;
    
    if (type == 0) {
        // encryption
        iterationNr = 0;
    } else {
        // decryption
        iterationNr = 15;
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:16];
    
    NSMutableArray *L = [chunk subarrayWithRange:NSMakeRange(0, 8)];
    NSMutableArray *R = [chunk subarrayWithRange:NSMakeRange(8, 8)];
    
    int i = 0;
    while (i < 16) {
        // the 16 rounds of DES
    
        NSMutableArray *tmpR = [R copy];
        
        R = [self permutate:R permutation:self->EXPANSION];
        
        NSArray *subkey = [self->subKeys objectAtIndex:iterationNr];
        
        // xor R with subkey
        R = [self xorTwoNSArrays:R second:subkey];
        
        NSLog(@"DESHI round %d, Xor'd R: %@", i, R);
        
        i++;
        
        if (type == 0) {
            // encryption
            iterationNr++;
        } else {
            // decryption
            iterationNr--;
        }
    }
    
    return (result);
}

-(NSArray*)xorTwoNSArrays:(NSArray *)first second:(NSArray *)second {
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[first count]];
    
    int j = 0;
    while (j < [first count]) {
        int xorResult = [[first objectAtIndex:j] integerValue] ^ [[second objectAtIndex:j] integerValue];
        [result insertObject:[NSNumber numberWithInt:xorResult] atIndex:j];
        j++;
    }
    
    return (result);
}

static NSMutableArray *shiftArray(NSArray *array)
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
    
    // pre: [1, 0, 1, 0, 1, 0, 1]
    //post: [0, 1, 0, 1, 0, 1, 1]
    
    // first, we have to remember the first digit
    NSNumber *first = [array objectAtIndex:0];
    
    // then, we have to move everything to the left, starting at object no. 2 (with index 1)
    for (size_t i = 1; i < [array count]; i++) {
        [result insertObject:[array objectAtIndex:i] atIndex:i-1];
    }
    
    // finally, set the last item to the formet first item
    [result insertObject:first atIndex:[array count]-1];
    
    return (result);
}

@end
