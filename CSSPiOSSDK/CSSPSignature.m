//
//  CSSPSignature.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/27.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPSignature.h"


@interface CSSPNSDate:NSObject
+ (NSDateFormatter *) DateFormatter;
@end

@implementation CSSPNSDate

+ (NSDateFormatter *) DateFormatter{
    NSMutableDictionary * threadDictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter * dataFormatter = [threadDictionary objectForKey:@"cachedDateFormatter"];
    if (dataFormatter == nil) {
        dataFormatter = [[NSDateFormatter alloc] init];
        [dataFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dataFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss GMT"];
        [threadDictionary setObject:dataFormatter forKey:@"cachedDateFormatter"];
    }
    return dataFormatter;
}

@end


@interface CSSPSignature ()
@property (readwrite, nonatomic, copy) NSString *accessKey;
@property (readwrite, nonatomic, copy) NSString *secretKey;
@end


@implementation CSSPSignature

+ (NSString *) HMACSign:(NSData *)data withKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm{
    CCHmacContext context;
    const char    *keyCString = [key cStringUsingEncoding:NSASCIIStringEncoding];
    
    CCHmacInit(&context, kCCHmacAlgSHA1, keyCString, strlen(keyCString));
    CCHmacUpdate(&context, [data bytes], [data length]);
    
    unsigned char digestRaw[CC_SHA1_DIGEST_LENGTH];
    NSUInteger digestLength = CC_SHA1_DIGEST_LENGTH;
    
    CCHmacFinal(&context, digestRaw);
    
    NSData *digestData = [NSData dataWithBytes:digestRaw length:digestLength];
    
    return [digestData base64EncodedStringWithOptions:kNilOptions];
    
}

- (void) setAccessKeyID:(NSString *)accessKey withSecret:(NSString *)secretKey{
    NSParameterAssert(accessKey);
    NSParameterAssert(secretKey);
    
    self.accessKey = accessKey;
    self.secretKey = secretKey;
}

-(NSString *) signatureForReques:(NSURLRequest *)request withtimestamp:(NSString *)timestamp{
    NSMutableDictionary	*mutableHeaderFields = [NSMutableDictionary dictionary];
    [[request allHTTPHeaderFields]enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        key = [key lowercaseString];
        if ([key hasPrefix:@"x-object-meta"]){
            if ([mutableHeaderFields objectForKey:key]){
                obj = [[mutableHeaderFields objectForKey:key] stringByAppendingFormat:@",%@", obj];
            }
            [mutableHeaderFields setObject:obj forKey:key];
        }
    }];
    
    NSMutableString *mutableCanonicalizedHeaderString = [NSMutableString string];
    for (NSString *key in [[mutableHeaderFields allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        id obj = [mutableHeaderFields objectForKey: key];
        [mutableCanonicalizedHeaderString appendFormat:@"%@:%@\n", key,obj];
    }
    
    NSString *canonicalizedResource = request.URL.path;
    NSString *method = [request HTTPMethod];
    NSString *contentMD5 = [request valueForHTTPHeaderField:@"Content-MD5"];
    NSString *contentType = [request valueForHTTPHeaderField:@"Content-Type"];
    
    NSMutableString *mutableString = [NSMutableString string];
    [mutableString appendFormat:@"%@\n", method ? method : @""];
    [mutableString appendFormat:@"%@\n", contentMD5 ? contentMD5 : @""];
    [mutableString appendFormat:@"%@\n", contentType ? contentType : @""];
    [mutableString appendFormat:@"%@\n", timestamp ? timestamp : @""];
    [mutableString appendFormat:@"%@", mutableCanonicalizedHeaderString];
    [mutableString appendFormat:@"%@", canonicalizedResource];

    return [CSSPSignature HMACSign:[mutableCanonicalizedHeaderString dataUsingEncoding:NSUTF8StringEncoding] withKey:self.secretKey usingAlgorithm:kCCHmacAlgSHA1];
}

- (NSURLRequest *) requestBySettingAuthorizationHeadersForRequest:(NSURLRequest *)request error:(NSError *__autoreleasing *)error{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    if (self.accessKey && self.secretKey){
        NSDate *date = [NSDate date];
        NSString *gmtDate = [[CSSPNSDate DateFormatter] stringFromDate:date];
        NSString *signature = [self signatureForReques:request withtimestamp:gmtDate];
        
        [mutableRequest setValue:[NSString stringWithFormat:@"CSSP %@:%@", self.accessKey, signature] forHTTPHeaderField:@"Authorization"];
        [mutableRequest setValue:gmtDate ? gmtDate : @"" forHTTPHeaderField:@"Date"];
    } else {
        if (error){
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Access Key and Secret Required", @"CSSPSignature", nil)
                                       };
            
            *error = [[NSError alloc] initWithDomain:@"cssp" code:NSURLErrorUserAuthenticationRequired userInfo:userInfo];
        }
    }
    return mutableRequest;
}

@end
