//
//  TweetsViewController.m
//  TwentyThings
//
//  Created by Christian Auth on 04.03.14.
//  Copyright (c) 2014 Christian Auth. All rights reserved.
//

#import "TweetsViewController.h"
#import "TweetViewController.h"
#import "ApplicationState.h"

@interface TweetsViewController ()

@end

@implementation TweetsViewController

#pragma mark - Initialization

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    //Set controllers array
    self.tweetControllers = [[NSMutableArray alloc] init];
    
    //Setup itemsView
    self.itemsView.delegate = self;
    self.pager.numberOfPages = 0;
    
    //Listen to notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(tweetsDidChange)
                   name:NotificationTweetsUpdated
                 object:nil];
    
    //Call parent
    [super viewDidLoad];
}


- (void)tweetsDidChange
{
     NSLog(@"TweetsViewController.tweetsDidChangee");
    [self performSelectorOnMainThread:@selector(updateItemsView)
                           withObject:nil
                        waitUntilDone:NO];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.itemsView.frame.size.width;
    int page = floor((self.itemsView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pager.currentPage = page;
}


#pragma mark - Build UI

- (void)updateItemsView
{
    TweetViewController *tweetController;
    ApplicationState *state = [ApplicationState sharedManager];
    NSLog(@"TweetsViewController.updateItemsView subViews=%lu, hashtags=%lu", (unsigned long)self.itemsView.subviews.count, (unsigned long)state.tweets.count);
    
    //Remove views?
    while (self.tweetControllers.count > state.tweets.count)
    {
        [[self.itemsView.subviews objectAtIndex:self.itemsView.subviews.count - 1] removeFromSuperview];
        [self.tweetControllers removeObjectAtIndex:self.tweetControllers.count - 1];
    }
    
    //Add views?
    UIStoryboard *storyboard = self.storyboard;
    while (self.itemsView.subviews.count < state.tweets.count)
    {
        tweetController = [storyboard instantiateViewControllerWithIdentifier:@"TweetView"];
        [self.itemsView addSubview:tweetController.view];
        [self.tweetControllers addObject:tweetController];
    }
    
    //Configure views
    for (int index = 0; index < state.tweets.count; index++)
    {
        tweetController = (TweetViewController *)[self.tweetControllers objectAtIndex:index];
        [tweetController.view setFrame:CGRectMake(index * self.itemsView.frame.size.width, 0, self.itemsView.frame.size.width, self.itemsView.frame.size.height)];
        [tweetController updateWithDictionary:(NSDictionary *)[state.tweets objectAtIndex:index]];
    }

    //Set content size
    self.itemsView.contentSize = CGSizeMake(self.itemsView.frame.size.width * state.tweets.count, self.itemsView.frame.size.height);
    
    //Configure pager
    self.pager.numberOfPages = state.tweets.count;
    
    //Show or hide loader
    if (state.tweets.count > 0)
    {
        [self.loader stopAnimating];
    }
    else
    {
        [self.loader startAnimating];
    }
}

@end
