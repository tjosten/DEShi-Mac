//
//  DESHIView.m
//  DEShi
//
//  Created by Timo Josten on 06/07/13.
//  Copyright (c) 2013 Timo Josten. All rights reserved.
//

#import "DESHIView.h"
#import "DEShi.h"

@implementation DESHIView

- (id)init {
    if (self = [super init]) {
        pasteBoard = [NSPasteboard generalPasteboard];
    }
    return (self);
}

- (IBAction) encrypt:(id)sender {
    
    if ([[key stringValue] length] != 2) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"You have to enter a key with length 16-bit."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[key window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        return;
    }
    
    if ([[message stringValue] length] == 0 || [[message stringValue] length] % 2 != 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"You have to enter a message which needs to be a multiple of 16-bit long."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[key window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        return;
    }

    DEShi *deshi = [[DEShi alloc] initWithKeyAndMessage:[key stringValue] message:[message stringValue]];
    NSString *cryptoText = [deshi encrypt];
    
    [cipher setString:cryptoText];
    
    // write cipher to pasteboard
    [pasteBoard clearContents];
    [pasteBoard writeObjects:[NSArray arrayWithObject:[NSString stringWithString:cryptoText]]];
}

- (IBAction) decrypt:(id)sender {

    if ([[key stringValue] length] != 2) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"You have to enter a key with length 16-bit."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[key window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        return;
    }
 
    if ([[cipher string] length] == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"You have to enter a cipher text if you want to decrypt something."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[key window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        return;
    }
    
    // clear message if entered previously
    [message setStringValue:@""];

    DEShi *deshi = [[DEShi alloc] initWithKeyAndCipher:[key stringValue] cipherText:[cipher string]];
    NSString *decrypted = [deshi decrypt];
    [message setStringValue:decrypted];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        // do nothing
    }
}

@end
