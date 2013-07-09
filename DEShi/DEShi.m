//
//  DEShi.m
//  DEShi
//
//  Created by Timo Josten on 06/07/13.
//  Copyright (c) 2013 Timo Josten. All rights reserved.
//

#import "DEShi.h"

@implementation DEShi

// "constructor" for encryption
-(id)initWithKeyAndMessage: (NSString*)varKey
                   message: (NSString*) varMessage {
    if (self = [super init]) {
        
        // initialize numbers required for crypto stuff
        [self initNumbers];
        
        // setting instance variables
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
    
        // initializing subkeys instance array
        self->subKeys = [NSMutableArray arrayWithCapacity:16];
        
        // generate subkeys
        [self generateSubkeys];
    }
    return (self);
}

// "constructor" for decryption
-(id)initWithKeyAndCipher: (NSString*)varKey
                   cipherText: (NSString*) varCipher {
    if (self = [super init]) {
        
        // initialize numbers required for crypto stuff
        [self initNumbers];
        
        // setting instance variables
        self->encKey = [varKey copy];
        self->cipher = [varCipher copy];
        
        NSLog(@"Initialized DEShi with key: %@, cipher: %@", self->encKey, self->cipher);
        
        // converting the key to binary notation
        NSMutableArray *keyBinaryTmp = [NSMutableArray arrayWithCapacity:([self->encKey length]*8)];
        size_t i;
        for (i = 0; i < [self->encKey length]; i++) {
            [keyBinaryTmp addObjectsFromArray:[self arrayOfBinaryNumbersForInt:[self->encKey characterAtIndex:i]]];
        }
        self->keyBinary = keyBinaryTmp;
        
        // initializing subkeys instance array
        self->subKeys = [NSMutableArray arrayWithCapacity:16];
        
        // generate subkeys
        [self generateSubkeys];
    }
    return (self);
}


// convert an integer value to an array of binary numbers representating that int
-(NSArray*) arrayOfBinaryNumbersForInt: (int) integer {
    
    NSMutableString *string = [NSMutableString string];
    for(NSInteger numberCopy = integer; numberCopy > 0; numberCopy >>= 1)
    {
        // prepend "0" or "1", depending on the bit
        [string insertString:((numberCopy & 1) ? @"1," : @"0,") atIndex:0];
    }

    // is that string 8 bit long? if not, fill it with leading zeros
    if ([string length]/2 != 8) {
        int requiredShifts = 8 - [string length]/2;
        for (size_t i = 0; i < requiredShifts; i++) {
            [string insertString: @"0," atIndex: 0];
        }
    }
    
    NSString *finalString = [NSString stringWithString:string];
    
    // remove the final comma of the string
    finalString = [finalString substringToIndex:([string length] - 1)];

    // convert the comma separated string to an NSArray
    NSArray *result = [finalString componentsSeparatedByString:@","];
    
    return (result);
}

// permutate a given NSArray message with given NSArray permutation
-(NSArray*)permutate:  (NSArray *)message
                        permutation:(NSArray*)permutation{
    
    // initialize the output array with capacity of permutation array
    NSMutableArray *permutatedArray = [NSMutableArray arrayWithCapacity:[permutation count]];
    
    // permutate!
    for (size_t i = 0; i < [permutation count]; i++) {
        NSNumber *newIndexNumber = [permutation objectAtIndex:i];
        int newIndex = [newIndexNumber intValue] - 1;
        [permutatedArray insertObject:[message objectAtIndex:newIndex] atIndex:i];
    }
    
    return permutatedArray;
}

// generate a set of 16 subkeys out of given encryption/decryption key
-(void)generateSubkeys {
    
    // allocate memory for the subkeys
    self->subKeys = [[NSMutableArray alloc] initWithCapacity:16];

    // permutate the key with PC1, so it's 14 bit long
    NSArray *permutatedKey = [self permutate:self->keyBinary permutation:self->PC1];
    
    // devide the key in 2 parts with len 7
    NSArray *leftPart = [permutatedKey subarrayWithRange:NSMakeRange(0, 7)];
    NSArray *rightPart = [permutatedKey subarrayWithRange:NSMakeRange(7, 7)];
    
    // calculate the 16 subkeys
    int i = 0;
    while (i < 16) {

        // do the required left shifts
        NSInteger shifts = [[self->LEFT_ROTATIONS objectAtIndex: i] integerValue];
        int j = 0;
        while (j < shifts) {
            leftPart = shiftArray(leftPart);
            rightPart = shiftArray(rightPart);
            j++;
        }
    
        // merge the two sides again
        NSArray *leftRight = [leftPart arrayByAddingObjectsFromArray: rightPart];
        
        // permutate the merged NSArray with PC2 and insert it to instance NSArray
        [self->subKeys insertObject:[self permutate:leftRight permutation:self->PC2] atIndex:i];
        
        i++;
    }
}

