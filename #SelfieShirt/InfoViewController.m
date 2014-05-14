//
//  InfoViewController.m
//  TwentyThings
//
//  Created by Christian Auth on 05.03.14.
//  Copyright (c) 2014 Christian Auth. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

#pragma mark - Initialization

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - View Lifecycle

- (void)viewDidLayoutSubviews
{
    //Adjust scroll size
    self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    //Call parent
    [super viewDidLayoutSubviews];
}


- (void)viewDidLoad
{
    //Set font & linespacing
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing: paragraphStyle.lineSpacing + 3];
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont fontWithName:@"BPreplay" size:14], NSParagraphStyleAttributeName: paragraphStyle };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.textView.text attributes:attributes];
    [self.textView setAttributedText: attributedString];
    
    [super viewDidLoad];
}


#pragma mark - Helper



@end
