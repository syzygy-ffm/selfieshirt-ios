//
//  ViewController.m
//  TwentyThings
//
//  Created by Christian Auth on 06.12.13.
//  Copyright (c) 2013 Christian Auth. All rights reserved.
//

#import "TweetViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>


@interface TweetViewController ()
@end

@implementation TweetViewController


#pragma mark - Initialization


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    //Prepare
    [self.message setText:@""];
    [self.from setText:@""];
    
    //Go
    [super viewDidLoad];
}


#pragma mark - Protected
- (void)loadImage:(NSString *)url
{
    NSLog(@"TweetViewController.loadImage url = %@", url);
    [self.loader startAnimating];
    UIImage *image = nil;
    if (url != (id)[NSNull null] && ![url isEqualToString:@""])
    {
        
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:(NSString *)url]]];
    }
    else
    {
        image = [UIImage imageNamed:@"default-selfie.jpg"];
    }
    
    [self performSelectorOnMainThread:@selector(didLoadImage:) withObject:image waitUntilDone:YES];
}


- (void)didLoadImage:(UIImage *)image
{
    NSLog(@"TweetViewController.didLoadImage");
    [self.loader stopAnimating];
    [self.image setImage:image];
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.image.layer addAnimation:transition forKey:nil];
}


#pragma mark - Public Interface

- (void)updateWithDictionary:(NSDictionary *)values;
{
    NSLog(@"TweetViewController.updateWithDictionary");
    
    //Message
    if ([values objectForKey:@"message"] != (id)[NSNull null])
    {
        [self.message setText:(NSString *)[values objectForKey:@"message"]];
    }
    else
    {
        [self.message setText:@""];
    }
    [self.message setFont:[UIFont fontWithName:@"BPreplay" size:14]];
    self.message.textContainerInset = UIEdgeInsetsMake(8, 6, 8, 8);
    [self.message.layoutManager ensureLayoutForTextContainer:self.message.textContainer];
    CGSize messageSize = [self.message sizeThatFits:CGSizeMake(self.message.frame.size.width, FLT_MAX)];
    self.messageHeight.constant = (CGFloat)ceil(messageSize.height);

    //From
    if ([values objectForKey:@"from"] != (id)[NSNull null])
    {
        [self.from setText:(NSString *)[values objectForKey:@"from"]];
    }
    else
    {
        [self.from setText:@""];
    }
    [self.from setFont:[UIFont fontWithName:@"BPreplay-Bold" size:14]];
    [self.from setTextColor:[UIColor whiteColor]];
    self.from.textContainerInset = UIEdgeInsetsMake(5, 6, 5, 8);
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"BPreplay-Bold" size:14], NSFontAttributeName, nil];
    CGFloat fromWidth = [[[NSAttributedString alloc] initWithString:self.from.text attributes:attributes] size].width;
    self.fromWidth.constant = MIN(self.message.frame.size.width, ceil(fromWidth + 10 + self.from.textContainerInset.left + self.from.textContainerInset.right));
    
    //Animate textfields
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.message layoutIfNeeded];
                         [self.from layoutIfNeeded];
                     }];
    
    //Image
    [self performSelectorInBackground:@selector(loadImage:) withObject:[values objectForKey:@"image"]];
    
    //Request layout
    [self.view layoutIfNeeded];
}

@end
