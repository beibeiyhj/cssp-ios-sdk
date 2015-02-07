//
//  IFLYCategory.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/6.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const CSSPDateRFC822DateFormat1;
FOUNDATION_EXPORT NSString *const CSSPDateISO8601DateFormat1;
FOUNDATION_EXPORT NSString *const CSSPDateISO8601DateFormat2;
FOUNDATION_EXPORT NSString *const CSSPDateISO8601DateFormat3;
FOUNDATION_EXPORT NSString *const CSSPDateShortDateFormat1;

@interface NSDate (CSSP)

+ (NSDate *)cssp_dateFromString:(NSString *)string;
+ (NSDate *)cssp_dateFromString:(NSString *)string format:(NSString *)dateFormat;
- (NSString *)cssp_stringValue:(NSString *)dateFormat;

+ (NSDate *)cssp_getDateFromMessageBody:(NSString *)messageBody;

@end

@interface NSDictionary (CSSP)

- (NSDictionary *)cssp_removeNullValues;
- (id)cssp_objectForCaseInsensitiveKey:(id)aKey;

@end

@interface NSObject (CSSP)

- (NSDictionary *)cssp_properties;

- (void)cssp_copyPropertiesFromObject:(NSObject *)object;
- (BOOL)cssp_isDNSBucketName:(NSString *)theBucketName;
- (BOOL)cssp_isVirtualHostedStyleCompliant:(NSString *)theBucketName;

@end

@interface NSString (CSSP)

+ (NSString *)cssp_randomStringWithLength:(NSUInteger)length;
- (BOOL)cssp_isBase64Data;
- (NSString *)cssp_stringWithURLEncoding;
- (NSString *)cssp_stringWithURLEncodingPath;
- (NSString *)cssp_md5String;

@end

@interface NSURL (CSSP)

- (NSURL *)cssp_URLByAppendingQuery:(NSDictionary *)query;

@end
