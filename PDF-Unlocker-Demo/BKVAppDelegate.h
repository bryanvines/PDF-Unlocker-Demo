//
//  BKVAppDelegate.h
//  PDF-Unlocker-Demo
//
//  Created by Bryan Vines on 12/18/13.
//  Copyright (c) 2013 Bryan Vines. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class BKVPDFUnlocker;

@interface BKVAppDelegate : NSObject <NSApplicationDelegate> {
    BKVPDFUnlocker * unlocker;
}

// Properties
@property (copy) NSString * fileName;
@property (copy) NSURL    * fileURL;
@property        BOOL       fileIsLocked;

// GUI Properties
@property (assign) IBOutlet NSWindow *window;

// Interface Action Methods
- (IBAction) clickedSelect:(id)sender;
- (IBAction) clickedSave:(id)sender;

@end
