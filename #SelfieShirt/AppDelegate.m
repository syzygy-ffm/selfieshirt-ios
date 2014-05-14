//
//  AppDelegate.m
//  TwentyThings
//
//  Created by Christian Auth on 06.12.13.
//  Copyright (c) 2013 Christian Auth. All rights reserved.
//

#import "AppDelegate.h"
#include "TargetConditionals.h"


@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Configure colors
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:115.0/255.0 green:223.0/255.0 blue:77.0/255.0 alpha:1.0]];
    
    //Require Push
    #if !(TARGET_IPHONE_SIMULATOR)
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeNewsstandContentAvailability)];
    #else
        //Register remote state
        [ApplicationState sharedManager].apnsToken = @"SIMULATOR";
        [[ApplicationState sharedManager] update:nil];
    #endif
    
    return YES;
}


-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"AppDelegate.performFetchWithCompletionHandler");
    completionHandler(UIBackgroundFetchResultNewData);
}


- (void)applicationDidBecomeActive:(UIApplication *)application;
{
    NSLog(@"AppDelegate.applicationDidBecomeActive");
    [[ApplicationState sharedManager] update:nil];
}


#pragma mark - Push Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"AppDelegate.didRegisterForRemoteNotificationsWithDeviceToken token : %@", deviceToken);
    
    //Extract token and update server if necessary
    [ApplicationState sharedManager].apnsToken = [[(NSString *)[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[ApplicationState sharedManager] update:nil];
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"AppDelegate.didFailToRegisterForRemoteNotificationsWithError error: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
	NSLog(@"AppDelegate.didReceiveRemoteNotification %@", [userInfo description]);
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //See if we got some changes
    NSString *effect = nil;
    if ([userInfo objectForKey:@"0"])
    {
        effect = [defaults stringForKey:@"hashtag1_animation"];
    }
    if ([userInfo objectForKey:@"1"])
    {
        effect = [defaults stringForKey:@"hashtag2_animation"];
    }
    if ([userInfo objectForKey:@"2"])
    {
        effect = [defaults stringForKey:@"hashtag3_animation"];
    }
    
    //If we recieved changes play the effect, if not it is a keepAlive notification
    if (effect)
    {
        NSLog(@"AppDelegate.didReceiveRemoteNotification - playing effect %@", effect);
        [[ApplicationState sharedManager].shirtDevice send:effect];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            [[ApplicationState sharedManager] update:handler];
        }
        else
        {
            handler(UIBackgroundFetchResultNewData);
        }
    }
    else
    {
        NSLog(@"AppDelegate.didReceiveRemoteNotification - handling keepAlive");
        [[ApplicationState sharedManager].shirtDevice requestBatteryInformations];
        handler(UIBackgroundFetchResultNewData);
    }
    
    //Update stats
    [ApplicationState sharedManager].notificationsReceived++;
    [ApplicationState sharedManager].notificationReceivedAt = [NSDate date];
}


@end
