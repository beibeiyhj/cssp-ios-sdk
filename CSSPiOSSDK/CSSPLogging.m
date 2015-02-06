//
//  CSSPLogging.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/6.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPLogging.h"

@implementation CSSPLogger

- (instancetype)init {
    if (self = [super init]) {
        _logLevel = CSSPLogLevelNone;
    }
    
    return self;
}

+ (instancetype)defaultLogger {
    static CSSPLogger *_defaultLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultLogger = [CSSPLogger new];
        _defaultLogger.logLevel = CSSPLogLevelError; //set default logLevel
    });
    
    return _defaultLogger;
}

- (void)log:(CSSPLogLevel)logLevel format:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3) {
    if(self.logLevel >= logLevel) {
        va_list args;
        va_start(args, fmt);
        NSLog(@"CSSPiOSSDK [%@] %@", [self logLevelLabel:logLevel], [[NSString alloc] initWithFormat:fmt arguments:args]);
        va_end(args);
    }
}

- (NSString *)logLevelLabel:(CSSPLogLevel)logLevel {
    switch (logLevel) {
        case CSSPLogLevelError:
            return @"Error";
            
        case CSSPLogLevelWarn:
            return @"Warn";
            
        case CSSPLogLevelInfo:
            return @"Info";
            
        case CSSPLogLevelDebug:
            return @"Debug";
            
        case CSSPLogLevelVerbose:
            return @"Verbose";
            
        case CSSPLogLevelUnknown:
        case CSSPLogLevelNone:
        default:
            return @"?";
    }
}

@end
