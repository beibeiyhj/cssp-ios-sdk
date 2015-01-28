//
//  CSSPSignature.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/27.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

@protocol CredentialsProvider <NSObject>

@optional
@property (nonatomic, strong, readonly) NSString *accessKey;
@property (nonatomic, strong, readonly) NSString *secretKey;
@property (nonatomic, strong, readonly) NSString *sessionKey;
@property (nonatomic, strong, readonly) NSDate *expiration;
@end


@interface CSSPSignature : NSObject



+ (NSString *) HMACSign:(NSData *) data withKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm;
- (void) setAccessKeyID:(NSString *)accessKey
             withSecret:(NSString *)secretKey;
- (NSURLRequest *) requestBySettingAuthorizationHeadersForRequest:(NSURLRequest *) request
                                                            error:(NSError * __autoreleasing *)error;
- (NSString *) signatureForReques:(NSURLRequest *) request
                    withtimestamp:(NSString *) timestamp;

@end


