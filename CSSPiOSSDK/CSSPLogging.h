//
//  CSSPLogging.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/6.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CSSPLogFormat @"%@ line:%d | %s | "

#define CSSPLogError(fmt, ...)    [[CSSPLogger defaultLogger] log:CSSPLogLevelError format:(CSSPLogFormat fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__]
#define CSSPLogWarn(fmt, ...)    [[CSSPLogger defaultLogger] log:CSSPLogLevelWarn format:(CSSPLogFormat fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__]
#define CSSPLogInfo(fmt, ...)    [[CSSPLogger defaultLogger] log:CSSPLogLevelInfo format:(CSSPLogFormat fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__]
#define CSSPLogDebug(fmt, ...)    [[CSSPLogger defaultLogger] log:CSSPLogLevelDebug format:(CSSPLogFormat fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__]
#define CSSPLogVerbose(fmt, ...)    [[CSSPLogger defaultLogger] log:CSSPLogLevelVerbose format:(CSSPLogFormat fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__]


typedef NS_ENUM(NSInteger, CSSPLogLevel) {
    CSSPLogLevelUnknown = -1,
    CSSPLogLevelNone = 0,
    CSSPLogLevelError = 1,
    CSSPLogLevelWarn = 2,
    CSSPLogLevelInfo = 3,
    CSSPLogLevelDebug = 4,
    CSSPLogLevelVerbose = 5
};

/**
 *  CSSPLogger is an utility class that handles logging to the console.
 *  You can specify the log level to control how verbose the output will be.
 */
@interface CSSPLogger : NSObject

/**
 *  The log level setting. The default is CSSPLogLevelNone.
 */
@property (atomic, assign) CSSPLogLevel logLevel;

/**
 *  Returns the shared logger object.
 *
 *  @return The shared logger object.
 */
+ (instancetype)defaultLogger;

/**
 *  Prints out the formatted logs to the console.
 *
 *  @param logLevel The level of this log.
 *  @param fmt      The formatted string to log.
 */
- (void)log:(CSSPLogLevel)logLevel
     format:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);

@end
