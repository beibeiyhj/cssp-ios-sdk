//
//  CSSPSignature.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/6.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import "CSSPNetworking.h"

@protocol CSSPCredentialsProvider;

@interface CSSPSignatureSignerUtility : NSObject

+ (NSData *)sha256HMacWithData:(NSData *)data withKey:(NSData *)key;
+ (NSString *)hashString:(NSString *)stringToHash;
+ (NSData *)hash:(NSData *)dataToHash;
+ (NSString *)hexEncode:(NSString *)string;
+ (NSString *)HMACSign:(NSData *)data withKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm;

@end

@interface CSSPSignatureSigner : NSObject <CSSPNetworkingRequestInterceptor>

@property (nonatomic, strong, readonly) id<CSSPCredentialsProvider> credentialsProvider;

+ (instancetype)signerWithCredentialsProvider:(id<CSSPCredentialsProvider>)credentialsProvider;

- (instancetype)initWithCredentialsProvider:(id<CSSPCredentialsProvider>)credentialsProvider;

@end