// the encryption message
-(NSString*) encrypt {
    NSMutableString *result = [NSMutableString string];
    
    // read the ascii message in blocks of 16 bit
    int i = 0;
    while (i < [self->message length]) {
        // convert parts of the ascii message to a bit array
        NSArray *firstArray = [self arrayOfBinaryNumbersForInt: [self->message characterAtIndex:i]];
        NSArray *secondArray = [firstArray arrayByAddingObjectsFromArray: [self arrayOfBinaryNumbersForInt:[self->message characterAtIndex:i+1]]];
        
        NSNumber *left = [self binaryStringToDecimal:[firstArray componentsJoinedByString:@""]];
        NSNumber *right = [self binaryStringToDecimal:[[self arrayOfBinaryNumbersForInt:[self->message characterAtIndex:i+1]] componentsJoinedByString:@""]];
        
        NSLog(@"left before encryption: %ld", [left integerValue]);
        NSLog(@"right before encryption: %ld",[right integerValue]);
        
        NSArray *data = [self permutate:secondArray permutation:self->IP];
        NSArray *encrypted_data = [self deshi:data type:0];
        
        // part this into 2x8 for binary to ascii conversion
        NSArray *leftArray = [encrypted_data subarrayWithRange:NSMakeRange(0, 8)];
        NSArray *rightArray = [encrypted_data subarrayWithRange:NSMakeRange(8, 8)];
        
        [result appendString: [NSString stringWithString:[leftArray componentsJoinedByString:@""]]];
        [result appendString: [NSString stringWithString:[rightArray componentsJoinedByString:@""]]];
        i+=2;
    }

    return (result);
}

// the decryption message
-(NSString*) decrypt {
    
    NSMutableString *result = [NSMutableString string];
    
    // first, convert the whole hex string as binary
    
    // read the hex message in blocks of 16 bit
    int i = 0;
    while (i < [self->cipher length]) {
        
        NSString *firstPart = [self->cipher substringWithRange:NSMakeRange(i, 8)];
        NSString *secondPart = [self->cipher substringWithRange:NSMakeRange(i+8, 8)];

        // we first convert them to decimal again, so we can use our own arrayOfBinaryNumbersForInt - that's tricky! :D
        NSNumber *first = [self binaryStringToDecimal:firstPart];
        NSNumber *second = [self binaryStringToDecimal:secondPart];

        NSArray *firstArray = [self arrayOfBinaryNumbersForInt:[first integerValue]];
        NSArray *secondArray = [self arrayOfBinaryNumbersForInt:[second integerValue]];
        
        NSArray *finalArray = [firstArray arrayByAddingObjectsFromArray: secondArray];
        
        NSArray *data = [self permutate:finalArray permutation:self->IP];
        NSArray *decrypted_data = [self deshi:data type:1];
        
        // part this into 2x8 for binary to ascii conversion
        NSArray *leftArrayDecrypted = [decrypted_data subarrayWithRange:NSMakeRange(0, 8)];
        NSArray *rightArrayDecrypted = [decrypted_data subarrayWithRange:NSMakeRange(8, 8)];
        
        NSNumber *left = [self binaryStringToDecimal:[leftArrayDecrypted componentsJoinedByString:@""]];
        NSNumber *right = [self binaryStringToDecimal:[rightArrayDecrypted componentsJoinedByString:@""]];
    
        [result appendFormat:@"%c", [left integerValue]];
        [result appendFormat:@"%c", [right integerValue]];
        
        i+=16;
    }
    
    return (result);
}

