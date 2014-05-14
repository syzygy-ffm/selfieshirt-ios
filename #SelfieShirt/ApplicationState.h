//
//  ApplicationState.h
//  TwentyThings
//
//  Created by Christian Auth on 11.12.13.
//  Copyright (c) 2013 Christian Auth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BluetoothDevice.h"


extern NSString *const NotificationTweetsUpdated;
extern NSString *const NotificationStatisticsUpdated;
extern NSString *const NotificationDeviceUpdated;


@interface ApplicationState : NSObject

@property (nonatomic, retain) NSString * apnsToken;
@property (nonatomic) BOOL isApnsRegistered;
@property (nonatomic) BOOL isApnsRegistering;

@property (nonatomic, strong) BluetoothDevice *shirtDevice;
@property (nonatomic, retain) NSString *shirtStatus;
@property (nonatomic, retain) NSNumber *shirtSignalStrength;
@property (nonatomic) int shirtCommandsSent;
@property (nonatomic, retain) NSDate * shirtConnectedAt;

@property (nonatomic, retain) NSDate * notificationReceivedAt;
@property (nonatomic) int notificationsReceived;

@property (nonatomic, retain) NSDate * tweetsReceivedAt;
@property (nonatomic) int tweetsReceived;
@property (nonatomic, retain) NSArray * tweets;

- (void)registerApns : (void (^)(BOOL success)) callback;
- (void)fetchTweets : (void (^)(BOOL success)) callback;
- (void)update : (void (^)(UIBackgroundFetchResult))backgroundCompletionHandler;
- (void)reconnectShirt;

+ (ApplicationState*)sharedManager;

@end
