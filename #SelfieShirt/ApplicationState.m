//
//  ApplicationState.m
//  TwentyThings
//
//  Created by Christian Auth on 11.12.13.
//  Copyright (c) 2013 Christian Auth. All rights reserved.
//

#import "ApplicationState.h"
#import "BluetoothDevice.h"

NSString *const NotificationTweetsUpdated = @"NotificationTweetsUpdated";
NSString *const NotificationStatisticsUpdated = @"NotificationStatisticsUpdated";
NSString *const NotificationDeviceUpdated = @"NotificationDeviceUpdated";


@implementation ApplicationState

#pragma mark - Lifecycle

- (id)init
{
    if (self = [super init])
    {
        NSLog(@"ApplicationState.init");

        //Setup device
        self.shirtDevice = [[BluetoothDevice alloc] init];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(bluetoothStartedScanning)
                       name:NotificationBluetoothStartedScanning
                     object:nil];
        [center addObserver:self
                   selector:@selector(bluetoothStoppedScanning)
                       name:NotificationBluetoothStoppedScanning
                     object:nil];
        [center addObserver:self
                   selector:@selector(bluetoothConnectingDevice)
                       name:NotificationBluetoothConnectingDevice
                     object:nil];
        [center addObserver:self
                   selector:@selector(bluetoothConnectedDevice)
                       name:NotificationBluetoothConnectedDevice
                     object:nil];
        [center addObserver:self
                   selector:@selector(bluetoothDisconnectedDevice)
                       name:NotificationBluetoothDisconnectedDevice
                     object:nil];
        [center addObserver:self
                   selector:@selector(bluetoothCommandSent)
                       name:NotificationBluetoothCommandSent
                     object:nil];
        
        //Prepare settings
        NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: @"http://selfie-shirt.cloudapp.net", @"server_url",
                                     @YES, @"hashtag1_enabled",
                                     @"selfie", @"hashtag1_tag",
                                     EffectDefault, @"hashtag1_animation",
                                     @NO, @"hashtag2_enabled",
                                     @"", @"hashtag2_tag",
                                     EffectDefault, @"hashtag2_animation",
                                     @NO, @"hashtag3_enabled",
                                     @"", @"hashtag3_tag",
                                     EffectDefault, @"hashtag3_animation",
                                     nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        
        //Default Values
        self.tweets = [NSMutableArray arrayWithObjects:nil];
        self.isApnsRegistered = NO;
        self.isApnsRegistering = NO;
        self.apnsToken = nil;
        self.shirtStatus = @"None";
        
        //Listen to notifications
        [center addObserver:self
                   selector:@selector(settingsDidChange)
                       name:NSUserDefaultsDidChangeNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(bluetoothSignalStrengthChanged)
                       name:NotificationBluetoothSignalStrengthUpdated
                     object:nil];
    }
    
    return self;
}


#pragma mark - Notification Handling

- (void)bluetoothStartedScanning
{
    NSLog(@"ApplicationState.bluetoothStartedScanning");
    self.shirtStatus = @"Searching";
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationStatisticsUpdated object:nil];    
}


- (void)bluetoothStoppedScanning
{
    NSLog(@"ApplicationState.bluetoothStoppedScanning");
}


- (void)bluetoothConnectingDevice
{
    NSLog(@"ApplicationState.bluetoothConnectingDevice");
    self.shirtStatus = @"Connecting";
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationStatisticsUpdated object:nil];
}


- (void)bluetoothConnectedDevice
{
    NSLog(@"ApplicationState.bluetoothConnectedDevice");
    self.shirtStatus = @"Connected";
    self.shirtConnectedAt = [NSDate date];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationStatisticsUpdated object:nil];
}


- (void)bluetoothDisconnectedDevice
{
    NSLog(@"ApplicationState.bluetoothDisconnectedDevice");
    self.shirtStatus = @"Disconnected";
    self.shirtConnectedAt = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationStatisticsUpdated object:nil];
}


- (void)bluetoothSignalStrengthChanged
{
    NSLog(@"ApplicationState.bluetoothSignalStrengthChanged");
    self.shirtSignalStrength = self.shirtDevice.signalStrength;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationStatisticsUpdated object:nil];
}


- (void)bluetoothCommandSent
{
    NSLog(@"ApplicationState.bluetoothCommandSent");
    self.shirtCommandsSent++;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationStatisticsUpdated object:nil];
}


- (void)settingsDidChange
{
    NSLog(@"ApplicationState.settingsDidChange");
    self.isApnsRegistered = NO;
    [self performSelectorOnMainThread:@selector(update:)
                           withObject:nil
                        waitUntilDone:NO];
}


#pragma mark - Public Interface

- (NSString *)encodeString : (NSString *)unencoded
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)unencoded,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}


