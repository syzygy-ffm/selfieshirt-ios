//
//  TweetsViewController.h
//  TwentyThings
//
//  Created by Christian Auth on 04.03.14.
//  Copyright (c) 2014 Christian Auth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetsViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *itemsView;
@property (nonatomic, retain) IBOutlet UIPageControl *pager;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loader;

@property (nonatomic, retain) NSMutableArray * tweetControllers;

- (void)updateItemsView;

@end
