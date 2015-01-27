//
//  CSSPSignature.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/27.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPSignature.h"

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

- (NSURLRequest *) requestBySettingAuthorizationHeadersForRequest:(NSURLRequest *)request error:(NSError *__autoreleasing *)error{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    if (self.accessKey && self.secretKey){
        
    }
    return nil;
}

@end