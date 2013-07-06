//
//  AppDelegate.m
//  DEShi
//
//  Created by Timo Josten on 06/07/13.
//  Copyright (c) 2013 Timo Josten. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"LAUNCH FINISHED");
}

-(IBAction)closeApplication:(id)sender {
    NSLog(@"CLOSE APPLICATION");    
}

- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"YEP!");
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end
