//
//  ExtendedNSLog.h
//  #SelfieShirt
//
//  Created by Christian Auth on 15.04.14.
//  Copyright (c) 2014 Christian Auth. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
    #define NSLog(args...) ExtendedNSLog(__FILE__, __LINE__, __PRETTY_FUNCTION__, args);
#else
    #define NSLog(x...)
#endif

void ExtendedNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);