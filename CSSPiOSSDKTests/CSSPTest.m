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


- (void)testHeadContainer {
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];
    CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn"];

    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration withEndpoint:endpoint];

    CSSPHeadContainerRequest *request = [CSSPHeadContainerRequest new];
    request.container = @"photos";

    [[[cssp headContainer:request] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        return nil;

    }]waitUntilFinished];
    
}

- (void)testListObjects {
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];
    CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn"];
    
    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration withEndpoint:endpoint];
    
    
    CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
    listObjectReq.container = @"photos";
    //listObjectReq.limit = [NSNumber numberWithInt:1];
    //listObjectReq.marker = @"eee";
    listObjectReq.prefix = @"animals/";
    listObjectReq.delimiter = @"/";
    
    [[[cssp listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPListObjectsOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPListObjectsOutput class]));
        CSSPListObjectsOutput *listObjectsOutput = task.result;
        //        XCTAssertEqualObjects(listObjectsOutput.name, @"ios-test-listobjects");
        
        for (CSSPObject *object in listObjectsOutput.contents) {
            XCTAssertTrue([object.lastModified isKindOfClass:[NSDate class]], @"listObject doesn't contain LastModified(NSDate)");
        }
        
        return nil;
    }] waitUntilFinished];
    
//    CSSPListObjectsRequest *listObjectReq2 = [CSSPListObjectsRequest new];
//    listObjectReq2.container = @"ios-test-listobjects-not-existed";
//    
//    
//    [[[cssp listObjects:listObjectReq2] continueWithBlock:^id(BFTask *task) {
//        XCTAssertTrue(task.error, @"Expected NoSuchBucket Error not thrown.");
//        return nil;
//    }] waitUntilFinished];

}

@end
