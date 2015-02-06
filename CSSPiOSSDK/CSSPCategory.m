//
//  IFLYCategory.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/6.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPCategory.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "CSSPLogging.h"

NSString *const CSSPDateRFC822DateFormat1 = @"EEE, dd MMM yyyy HH:mm:ss z";
NSString *const CSSPDateISO8601DateFormat1 = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
NSString *const CSSPDateISO8601DateFormat2 = @"yyyyMMdd'T'HHmmss'Z'";
NSString *const CSSPDateISO8601DateFormat3 = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
NSString *const CSSPDateShortDateFormat1 = @"yyyyMMdd";

@implementation NSDate (CSSP)

+ (NSDate *)cssp_dateFromString:(NSString *)string {
    NSDate *parsedDate = nil;
    NSArray *arrayOfDateFormat = @[CSSPDateRFC822DateFormat1,CSSPDateISO8601DateFormat1,CSSPDateISO8601DateFormat2,CSSPDateISO8601DateFormat3];
    
    for (NSString *dateFormat in arrayOfDateFormat) {
        if (!parsedDate) {
            parsedDate = [NSDate cssp_dateFromString:string format:dateFormat];
        } else {
            break;
        }
    }
    
    return parsedDate;
}

+ (NSDate *)cssp_dateFromString:(NSString *)string format:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = dateFormat;
    
    NSDate *parsed = [dateFormatter dateFromString:string];
    
    return parsed;
}

- (NSString *)cssp_stringValue:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = dateFormat;
    
    //ClockSkew Correction
    NSString *formatted = [dateFormatter stringFromDate:[NSDate date]];
    
    return formatted;
}


+ (NSDate *)cssp_getDateFromMessageBody:(NSString *)messageBody
{
    if ([messageBody length] == 0) {
        return nil;
    }
    NSString *time = nil;
    // if local device time is behind than server time
    if ([messageBody rangeOfString:@" + 15"].location == NSNotFound) {
        time = [self getTimeUsingBeginTag:@" (" andEndTag:@" - 15 min.)" fromResponseBody:messageBody];
    }
    else {
        time =  [self getTimeUsingBeginTag:@" (" andEndTag:@" + 15 min.)" fromResponseBody:messageBody];
    }
    
    return [self cssp_dateFromString:time];
}

+ (NSString *)getTimeUsingBeginTag:(NSString *)bTag andEndTag:(NSString *)eTag fromResponseBody:(NSString *)responseBody {
    // Extract server time from response message body.
    @try {
        NSRange rLeft = [responseBody rangeOfString:bTag];
        NSRange rRight = [responseBody rangeOfString:eTag];
        NSUInteger loc = rLeft.location + rLeft.length;
        NSUInteger len = rRight.location - rLeft.location - rLeft.length;
        NSRange sub = NSMakeRange(loc, len);
        NSString *date = [responseBody substringWithRange:sub];
        return date;
    } @catch (NSException *e) {
        return nil;
    }
}

@end

@implementation NSDictionary (CSSP)

- (NSDictionary *)cssp_removeNullValues {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != [NSNull null]) {
            [mutableDictionary setObject:obj forKey:key];
        }
    }];
    
    return mutableDictionary;
}

-(id) cssp_objectForCaseInsensitiveKey:(id)aKey {
    for (NSString *key in self.allKeys) {
        if ([key compare:aKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return [self objectForKey:key];
        }
    }
    return  nil;
}

@end

@implementation NSObject (CSSP)

- (NSDictionary *)cssp_properties {
    NSMutableDictionary *propertyDictionary;
    if ([self superclass] != [NSObject class]) {
        propertyDictionary = [NSMutableDictionary dictionaryWithDictionary:[[self superclass] cssp_properties]];
    } else {
        propertyDictionary = [NSMutableDictionary dictionary];
    }
    
    unsigned int propertyListCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyListCount);
    for(uint32_t i = 0; i < propertyListCount; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        const char *attributes = property_getAttributes(property);
        if(propertyName) {
            NSString *propertyNameString = [NSString stringWithCString:propertyName
                                                              encoding:[NSString defaultCStringEncoding]];
            NSString *attributesString = [NSString stringWithCString:attributes
                                                            encoding:[NSString defaultCStringEncoding]];
            [propertyDictionary setObject:attributesString forKey:propertyNameString];
        }
    }
    free(properties);
    
    return propertyDictionary;
}

