//
//  ViewController.h
//  TwentyThings
//
//  Created by Christian Auth on 06.12.13.
//  Copyright (c) 2013 Christian Auth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UITextView *message;
@property (nonatomic, retain) IBOutlet UITextView *from;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *messageHeight;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *fromWidth;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loader;

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) int updateCount;

- (void)updateWithDictionary:(NSDictionary *)values;

@end
