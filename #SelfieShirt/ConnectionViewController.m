//
//  ConnectionViewController.m
//  TwentyThings
//
//  Created by Christian Auth on 04.03.14.
//  Copyright (c) 2014 Christian Auth. All rights reserved.
//

#import "ConnectionViewController.h"
#import "ApplicationState.h"
#import "BluetoothDevice.h"
#import "NSDate+TimeAgo.h"
#import <QuartzCore/QuartzCore.h>

@interface ConnectionViewController ()

@end

@implementation ConnectionViewController

#pragma mark - Initialization

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    NSLog(@"ConnectionViewController.viewDidLoad");
    
    //Format buttons
    self.reconnectButton.layer.cornerRadius = 10;
    [self.reconnectButton.titleLabel setFont:[UIFont fontWithName:@"BPreplay-Bold" size:14]];

    self.flashButton.layer.cornerRadius = 10;
    [self.flashButton.titleLabel setFont:[UIFont fontWithName:@"BPreplay-Bold" size:14]];
    
    //Set fonts
    [self.shirtLabel setFont:[UIFont fontWithName:@"BPreplay-Bold" size:16]];
    [self.shirtStatusLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtStatusValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtConnectedAtLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtConnectedAtValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtCommandsSentLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtCommandsSentValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtSignalLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtSignalValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtBatteryLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtBatteryValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtIdentifierLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.shirtIdentifierValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];

    [self.notificationLabel setFont:[UIFont fontWithName:@"BPreplay-Bold" size:16]];
    [self.notificationsReceivedAtLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.notificationsReceivedAtValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.notificationsReceivedLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.notificationsReceivedValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    
    [self.twitterLabel setFont:[UIFont fontWithName:@"BPreplay-Bold" size:16]];
    [self.tweetsReceivedLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.tweetsReceivedValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.tweetsReceivedAtLabel setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    [self.tweetsReceivedAtValue setFont:[UIFont fontWithName:@"BPreplay" size:17]];
    
    //Listen to notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(statisticsDidChange)
                   name:NotificationStatisticsUpdated
                 object:nil];
    [center addObserver:self
               selector:@selector(statisticsDidChange)
                   name:NotificationBluetoothIdentifierUpdated
                 object:nil];
    [center addObserver:self
               selector:@selector(statisticsDidChange)
                   name:NotificationBluetoothBatteryUpdated
                 object:nil];
    
    //Initial update
    self.updateCount = 0;
    [self updateStatistics];
    
    //Go
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    NSLog(@"ConnectionViewController.viewDidUnload");
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"ConnectionViewController.viewWillAppear");
    [self updateStatistics];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerTicked:) userInfo:nil repeats:YES];
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"ConnectionViewController.viewWillDisappear");
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    [super viewWillDisappear:animated];
}


#pragma mark - Notification Handling

- (void)updateStatistics
{
    NSLog(@"ConnectionViewController.updateStatistics");
    ApplicationState *state = [ApplicationState sharedManager];
    
    [self.shirtStatusValue setText:state.shirtStatus];
    if ([state.shirtStatus isEqualToString:@"Searching"] || [state.shirtStatus isEqualToString:@"Connecting"])
    {
        [self.shirtLoader startAnimating];
    }
    else
    {
        [self.shirtLoader stopAnimating];
    }
    if (state.shirtConnectedAt)
    {
        [self.shirtConnectedAtValue setText:[state.shirtConnectedAt timeAgo]];
    }
    else
    {
        [self.shirtConnectedAtValue setText:@"Never"];
    }
    if (state.shirtSignalStrength)
    {
        [self.shirtSignalValue setText:[[state.shirtSignalStrength description] stringByAppendingString:@" db"]];
    }
    else
    {
        [self.shirtSignalValue setText:@"None"];
    }
    [self.shirtCommandsSentValue setText:[@(state.shirtCommandsSent) description]];
    [self.shirtIdentifierValue setText:state.shirtDevice.identifier];
    [self.shirtBatteryValue setText:[NSString stringWithFormat:@"%@, %0.1fV", state.shirtDevice.batteryState, [state.shirtDevice.batteryVolts doubleValue]]];
    
    [self.notificationsReceivedValue setText:[@(state.notificationsReceived) description]];
    if (state.notificationReceivedAt)
    {
        [self.notificationsReceivedAtValue setText:[state.notificationReceivedAt timeAgo]];
    }
    else
    {
        [self.notificationsReceivedAtValue setText:@"Never"];
    }
    
    [self.tweetsReceivedValue setText:[@(state.tweetsReceived) description]];
    if (state.tweetsReceivedAt)
    {
        [self.tweetsReceivedAtValue setText:[state.tweetsReceivedAt timeAgo]];
    }
    else
    {
        [self.tweetsReceivedAtValue setText:@"Never"];
    }
}


- (void)statisticsDidChange
{
    NSLog(@"ConnectionViewController.statisticsDidChange");
    [self performSelectorOnMainThread:@selector(updateStatistics)
                           withObject:nil
                        waitUntilDone:NO];
}


- (void)updateTimerTicked:(NSTimer*)timer
{
    NSLog(@"ConnectionViewController.updateTimerTicked");
    self.updateCount++;
    if (self.updateCount > 20)
    {
        [[ApplicationState sharedManager].shirtDevice requestSignalStrength];
        [[ApplicationState sharedManager].shirtDevice requestBatteryInformations];
        self.updateCount = 0;
    }
    [self updateStatistics];
}


#pragma mark - Actions

- (IBAction) reconnect
{
    [[ApplicationState sharedManager] reconnectShirt];
}


- (IBAction) flash
{
    [[ApplicationState sharedManager].shirtDevice send:EffectFlash];
}


@end