- (void)cssp_copyPropertiesFromObject:(NSObject *)object {
    NSDictionary *propertiesToObject = [self cssp_properties];
    NSDictionary *propertiesFromObject = [object cssp_properties];
    for (NSString *key in [propertiesFromObject allKeys]) {
        if ([propertiesToObject objectForKey:key]) {
            NSString *attributes = [propertiesFromObject valueForKey:key];
            
            if ([attributes rangeOfString:@",R,"].location == NSNotFound) {
                if (![key isEqualToString:@"uploadProgress"] && ![key isEqualToString:@"downloadProgress"]) {
                    //do not copy progress block since they do not have getter method and they have already been copied via internalRequest. copy it again will result in overwrite the current value to nil.
                    [self setValue:[object valueForKey:key]
                            forKey:key];
                }
            }
        }
    }
}

- (BOOL)cssp_isDNSBucketName:(NSString *)theContainerName;
{
    if (theContainerName == nil) {
        return NO;
    }
    
    if ( [theContainerName length] < 3 || [theContainerName length] > 63) {
        return NO;
    }
    
    if ( [theContainerName hasSuffix:@"-"]) {
        return NO;
    }
    
    if ( [self cssp_contains:theContainerName searchString:@"_"]) {
        return NO;
    }
    
    if ( [self cssp_contains:theContainerName searchString:@"-."] ||
        [self cssp_contains:theContainerName searchString:@".-"]) {
        return NO;
    }
    
    if ( [[theContainerName lowercaseString] isEqualToString:theContainerName] == NO) {
        return NO;
    }
    
    return YES;
}

- (BOOL)cssp_isVirtualHostedStyleCompliant:(NSString *)theContainerName
{
    if (![self cssp_isDNSBucketName:theContainerName]) {
        return NO;
    } else {
        return ![self cssp_contains:theContainerName searchString:@"."];
    }
}

- (BOOL)cssp_contains:(NSString *)sourceString searchString:(NSString *)searchString
{
    NSRange range = [sourceString rangeOfString:searchString];
    
    return (range.location != NSNotFound);
}

@end

@implementation NSString (CSSP)

+ (NSString *)cssp_randomStringWithLength:(NSUInteger)length {
    NSMutableString *randomString = [NSMutableString new];
    for (int32_t i = 0; i < length; i++) {
        @autoreleasepool {
            [randomString appendString:[NSString stringWithFormat:@"%c", arc4random_uniform(26) + 'a']];
        }
    }
    return randomString;
}

- (BOOL)cssp_isBase64Data {
    if ([self length] % 4 == 0) {
        static NSCharacterSet *invertedBase64CharacterSet = nil;
        if (invertedBase64CharacterSet == nil) {
            invertedBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="] invertedSet];
        }
        return [self rangeOfCharacterFromSet:invertedBase64CharacterSet
                                     options:NSLiteralSearch].location == NSNotFound;
    }
    return NO;
}

- (NSString *)cssp_stringWithURLEncoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[self cssp_decodeURLEncoding],
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\();:@&=+$,/?%#[] ",
                                                                                 kCFStringEncodingUTF8));
}

- (NSString *)cssp_stringWithURLEncodingPath {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[self cssp_decodeURLEncoding],
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\();:@&=+$,?%#[] ",
                                                                                 kCFStringEncodingUTF8));
}

- (NSString *)cssp_decodeURLEncoding {
    NSString *result = [self stringByRemovingPercentEncoding];
    return result?result:self;
}

- (NSString *)cssp_md5String {
    NSData *dataString = [self dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
    unsigned char digestArray[CC_MD5_DIGEST_LENGTH];
    CC_MD5([dataString bytes], (CC_LONG)[dataString length], digestArray);
    
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", digestArray[i]];
    }
    return md5String;
}

@end

@implementation NSURL (CSSP)

- (NSURL *)cssp_URLByAppendingQuery:(NSDictionary *)query {
    if ([query count] == 0) {
        return self;
    }
    
    NSMutableString *queryString = [NSMutableString new];
    for (NSString *key in query) {
        
        //lowercase first char
        //TODO this is a temporary fix, parse the query string properly and setup the dictionary with the key as the parameter, not the token
        NSString * correctedKey = [[[key substringToIndex:1] lowercaseString] stringByAppendingString: [key length]>1 ? [key substringFromIndex:1] : @"" ];
        
        if ([queryString length] > 0) {
            [queryString appendString:@"&"];
        }
        
        NSString *value = nil;
        if ([query[key] isKindOfClass:[NSString class]]) {
            value = query[key];
        } else if ([query[key] isKindOfClass:[NSNumber class]]) {
            value = [query[key] stringValue];
        } else {
            value = [query[key] description];
            CSSPLogWarn(@"Query value is neither NSString nor NSNumber. This method should properly handle this datatype. [%@]", query[key]);
        }
        [queryString appendString:[NSString stringWithFormat:@"%@=%@",
                                   [correctedKey cssp_stringWithURLEncoding],
                                   [value cssp_stringWithURLEncoding]]];
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",
                                 [self absoluteString],
                                 [self query] ? @"&" : @"?",
                                 queryString]];
}

@end