//
//  ConnectionViewController.h
//  TwentyThings
//
//  Created by Christian Auth on 04.03.14.
//  Copyright (c) 2014 Christian Auth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionViewController : UIViewController

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) int updateCount;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *contentView;

@property (nonatomic, retain) IBOutlet UILabel *shirtLabel;
@property (nonatomic, retain) IBOutlet UILabel *shirtStatusLabel;
@property (nonatomic, retain) IBOutlet UILabel *shirtStatusValue;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *shirtLoader;
@property (nonatomic, retain) IBOutlet UILabel *shirtConnectedAtLabel;
@property (nonatomic, retain) IBOutlet UILabel *shirtConnectedAtValue;
@property (nonatomic, retain) IBOutlet UILabel *shirtCommandsSentLabel;
@property (nonatomic, retain) IBOutlet UILabel *shirtCommandsSentValue;
@property (nonatomic, retain) IBOutlet UILabel *shirtSignalLabel;
@property (nonatomic, retain) IBOutlet UILabel *shirtSignalValue;
@property (nonatomic, retain) IBOutlet UILabel *shirtIdentifierLabel;
@property (nonatomic, retain) IBOutlet UILabel *shirtIdentifierValue;
@property (nonatomic, retain) IBOutlet UILabel *shirtBatteryLabel;
@property (nonatomic, retain) IBOutlet UILabel *shirtBatteryValue;

@property (nonatomic, retain) IBOutlet UILabel *notificationLabel;
@property (nonatomic, retain) IBOutlet UILabel *notificationsReceivedAtLabel;
@property (nonatomic, retain) IBOutlet UILabel *notificationsReceivedAtValue;
@property (nonatomic, retain) IBOutlet UILabel *notificationsReceivedLabel;
@property (nonatomic, retain) IBOutlet UILabel *notificationsReceivedValue;

@property (nonatomic, retain) IBOutlet UILabel *twitterLabel;
@property (nonatomic, retain) IBOutlet UILabel *tweetsReceivedLabel;
@property (nonatomic, retain) IBOutlet UILabel *tweetsReceivedValue;
@property (nonatomic, retain) IBOutlet UILabel *tweetsReceivedAtLabel;
@property (nonatomic, retain) IBOutlet UILabel *tweetsReceivedAtValue;

@property (nonatomic, retain) IBOutlet UIButton *reconnectButton;
@property (nonatomic, retain) IBOutlet UIButton *flashButton;

- (IBAction) reconnect;
- (IBAction) flash;

@end