// the deshi implementation
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
        
        // divide the 12-bit array into 2x6-bit for the 2 sboxes
        NSMutableArray *R1 = [R subarrayWithRange:NSMakeRange(0, 6)];
        NSMutableArray *R2 = [R subarrayWithRange:NSMakeRange(6, 6)];
        
        NSMutableArray *blocks = [NSMutableArray arrayWithObjects:R1, R2, nil];
        
        int j = 0;
        NSMutableArray *sBoxResults = [NSMutableArray array];
        while (j < [blocks count]) {
            NSMutableArray *currentBlock = [blocks objectAtIndex:j];
            
            // determine the row: that's the first and the last bit (position 0 and 5) from binary to decimal
            NSMutableString *rowString = [NSMutableString string];
            [rowString insertString:[[currentBlock objectAtIndex:0] stringValue] atIndex:0];
            [rowString insertString:[[currentBlock objectAtIndex:5] stringValue] atIndex:1];
            NSNumber *row = [self binaryStringToDecimal:rowString];
            
            // determine the col: that's the remaining positions
            NSMutableString *colString = [NSMutableString string];
            [colString insertString:[[currentBlock objectAtIndex:1] stringValue] atIndex:0];
            [colString insertString:[[currentBlock objectAtIndex:2] stringValue] atIndex:1];
            [colString insertString:[[currentBlock objectAtIndex:3] stringValue] atIndex:2];
            [colString insertString:[[currentBlock objectAtIndex:4] stringValue] atIndex:3];
            NSNumber *col = [self binaryStringToDecimal:colString];
                        
            // now fetch the number from the sbox by first getting the currect array
            NSArray *sBox = [self->SBOXES objectAtIndex:j];
            NSArray *sBoxResult = [sBox objectAtIndex:[row integerValue]];
            [sBoxResults insertObject:[sBoxResult objectAtIndex: [col integerValue]] atIndex:j];
            
            j++;
        }
        
        // now: cummulate all the sbox results
        int tmp = 0;
        for (size_t k = 0; k < [sBoxResults count]; k++) {
            tmp += [[sBoxResults objectAtIndex: k] integerValue];
        }
        
        // convert that thing to binary again:
        NSArray *binarySboxResult = [self arrayOfBinaryNumbersForInt: tmp];
        
        // permutate that result with P
        R = [self permutate:binarySboxResult permutation:self->P];
        
        // xor R with L
        R = [self xorTwoNSArrays:R second:L];
        
        L = tmpR;
        
        i++;
        
        if (type == 0) {
            // encryption
            iterationNr++;
        } else {
            // decryption
            iterationNr--;
        }
    }
    
    // final permutation
    NSArray *RL = [R arrayByAddingObjectsFromArray: L];
    result = [self permutate:RL permutation:self->IP_INVERSE];
    
    return (result);
}

// xor two given arrays and return the result as NSMutableArray
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

// convert a string with binary numbers to NSNumber
-(NSNumber*)binaryStringToDecimal: (NSString*) string {
    long v = strtol([string UTF8String], NULL, 2);
    return [NSNumber numberWithLong:v];
}

// left-shift given NSArray
static NSMutableArray *shiftArray(NSArray *array)
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
    
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

