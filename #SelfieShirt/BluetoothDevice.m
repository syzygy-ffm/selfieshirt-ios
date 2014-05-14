//
//  BluetoothDevice.m
//  TwentyThings
//
//  Created by Christian Auth on 06.12.13.
//  Copyright (c) 2013 Christian Auth. All rights reserved.
//
//  http://weblog.invasivecode.com/post/39707371281/core-bluetooth-for-ios-6-core-bluetooth-was
//

#import "BluetoothDevice.h"

NSString *const NotificationBluetoothStartedScanning = @"NotificationBluetoothStartedScanning";
NSString *const NotificationBluetoothStoppedScanning = @"NotificationBluetoothStoppedScanning";
NSString *const NotificationBluetoothConnectingDevice = @"NotificationBluetoothConnectingDevice";
NSString *const NotificationBluetoothConnectedDevice = @"NotificationBluetoothConnectedDevice";
NSString *const NotificationBluetoothDisconnectedDevice = @"NotificationBluetoothDisconnectedDevice";
NSString *const NotificationBluetoothSignalStrengthUpdated = @"NotificationBluetoothSignalStrengthUpdated";
NSString *const NotificationBluetoothBatteryUpdated = @"NotificationBluetoothBatteryUpdated";
NSString *const NotificationBluetoothIdentifierUpdated = @"NotificationBluetoothIdentifierUpdated";
NSString *const NotificationBluetoothCommandSent = @"NotificationBluetoothCommandSent";


NSString *const RequestIdentifier = @"I";
NSString *const RequestBatteryState = @"B";
NSString *const RequestBatteryVolts = @"V";

NSString *const EffectFlash = @"F";
NSString *const EffectPulser = @"P";
NSString *const EffectDoublePulser = @"D";
NSString *const EffectRainbow = @"R";
NSString *const EffectStrobe = @"S";
NSString *const EffectTremolo = @"T";
NSString *const EffectConnected = @"T";
NSString *const EffectDefault = @"F";

@implementation BluetoothDevice

- (id)init
{
    self = [super init];
    if (self)
    {
        self.batteryState = @"Unknown";
        self.batteryVolts = 0;
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}


- (void)updateSignalStrength:(NSNumber *)signalStrength
{
    NSLog(@"BluetoothDevice.setSignalStrength %@", signalStrength);
    self.signalStrength = signalStrength;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothSignalStrengthUpdated object:nil];
}


#pragma mark - Public Interface

- (void)send : (NSString *) command
{
    NSLog(@"BluetoothDevice.send %@", command);
    
    if (self.peripheral == nil || self.characteristic == nil)
    {
        NSLog(@"BluetoothDevice.send not connected -> exiting");
        return;
    }
   
    NSData *payload = [command dataUsingEncoding:NSUTF8StringEncoding];
    if (self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
    {
        [self.peripheral writeValue:payload forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    }
    else
    {
        [self.peripheral writeValue:payload forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothCommandSent object:nil];
}


- (void)startScanning
{
    [self.manager stopScan];
    self.peripheral = nil;
    self.characteristic = nil;
    self.batteryState = @"Unknown";
    self.batteryVolts = 0;
    self.signalStrength = nil;
    self.identifier = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothStartedScanning object:nil];
    [self.manager scanForPeripheralsWithServices:nil options:nil];
}


- (void)stopScanning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothStoppedScanning object:nil];
    [self.manager stopScan];
}


- (void)requestSignalStrength
{
    NSLog(@"BluetoothDevice.requestSignalStrength");
    
    if (self.peripheral == nil || self.readingSignalStrength == YES)
    {
        NSLog(@"BluetoothDevice.readSignalStrength not connected -> exiting");
        return;
    }
    self.readingSignalStrength = YES;
    [self.peripheral readRSSI];
}


