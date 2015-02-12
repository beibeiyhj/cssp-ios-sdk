//
//  CSSPTest.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/11.
//  Copyright (c) 2015年 cssp. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CSSP.h"

@interface CSSPTest :XCTestCase
@end

@implementation CSSPTest

+ (CSSPServiceConfiguration *)setupCredentialsProvider {
    CSSPStaticCredentialsProvider *credentialsProvider = [CSSPStaticCredentialsProvider credentialsWithAccessKey:@"841bd27b5ecc48c18d828f6007bfc400" secretKey:@"6b7362b058a24000af041903b314795a"];

    CSSPServiceConfiguration *configuration = [CSSPServiceConfiguration configurationWithCredentialsProvider:credentialsProvider withEndpoint:nil];
    return configuration;
}


+ (void)testCSSPHeadContainer {
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];
    CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openspeech.cn"];

    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration withEndpoint:endpoint];

    CSSPHeadContainerRequest *request = [CSSPHeadContainerRequest new];
    request.container = @"photos";

    [[[cssp headContainer:request] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        return nil;

    }]waitUntilFinished];
    
}

@end