// initialize the number matrices required for the crypto 
-(void)initNumbers {
    // [6, 4, 7, 3, 5, 1, 8, 2]
    self->P =   [NSArray arrayWithObjects:
                 [NSNumber numberWithInt:6],
                 [NSNumber numberWithInt:4],
                 [NSNumber numberWithInt:7],
                 [NSNumber numberWithInt:3],
                 [NSNumber numberWithInt:5],
                 [NSNumber numberWithInt:1],
                 [NSNumber numberWithInt:8],
                 [NSNumber numberWithInt:2],
                 nil];
    
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
    
    self->SBOXES = [NSArray arrayWithObjects:
                    // SBOX 1
                    [NSArray arrayWithObjects:
                     [NSArray arrayWithObjects:
                      // row 0: [14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7]
                      [NSNumber numberWithInt: 14],
                      [NSNumber numberWithInt: 4],
                      [NSNumber numberWithInt: 13],
                      [NSNumber numberWithInt: 1],
                      [NSNumber numberWithInt: 2],
                      [NSNumber numberWithInt: 15],
                      [NSNumber numberWithInt: 11],
                      [NSNumber numberWithInt: 8],
                      [NSNumber numberWithInt: 3],
                      [NSNumber numberWithInt: 10],
                      [NSNumber numberWithInt: 6],
                      [NSNumber numberWithInt: 12],
                      [NSNumber numberWithInt: 5],
                      [NSNumber numberWithInt: 9],
                      [NSNumber numberWithInt: 0],
                      [NSNumber numberWithInt: 7],
                      nil],
                     [NSArray arrayWithObjects:
                      // row 1: [0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8]
                      [NSNumber numberWithInt: 0],
                      [NSNumber numberWithInt: 15],
                      [NSNumber numberWithInt: 7],
                      [NSNumber numberWithInt: 4],
                      [NSNumber numberWithInt: 14],
                      [NSNumber numberWithInt: 2],
                      [NSNumber numberWithInt: 13],
                      [NSNumber numberWithInt: 1],
                      [NSNumber numberWithInt: 10],
                      [NSNumber numberWithInt: 6],
                      [NSNumber numberWithInt: 12],
                      [NSNumber numberWithInt: 11],
                      [NSNumber numberWithInt: 9],
                      [NSNumber numberWithInt: 5],
                      [NSNumber numberWithInt: 3],
                      [NSNumber numberWithInt: 8],
                      nil],
                     [NSArray arrayWithObjects:
                      // row 2: [4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0]
                      [NSNumber numberWithInt: 4],
                      [NSNumber numberWithInt: 1],
                      [NSNumber numberWithInt: 14],
                      [NSNumber numberWithInt: 8],
                      [NSNumber numberWithInt: 13],
                      [NSNumber numberWithInt: 6],
                      [NSNumber numberWithInt: 2],
                      [NSNumber numberWithInt: 11],
                      [NSNumber numberWithInt: 15],
                      [NSNumber numberWithInt: 12],
                      [NSNumber numberWithInt: 9],
                      [NSNumber numberWithInt: 7],
                      [NSNumber numberWithInt: 3],
                      [NSNumber numberWithInt: 10],
                      [NSNumber numberWithInt: 5],
                      [NSNumber numberWithInt: 0],
                      nil],
                     [NSArray arrayWithObjects:
                      // row 3: [15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13]
                      [NSNumber numberWithInt: 15],
                      [NSNumber numberWithInt: 12],
                      [NSNumber numberWithInt: 8],
                      [NSNumber numberWithInt: 2],
                      [NSNumber numberWithInt: 4],
                      [NSNumber numberWithInt: 9],
                      [NSNumber numberWithInt: 1],
                      [NSNumber numberWithInt: 7],
                      [NSNumber numberWithInt: 5],
                      [NSNumber numberWithInt: 11],
                      [NSNumber numberWithInt: 3],
                      [NSNumber numberWithInt: 14],
                      [NSNumber numberWithInt: 10],
                      [NSNumber numberWithInt: 0],
                      [NSNumber numberWithInt: 6],
                      [NSNumber numberWithInt: 13],
                      nil],
                     nil],
                    // SBOX 2
                    [NSArray arrayWithObjects:
                     [NSArray arrayWithObjects:
                      // row 0: [15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10],
                      [NSNumber numberWithInt: 15],
                      [NSNumber numberWithInt: 1],
                      [NSNumber numberWithInt: 8],
                      [NSNumber numberWithInt: 14],
                      [NSNumber numberWithInt: 6],
                      [NSNumber numberWithInt: 11],
                      [NSNumber numberWithInt: 3],
                      [NSNumber numberWithInt: 4],
                      [NSNumber numberWithInt: 9],
                      [NSNumber numberWithInt: 7],
                      [NSNumber numberWithInt: 2],
                      [NSNumber numberWithInt: 13],
                      [NSNumber numberWithInt: 12],
                      [NSNumber numberWithInt: 0],
                      [NSNumber numberWithInt: 5],
                      [NSNumber numberWithInt: 10],
                      nil],
                     [NSArray arrayWithObjects:
                      // row 1: [3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5]
                      [NSNumber numberWithInt: 3],
                      [NSNumber numberWithInt: 13],
                      [NSNumber numberWithInt: 4],
                      [NSNumber numberWithInt: 7],
                      [NSNumber numberWithInt: 15],
                      [NSNumber numberWithInt: 2],
                      [NSNumber numberWithInt: 8],
                      [NSNumber numberWithInt: 14],
                      [NSNumber numberWithInt: 12],
                      [NSNumber numberWithInt: 0],
                      [NSNumber numberWithInt: 1],
                      [NSNumber numberWithInt: 10],
                      [NSNumber numberWithInt: 6],
                      [NSNumber numberWithInt: 9],
                      [NSNumber numberWithInt: 11],
                      [NSNumber numberWithInt: 5],
                      nil],
                     [NSArray arrayWithObjects:
                      // row 2: [0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15]
                      [NSNumber numberWithInt: 0],
                      [NSNumber numberWithInt: 14],
                      [NSNumber numberWithInt: 7],
                      [NSNumber numberWithInt: 11],
                      [NSNumber numberWithInt: 10],
                      [NSNumber numberWithInt: 4],
                      [NSNumber numberWithInt: 13],
                      [NSNumber numberWithInt: 1],
                      [NSNumber numberWithInt: 5],
                      [NSNumber numberWithInt: 8],
                      [NSNumber numberWithInt: 12],
                      [NSNumber numberWithInt: 6],
                      [NSNumber numberWithInt: 9],
                      [NSNumber numberWithInt: 3],
                      [NSNumber numberWithInt: 2],
                      [NSNumber numberWithInt: 15],
                      nil],
                     [NSArray arrayWithObjects:
                      // row 3: [13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9]
                      [NSNumber numberWithInt: 13],
                      [NSNumber numberWithInt: 8],
                      [NSNumber numberWithInt: 10],
                      [NSNumber numberWithInt: 1],
                      [NSNumber numberWithInt: 3],
                      [NSNumber numberWithInt: 15],
                      [NSNumber numberWithInt: 4],
                      [NSNumber numberWithInt: 2],
                      [NSNumber numberWithInt: 11],
                      [NSNumber numberWithInt: 6],
                      [NSNumber numberWithInt: 7],
                      [NSNumber numberWithInt: 12],
                      [NSNumber numberWithInt: 0],
                      [NSNumber numberWithInt: 5],
                      [NSNumber numberWithInt: 14],
                      [NSNumber numberWithInt: 9],
                      nil],
                     nil],
                    nil];
}

@end
