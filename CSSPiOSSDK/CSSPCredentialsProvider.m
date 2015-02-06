//
//  CSSPCredentialsProvider.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/6.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPCredentialsProvider.h"
#import "CSSPLogging.h"
#import "Bolts.h"

@interface CSSPStaticCredentialsProvider()

@property (nonatomic, strong) NSString *accessKey;
@property (nonatomic, strong) NSString *secretKey;

@end

@implementation CSSPStaticCredentialsProvider

+ (instancetype)credentialsWithAccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    CSSPStaticCredentialsProvider *credentials = [[CSSPStaticCredentialsProvider alloc] initWithAccessKey:accessKey
                                                                                              secretKey:secretKey];
    return credentials;
}

+ (instancetype)credentialsWithCredentialsFilename:(NSString *)credentialsFilename {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:credentialsFilename ofType:@"json"];
    NSDictionary *credentialsJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath]
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
    CSSPStaticCredentialsProvider *credentials = [[CSSPStaticCredentialsProvider alloc] initWithAccessKey:credentialsJson[@"accessKey"]
                                                                                                secretKey:credentialsJson[@"secretKey"]];
    return credentials;
}

- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey {
    if (self = [super init]) {
        _accessKey = accessKey;
        _secretKey = secretKey;
    }
    return self;
}

@end