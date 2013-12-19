//
//  BKVAppDelegate.m
//  PDF-Unlocker-Demo
//
//  Created by Bryan Vines on 12/18/13.
//  Copyright (c) 2013 Bryan Vines. All rights reserved.
//

#import "BKVAppDelegate.h"
#import "BKVPDFUnlocker.h"

@implementation BKVAppDelegate

#pragma mark - Application Methods
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Initialize a BKVPDFUnlocker.
    unlocker = [[BKVPDFUnlocker alloc]initWithWindowNibName:@"BKVPDFUnlocker"];
    
    // Reset our properties.
    [self resetProperties];
    
    // Register as an observer of certain properties.
    [self registerAsObserver];
}
- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

#pragma mark - KVO Methods
- (void) registerAsObserver {
    
    // Register to observe our fileIsLocked property.
    [self addObserver:self
           forKeyPath:@"fileIsLocked"
              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
              context:NULL];
    
    // Register to observe the unlocker's unlockedPDF property.
    [unlocker addObserver:self
               forKeyPath:@"unlockedPDF"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    
    // We're registered to receive notifications when the our fileIsLocked property is changed.
    if ([keyPath isEqual:@"fileIsLocked"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey]boolValue] == NO) {
            // If the property is NO, show an alert to the user.
            [self performSelector:@selector(showAlertWithMessage:) withObject:@"The file you selected is already unlocked." afterDelay:0.1];
        }
    }
    
    // We're registered to receive notifications when the unlocker's unlockedPDF property is changed.
    if ([keyPath isEqual:@"unlockedPDF"]) {
        if ([change objectForKey:NSKeyValueChangeNewKey] != nil) {
            // If the new value isn't nil, it contains a PDF document.
            // Let's get it over here.
            PDFDocument * aPDF = unlocker.unlockedPDF;
            
            // Now we'll need to save it.
            // An NSSavePanel maybe?
            NSSavePanel * sPanel = [NSSavePanel savePanel];
            [sPanel setTitle:@"Save Unlocked PDF"];
            [sPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
                // handler
                if (result == NSOKButton) {
                    // User gave the document a name and location.
                    // Tell the PDF document to save itself there.
                    [aPDF writeToURL:sPanel.URL];
                }
            }];
        }
    }
}

#pragma mark - Utility Methods
- (void) resetProperties {
    self.fileName = nil;
    self.fileURL = nil;
    self.fileIsLocked = NO;
}
- (void) showAlertWithMessage:(NSString *)message {
    // Get an alert panel.
    NSAlert * alert = [NSAlert alertWithMessageText:@"Oops!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Problem: %@", message];
    
    // Show the alert.
    [alert runModal];
    
}

#pragma mark - GUI Action Methods
- (IBAction) clickedSelect:(id)sender {
    // The user clicked the Select button.
    // We'll show an NSOpenPanel as a sheet on our window.
    
    // Get an NSOpenPanel
    NSOpenPanel * oPanel = [NSOpenPanel openPanel];
    
    // Configure the panel to only allow PDF documents
    [oPanel setAllowedFileTypes:@[@"pdf"]];
    
    // Run the panel as a sheet on our window.
    [oPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            // User selected a file and clicked OK.
            PDFDocument * pdfDoc = [[PDFDocument alloc]initWithURL:oPanel.URL];
            if ([pdfDoc isLocked]) {
                // The PDF is locked.
                self.fileIsLocked = YES;                        // Set our fileIsLocked property.
                self.fileName = oPanel.URL.lastPathComponent;   // Set our fileName property.
                self.fileURL = oPanel.URL;                      // Set our fileURL property.
                            } else {
                // The PDF is not locked.
                self.fileName = oPanel.URL.lastPathComponent;   // Set our fileName property.
                self.fileIsLocked = NO;                         // Set our fileIsLocked property.
            }
        }
    }];
    
}
- (IBAction) clickedSave:(id)sender {
    // Tell the unlocker where the locked file is.
    [unlocker setLockedFileURL:self.fileURL];
    
    // Tell the unlocker to show its pretty face.
    [unlocker showWindow:self];
}

@end
