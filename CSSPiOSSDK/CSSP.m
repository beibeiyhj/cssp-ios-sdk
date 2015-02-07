//
//  CSSPiOSSDK.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/26.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSP.h"

@implementation CSSPServiceConfiguration
- (instancetype)init {
    if(self = [super init]) {
        _maxRetryCount = 3;
    }
    
    return self;
}


+ (instancetype)configurationWithCredentialsProvider:(id<CSSPCredentialsProvider>)credentialsProvider {
    CSSPServiceConfiguration *configuration = [[CSSPServiceConfiguration alloc] init];
    
    configuration.credentialsProvider = credentialsProvider;
    
    return configuration;
}

- (id)copyWithZone:(NSZone *)zone {
    CSSPServiceConfiguration *configuration = [[[self class] allocWithZone:zone] initWithRegion:self.regionType
                                                                           credentialsProvider:self.credentialsProvider];
    configuration.maxRetryCount = self.maxRetryCount;
    return configuration;
}

@end



@implementation CSSP

@end
