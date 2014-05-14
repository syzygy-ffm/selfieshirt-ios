# #SelfieShirt iOS Application

## What?
This is a subproject of the [#SelfieShirt](https://github.com/syzygy-ffm/selfieshirt). If you landed here by accident you should first checkout the short intro movie on the [accompanying website](http://syzygy.de/selfieshirt).

The iOS application takes care of connecting the [shirt controller](https://github.com/syzygy-ffm/selfieshirt-controller) with the [shirt server](https://github.com/syzygy-ffm/selfieshirt-server) and displaying the latest matching tweets.

![Overview](https://raw.githubusercontent.com/syzygy-ffm/selfieshirt/master/Content/iOS-HowItWorks.jpg)

## Overview

### Device configuration
The application allows the user to define three hashtag queries that will get sent accompanied by the device token to the server to register the device. See [Settings.bundle/Root.plist](%23SelfieShirt/Settings.bundle/Root.plist) and [ApplicationState.m](%23SelfieShirt/ApplicationState.m) for details.

### Notification handling
If one of the registered hashtag queries yields a new tweet the server will send a push notification to the device. The app will the figure out which effect should be played (this is configurable) and sends the appropriate command to the controller. If the app is in forgeound mode the tweet display will get updated with the newest tweets. See [AppDelegate.m](%23SelfieShirt/AppDelegate.m) for details.

### Tweets display
The app features a simple tweets display for each of the defined queries. It will display the user and message and a image (if one was found). See [TweetsViewController.m](%23SelfieShirt/TweetsViewController.m) and [ApplicationState.m](%23SelfieShirt/ApplicationState.m) for details.

## What do i needed?
 - XCode
 - [Apple developer account](https://developer.apple.com/devcenter/ios/index.action) for a provioning profile.

## Developing
After cloning the repository you need to adjust the bundle identifier to match that of your provisioning profile. This should be enough to compile & run the app. We added [extended logging](%23SelfieShirt/ExtendedNSLog.m) to the project which helps understanding some of inner workings of the app. You can activate it by defining DEBUG=1. This is already done for non production builds. You can change this in Build Settings / Preprocessing. 

## Precompiled
We provide a [precompiled version](http://syzygyffm.blob.core.windows.net/selfieshirt/index.html) of the application. Just open the url in your mobile browser and install it.

## Share it!
Build your own Shirt. Create, imitate, improvise, play around. And don’t forget to share: #SelfieShirt  
If you have any questions see [syzygy.de/selfieshirt](http://syzygy.de/selfieshirt) for more details and contact information.