- (void)registerApns : (void (^)(BOOL success)) callback
{
    NSLog(@"ApplicationState.registerApns");
    
    //Start
    self.isApnsRegistering = YES;
    
    //Build url
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *serviceUrl = [[defaults stringForKey:@"server_url"] stringByAppendingString:@"/register"];
    NSURL *url = [[NSURL alloc] initWithString:serviceUrl];

    //Build post data
    NSMutableString *data = [NSMutableString stringWithCapacity:100];
    [data appendFormat:@"token=%@", [self encodeString:self.apnsToken]];
    if ([defaults boolForKey:@"hashtag1_enabled"] == YES)
    {
        [data appendFormat:@"&hashtags[]=%@", [self encodeString:[defaults stringForKey:@"hashtag1_tag"]]];
    }
    if ([defaults boolForKey:@"hashtag2_enabled"] == YES)
    {
        [data appendFormat:@"&hashtags[]=%@", [self encodeString:[defaults stringForKey:@"hashtag2_tag"]]];
    }
    if ([defaults boolForKey:@"hashtag3_enabled"] == YES)
    {
        [data appendFormat:@"&hashtags[]=%@", [self encodeString:[defaults stringForKey:@"hashtag3_tag"]]];
    }
    
    //Configure request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:15];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    //Send
    NSLog(@"ApplicationState.registerApns - Posting %@ with %@", url, data);
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         //Error?
         if (error)
         {
             NSLog(@"ApplicationState.registerApns - Posting %@ failed with %@", url, error);
             if (callback != nil)
             {
                 callback(NO);
             }
             self.isApnsRegistering = NO;
             return;
         }
         
         //Success!
         NSLog(@"ApplicationState.registerApns - Posting %@ sucessfull %@", url, response);
         self.isApnsRegistered = YES;
         self.isApnsRegistering = NO;
         if (callback != nil)
         {
             callback(YES);
         }
         
         return;
     }];
}


- (void)fetchTweets : (void (^)(BOOL success)) callback
{
    NSLog(@"ApplicationState.fetchTweets");
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *serviceUrl = [[defaults stringForKey:@"server_url"] stringByAppendingFormat:@"/updates/%@?timestamp=%f", self.apnsToken, [[NSDate date] timeIntervalSince1970]];
    NSURL *url = [[NSURL alloc] initWithString:serviceUrl];
    NSLog(@"ApplicationState.fetchTweets - Fetching %@", url);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        //Error?
        if (error)
        {
            NSLog(@"ApplicationState.fetchTweets - Fetching %@ failed with %@", url, error);
            if (callback != nil)
            {
                callback(NO);
            }
            return;
        }
        
        //Parse
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        if (localError != nil)
        {
            NSLog(@"ApplicationState.fetchTweets - Fetching %@ failed with %@", url, localError);
            if (callback != nil)
            {
                callback(NO);
            }
            return;
        }
        
        //Check success
        if ((BOOL)[parsedObject valueForKey:@"success"] == NO)
        {
            NSLog(@"ApplicationState.fetchTweets - Server returned error.....");
            if (callback != nil)
            {
                callback(NO);
            }
        }
        
        //Get values
        BOOL changed = YES;
        NSMutableArray *newTweets = [NSMutableArray arrayWithObjects:nil];
        NSArray* queriesData = (NSArray *)[parsedObject valueForKey:@"queries"];
        for (int index = 0; index < queriesData.count; index++)
        {
            NSDictionary* queryData = (NSDictionary*)[queriesData objectAtIndex:index];
            NSMutableDictionary *tweet = [NSMutableDictionary dictionaryWithCapacity:4];
            [tweet setValue:[queryData valueForKey:@"query"] forKey:@"tag"];
            [tweet setValue:[queryData valueForKey:@"message_from"] forKey:@"from"];
            [tweet setValue:[queryData valueForKey:@"message_body"] forKey:@"message"];
            [tweet setValue:[queryData valueForKey:@"message_image"] forKey:@"image"];
            [newTweets addObject:tweet];
            
            self.tweetsReceived++;
        }

        //Inform app
        if (changed == YES)
        {
            self.tweets = [NSArray arrayWithArray:newTweets];
            self.tweetsReceivedAt = [NSDate date];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTweetsUpdated object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationStatisticsUpdated object:nil];
        }

        //Success!
        if (callback != nil)
        {
            callback(YES);
        }
        
        return;
    }];
}


- (void)update : (void (^)(UIBackgroundFetchResult))backgroundCompletionHandler
{
    NSLog(@"ApplicationState.update");
    
    //Do we have a token?
    if (self.apnsToken == nil)
    {
        NSLog(@"ApplicationState.update - skip because we have no token yet");
        return;
    }
    //Already in registering state?
    if (self.isApnsRegistering == YES)
    {
        NSLog(@"ApplicationState.update - skip because we are in registration process");
        return;
    }
    //Are we already regsitered?
    if (self.isApnsRegistered)
    {
        //Get new tweets
        [self fetchTweets:^(BOOL success)
        {
            if (success == YES)
            {
                if (backgroundCompletionHandler != nil)
                {
                    backgroundCompletionHandler(UIBackgroundFetchResultNewData);
                }
            }
            else
            {
                if (backgroundCompletionHandler != nil)
                {
                    backgroundCompletionHandler(UIBackgroundFetchResultFailed);
                }
            }
        }];
    }
    else
    {
        //Register device
        [self registerApns:^(BOOL success)
        {
            if (success == YES)
            {
                //Get new tweets
                [self fetchTweets:^(BOOL success)
                {
                    if (success == YES)
                    {
                        if (backgroundCompletionHandler != nil)
                        {
                            backgroundCompletionHandler(UIBackgroundFetchResultNewData);
                        }
                    }
                    else
                    {
                        if (backgroundCompletionHandler != nil)
                        {
                            backgroundCompletionHandler(UIBackgroundFetchResultFailed);
                        }
                    }
                }];
            }
            else
            {
                //Something went wrong...
                if (backgroundCompletionHandler != nil)
                {
                    backgroundCompletionHandler(UIBackgroundFetchResultFailed);
                }
            }
        }];
    }
}

- (void)reconnectShirt
{
    self.shirtSignalStrength = nil;
    self.shirtConnectedAt = nil;
    
    [self.shirtDevice startScanning];
}

#pragma mark - Singleton

+ (ApplicationState*)sharedManager
{
    static ApplicationState *instance = nil;
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

@end
