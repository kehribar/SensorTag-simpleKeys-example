//
//  AppDelegate.m
//  SensorTag_simpleKeys_demo
//
//  Created by ihsan kehribar on 25/01/14.
//  Copyright (c) 2014 ihsan kehribar. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()

@property BOOL isConnected;
@property CBPeripheral* peripheral;
@property CBCentralManager* manager;

@end

@implementation AppDelegate

NSString* serviceUIID = @"FFE0";
NSString* characteristicUIID = @"FFE1";

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.isConnected = false;
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (IBAction)connectButton_action:(id)sender
{
    // try to disconnect
    if (self.isConnected)
    {
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
    // try to search & connect
    else
    {
        // start scan
        NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)};
        [self.manager scanForPeripheralsWithServices:nil options:scanOptions];
        
        [self.connectButton_outlet setTitle:@"Scanning ..."];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    BOOL bleProblem = true;
    
    switch (self.manager.state)
    {
        case CBCentralManagerStateUnknown:
        {
            NSLog(@"> CBCentralManagerStateUnknown");
            break;
        }
        case CBCentralManagerStateResetting:
        {
            NSLog(@"> CBCentralManagerStateResetting");
            break;
        }
        case CBCentralManagerStateUnsupported:
        {
            NSLog(@"> CBCentralManagerStateUnsupported");
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            NSLog(@"> CBCentralManagerStateUnauthorized");
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"> CBCentralManagerStatePoweredOff");
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"> CBCentralManagerStatePoweredOn");
            bleProblem = false;
            break;
        }
    }
    
    if (bleProblem)
    {
        [self.connectButton_outlet setEnabled:false];
        [self.logLabel_outlet setStringValue:@"BLE hardware problem!"];
        NSLog(@"> BLE hardware problem");
        self.isConnected = false;
    }
    else
    {
        [self.connectButton_outlet setEnabled:true];
        [self.logLabel_outlet setStringValue:@"BLE hardware OK!"];
        NSLog(@"> BLE hardware OK");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (self.peripheral != peripheral)
    {
        self.peripheral = peripheral;
    }
    
    // stop the scan after the initial discovery
    [self.manager stopScan];
    
    if([self.peripheral.name isEqualToString:@"SensorTag"])
    {
        // try to connect to the first discovered peripheral
        [central connectPeripheral:peripheral options:nil];
    }
    else
    {
        [self.logLabel_outlet setStringValue:@"Not a SensorTag!"];
        [self.connectButton_outlet setTitle:@"Connect!"];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    
    self.isConnected = true;
    
    NSLog(@"> didConnectPeripheral!");
    
    [self.logLabel_outlet setStringValue:@"didConnectPeripheral!"];
    
    [self.connectButton_outlet setTitle:@"Disconnect!"];
    
    // after connection try to discover the specific service
    NSMutableArray *tmpArray = [NSMutableArray array];
    [tmpArray addObject:[CBUUID UUIDWithString:serviceUIID]];
    
    [peripheral discoverServices:tmpArray];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (self.peripheral == peripheral)
    {
        self.peripheral = nil;
    }
    
    self.isConnected = false;

    [self.connectButton_outlet setTitle:@"Connect!"];
    
    NSLog(@"> didDisconnectPeripheral!");
    
    [self.logLabel_outlet setStringValue:@"didDisconnectPeripheral!"];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (self.peripheral == peripheral)
    {
        self.peripheral = nil;
    }
    
    NSLog(@"> didFailToConnectPeripheral!");
    
    [self.logLabel_outlet setStringValue:@"didFailToConnectPeripheral!"];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error != nil)
    {
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        
        [self.logLabel_outlet setStringValue:@"Service discovery failed"];
        
        return;
    }
    
    NSUInteger tmp = [peripheral.services count];
    
    if(tmp == 0)
    {
        NSLog(@"> probably wrong device!");
        [self.logLabel_outlet setStringValue:@"Service discovery failed"];
    }
    else
    {
        NSLog(@"> didDiscoverServices!");
        
        [self.logLabel_outlet setStringValue:@"didDiscoverServices!"];
            
        NSMutableArray *tmpArray = [NSMutableArray array];
        [tmpArray addObject:[CBUUID UUIDWithString:characteristicUIID]];
        
        [peripheral discoverCharacteristics:tmpArray forService:[peripheral.services objectAtIndex:0]];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error != nil)
    {
        NSLog(@"Error discovering characteristic: %@", [error localizedDescription]);

        [self.logLabel_outlet setStringValue:@"Chracteristic discovery failed"];
        
        return;
    }
    
    NSUInteger tmp = [service.characteristics count];
    
    if (tmp == 0)
    {
        NSLog(@"> probably wrong device!");
        [self.logLabel_outlet setStringValue:@"Chracteristic discovery failed"];
    }
    else
    {
        // enable notifications for the spesific 'simpleKeys' characteristic
        [peripheral setNotifyValue:YES forCharacteristic:[service.characteristics objectAtIndex:0]];
        
        [self.logLabel_outlet setStringValue:@"Subscription ok!"];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error != nil)
    {
        NSLog(@"Error updating value: %@", error.localizedDescription);
        return;
    }
    
    NSString *value = [[NSString alloc] initWithFormat:@"%@", characteristic.value];
    [self.dataLabel_outlet setStringValue:value];
}


@end
