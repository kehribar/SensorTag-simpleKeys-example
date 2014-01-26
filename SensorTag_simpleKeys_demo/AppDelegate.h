//
//  AppDelegate.h
//  SensorTag_simpleKeys_demo
//
//  Created by ihsan kehribar on 25/01/14.
//  Copyright (c) 2014 ihsan kehribar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

- (IBAction)connectButton_action:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *logLabel_outlet;

@property (weak) IBOutlet NSTextField *dataLabel_outlet;

@property (weak) IBOutlet NSButton *connectButton_outlet;

@end
