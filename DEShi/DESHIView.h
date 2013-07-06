//
//  DESHIView.h
//  DEShi
//
//  Created by Timo Josten on 06/07/13.
//  Copyright (c) 2013 Timo Josten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEShi.h"

@interface DESHIView : NSObject {
    IBOutlet NSTextField *message;
    IBOutlet NSTextField *key;
    IBOutlet NSTextView *cipher;
    NSPasteboard *pasteBoard;
}

- (IBAction) encrypt: (id) sender;
- (IBAction) decrypt: (id) sender;

@end