- (void)requestBatteryInformations
{
    NSLog(@"BluetoothDevice.requestBatteryInformations");
    
    if (self.peripheral == nil)
    {
        NSLog(@"BluetoothDevice.requestBatteryInformations not connected -> exiting");
        return;
    }
    
    [self send:RequestBatteryState];
    [self send:RequestBatteryVolts];
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"BluetoothDevice.centralManagerDidUpdateState - Central Manager is ready");
            [self startScanning];
            break;
            
        default:
            break;
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"BluetoothDevice.didDiscoverPeripheral - Found Device RSSI %@ Data %@", RSSI, advertisementData);

    if (![[advertisementData valueForKey:CBAdvertisementDataLocalNameKey] isEqualToString:@"Xadow BLE Slave"] && ![[advertisementData valueForKey:CBAdvertisementDataLocalNameKey] isEqualToString:@"Seeed_BLE"])
    {
        NSLog(@"BluetoothDevice.didDiscoverPeripheral - This is not what i was looking for....");
        return;
    }

    // Stops scanning for peripheral
    [self stopScanning];

    //Connect it
    if (self.peripheral != peripheral)
    {
        self.peripheral = peripheral;
        [self updateSignalStrength:RSSI];
        NSLog(@"BluetoothDevice.didDiscoverPeripheral - Connecting to peripheral %@", peripheral);
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothConnectingDevice object:nil];
        [self.manager connectPeripheral:peripheral options:nil];
    }
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"BluetoothDevice.didFailToConnectPeripheral - Error connecting peripheral: %@", [error localizedDescription]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothDisconnectedDevice object:nil];
    [self startScanning];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"BluetoothDevice.didConnectPeripheral");
    
    [self.peripheral setDelegate:self];
    [self.peripheral discoverServices:nil];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"BluetoothDevice.didDisconnectPeripheral - Error disconnecting service: %@", [error localizedDescription]);
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothDisconnectedDevice object:nil];
    [self startScanning];
}


#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"BluetoothDevice.didDiscoverServices - Error discovering service: %@", [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services)
    {
        NSLog(@"BluetoothDevice.didDiscoverServices - Service found with UUID: %@", service.UUID);
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"BluetoothDevice.didDiscoverCharacteristicsForService -  Error discovering characteristic: %@", [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"BluetoothDevice.didDiscoverCharacteristicsForService - Characteristic found: %@, properties: %d", characteristic.UUID, characteristic.properties);
        if (characteristic.properties & CBCharacteristicPropertyWrite || characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
        {
            self.characteristic = characteristic;
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothConnectedDevice object:nil];
        }
        if (characteristic.properties & CBCharacteristicPropertyNotify)
        {
            self.notifyCharacteristic = characteristic;
        }
    }
    
    if (self.characteristic)
    {
        [self send:EffectConnected];
        
        [self.peripheral readValueForCharacteristic:self.notifyCharacteristic];
        [self.peripheral setNotifyValue:YES forCharacteristic:self.notifyCharacteristic];
        [self send:RequestIdentifier];
        [self send:RequestBatteryState];
        [self send:RequestBatteryVolts];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"BluetoothDevice.didUpdateValueForCharacteristic -  Error : %@", [error localizedDescription]);
        return;
    }
    else
    {
        //Split command responses
        NSArray *commandResponses = [[NSString stringWithUTF8String:[characteristic.value bytes]] componentsSeparatedByString:@"|"];
        
        for (NSString* commandResponse in commandResponses)
        {
            if ([commandResponse isEqualToString:@""])
            {
                continue;
            }
            
            NSArray *data = [commandResponse componentsSeparatedByString:@":"];
            NSLog(@"BluetoothDevice.didUpdateValueForCharacteristic - Received data : %@", [data description]);
            if (data.count < 2)
            {
                NSLog(@"BluetoothDevice.didUpdateValueForCharacteristic - Skipping");
            }
            
            NSString *identifier = (NSString *)[data objectAtIndex:0];
            
            //BatterState?
            if ([identifier isEqualToString:@"BS"])
            {
                NSString *bs = (NSString *)[data objectAtIndex:1];
                self.batteryState = @"Not charging";
                if ([bs isEqualToString:@"2"])
                {
                    self.batteryState = @"Charging";
                }
                if ([bs isEqualToString:@"3"])
                {
                    self.batteryState = @"Charged";
                }
                NSLog(@"BluetoothDevice.didUpdateValueForCharacteristic - Changed batterState %@", self.batteryState);
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothBatteryUpdated object:nil];
            }
            //BatterVolts?
            else if ([identifier isEqualToString:@"BV"])
            {
                NSString *bv = (NSString *)[data objectAtIndex:1];
                self.batteryVolts = [NSNumber numberWithFloat:[bv integerValue] / 100.0];
                NSLog(@"BluetoothDevice.didUpdateValueForCharacteristic - Changed batteryVolts %f",[self.batteryVolts doubleValue]);
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothBatteryUpdated object:nil];
            }
            //IDentifier?
            else if ([identifier isEqualToString:@"ID"])
            {
                self.identifier = (NSString *)[data objectAtIndex:1];
                NSLog(@"BluetoothDevice.didUpdateValueForCharacteristic - Changed identifier %@", self.identifier);
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBluetoothIdentifierUpdated object:nil];
            }
        }
    }
}


- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.readingSignalStrength = NO;
    [self updateSignalStrength:peripheral.RSSI];
}


@end
