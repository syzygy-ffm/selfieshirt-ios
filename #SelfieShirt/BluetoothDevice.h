//
//  BluetoothDevice.h
//  TwentyThings
//
//  Created by Christian Auth on 06.12.13.
//  Copyright (c) 2013 Christian Auth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString *const NotificationBluetoothStartedScanning;
extern NSString *const NotificationBluetoothStoppedScanning;
extern NSString *const NotificationBluetoothConnectingDevice;
extern NSString *const NotificationBluetoothConnectedDevice;
extern NSString *const NotificationBluetoothDisconnectedDevice;
extern NSString *const NotificationBluetoothSignalStrengthUpdated;
extern NSString *const NotificationBluetoothBatteryUpdated;
extern NSString *const NotificationBluetoothIdentifierUpdated;
extern NSString *const NotificationBluetoothCommandSent;

extern NSString *const RequestIdentifier;
extern NSString *const RequestBatteryState;
extern NSString *const RequestBatteryVolts;


extern NSString *const EffectFlash;
extern NSString *const EffectPulser;
extern NSString *const EffectDoublePulser;
extern NSString *const EffectRainbow;
extern NSString *const EffectStrobe;
extern NSString *const EffectTremolo;
extern NSString *const EffectConnected;
extern NSString *const EffectDefault;


@interface BluetoothDevice : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;
@property (nonatomic, retain) NSNumber *signalStrength;
@property (nonatomic) BOOL readingSignalStrength;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *batteryState;
@property (nonatomic, retain) NSNumber *batteryVolts;



- (void)startScanning;
- (void)stopScanning;
- (void)send : (NSString *) command;
- (void)requestSignalStrength;
- (void)requestBatteryInformations;

@end
