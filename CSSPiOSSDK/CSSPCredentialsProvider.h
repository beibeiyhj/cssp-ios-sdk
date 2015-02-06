//
//  CSSPCredentialsProvider.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/6.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask;

@protocol CSSPCredentialsProvider <NSObject>

@optional
@property (nonatomic, strong, readonly) NSString *accessKey;
@property (nonatomic, strong, readonly) NSString *secretKey;
@property (nonatomic, strong, readonly) NSString *sessionKey;
@property (nonatomic, strong, readonly) NSDate *expiration;

- (BFTask *)refresh;

@end

@interface CSSPStaticCredentialsProvider : NSObject <CSSPCredentialsProvider>

@property (nonatomic, readonly) NSString *accessKey;
@property (nonatomic, readonly) NSString *secretKey;

+ (instancetype)credentialsWithAccessKey:(NSString *)accessKey
                               secretKey:(NSString *)secretKey;
+ (instancetype)credentialsWithCredentialsFilename:(NSString *)credentialsFilename;

- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey;

@end
