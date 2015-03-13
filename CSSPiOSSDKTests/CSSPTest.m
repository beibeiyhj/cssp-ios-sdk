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

#define CSSP_ACCESS_KEY @"4755ec75dbd74c909598d4ec59d3865a"
#define CSSP_SECRET_KEY @"c755bacdc1ce4a8993430c150dc29517"

#define CSSP_UPLOAD_URL @"http://speechplusios.hfdn.openstorage.cn/speechplussharecontainer"

@interface CSSPTest :XCTestCase
@end

@implementation CSSPTest

+ (CSSPServiceConfiguration *)setupCredentialsProvider {
    CSSPStaticCredentialsProvider *credentialsProvider = [CSSPStaticCredentialsProvider credentialsWithAccessKey:@"841bd27b5ecc48c18d828f6007bfc400" secretKey:@"6b7362b058a24000af041903b314795a"];

    CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn/111"];
    
    CSSPServiceConfiguration *configuration = [CSSPServiceConfiguration configurationWithCredentialsProvider:credentialsProvider withEndpoint:endpoint];
    return configuration;
}


- (void)testHeadContainer {
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];

    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration];

    [[[cssp headContainer] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        
        CSSPHeadContainerOutput *headContanerOutput = task.result;
        
        XCTAssertNotNil(headContanerOutput.objectCount, @"Object count required.");
        XCTAssertNotNil(headContanerOutput.bytesUsed, @"Object count required.");
        
        return nil;

    }]waitUntilFinished];
    
}

- (void)testListObjects {
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];
    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration];
    
    
    CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
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

- (void)testPutHeadGetAndDeleteObject {
    NSString *testObjectStr = @"a test object string.";
    NSString *keyName = @"ios-test-put-get-and-delete-obj";
    NSData *testObjectData = [testObjectStr dataUsingEncoding:NSUTF8StringEncoding];
    
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];
    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration];
    
    CSSPPutObjectRequest *putObjectRequest = [CSSPPutObjectRequest new];
    putObjectRequest.object = keyName;
    putObjectRequest.body = testObjectData;
    putObjectRequest.contentLength = [NSNumber numberWithUnsignedInteger:[testObjectData length]];
    //putObjectRequest.contentLength = [NSNumber numberWithUnsignedInteger:1];
    putObjectRequest.contentType = @"video/mpeg";
    
    //Add User Metadata
    NSDictionary *userMetaData = @{@"User-Data-1": @"user-metadata-value1",
                                   @"User-Data-2": @"user-metadata-value2"};
    
    
    putObjectRequest.metadata = userMetaData;
    
    [[[[[[[cssp putObject:putObjectRequest] continueWithSuccessBlock:^id(BFTask *task) {
        XCTAssertTrue([task.result isKindOfClass:[CSSPPutObjectOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPPutObjectOutput class]), [task.result description]);
        CSSPPutObjectOutput *putObjectOutput = task.result;
        XCTAssertNotNil(putObjectOutput.ETag);
        
        CSSPHeadObjectRequest *headObjectRequest = [CSSPHeadObjectRequest new];
        headObjectRequest.object = keyName;
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:15]];
        return [cssp headObject:headObjectRequest];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        XCTAssertTrue([task.result isKindOfClass:[CSSPHeadObjectOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPHeadObjectOutput class]), [task.result description]);
        CSSPHeadObjectOutput *headObjectOutput = task.result;
        XCTAssertTrue([headObjectOutput.contentLength intValue] > 0, @"Content Length is 0: [%@]", headObjectOutput.contentLength);
        
        XCTAssertEqualObjects(userMetaData, headObjectOutput.metadata, @"headObjectOutput doesn't contains the metadata we expected");
        
        CSSPGetObjectRequest *getObjectRequest = [CSSPGetObjectRequest new];
        getObjectRequest.object = keyName;
        
        return [cssp getObject:getObjectRequest];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        XCTAssertTrue([task.result isKindOfClass:[CSSPGetObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPGetObjectOutput class]),[task.result description]);
        CSSPGetObjectOutput *getObjectOutput = task.result;
        NSData *receivedBody = getObjectOutput.body;
        XCTAssertEqualObjects(testObjectData,receivedBody, @"received object is different from sent object, expect:%@ but got:%@",[[NSString alloc] initWithData:testObjectData encoding:NSUTF8StringEncoding],[[NSString alloc] initWithData:receivedBody encoding:NSUTF8StringEncoding]);
        
        XCTAssertEqualObjects(userMetaData, getObjectOutput.metadata, @"getObjectOutput doesn't contains the metadata we expected");
        
        CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
        deleteObjectRequest.object = keyName;
        
        return [cssp deleteObject:deleteObjectRequest];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),[task.result description]);
        return nil;
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"Error: [%@]", task.error);
        return nil;
    }] waitUntilFinished];
}


- (void)testMultipartUploadWithComplete {
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];
    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration];
    
    NSString *keyName = @"testMultipartUploadKey";
    NSMutableString *testString = [NSMutableString string];
    for (int32_t i = 0; i < 3000000; i++) {
        [testString appendFormat:@"%d", i];
    }
    
    NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    __block NSString *uploadId = @"";
    __block NSString *resultETag = @"";
    __block NSUInteger const transferManagerMinimumPartSize = 5 * 1024 * 1024;
    
    NSUInteger partCount = ceil((double)[testData length] / transferManagerMinimumPartSize);
    
    CSSPCreateMultipartUploadRequest *createReq = [CSSPCreateMultipartUploadRequest new];
    createReq.object = keyName;
    
    [[[[[cssp createMultipartUpload:createReq] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        CSSPCreateMultipartUploadOutput *output = task.result;
        XCTAssertTrue([task.result isKindOfClass:[CSSPCreateMultipartUploadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPCreateMultipartUploadOutput class]),[task.result description]);
        uploadId = output.uploadId;
        
        NSMutableArray *partUploadTasks = [NSMutableArray arrayWithCapacity:partCount];
        
        for (int32_t i = 1; i < partCount + 1; i++) {
            NSUInteger dataLength = i == partCount ? [testData length] - ((i - 1) * transferManagerMinimumPartSize) : transferManagerMinimumPartSize;
            NSData *partData = [testData subdataWithRange:NSMakeRange((i - 1) * transferManagerMinimumPartSize, dataLength)];
            
            CSSPUploadPartRequest *uploadPartRequest = [CSSPUploadPartRequest new];
            uploadPartRequest.object = keyName;
            uploadPartRequest.partNumber = @(i);
            uploadPartRequest.body = partData;
            uploadPartRequest.contentLength = @(dataLength);
            uploadPartRequest.uploadId = uploadId;
            
            [partUploadTasks addObject:[[cssp uploadPart:uploadPartRequest] continueWithSuccessBlock:^id(BFTask *task) {
                XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
                XCTAssertTrue([task.result isKindOfClass:[CSSPUploadPartOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPUploadPartOutput class]),[task.result description]);
                CSSPUploadPartOutput *partOuput = task.result;
                XCTAssertNotNil(partOuput.ETag);
                
                return nil;
            }]];
        }
        
        return [BFTask taskForCompletionOfAllTasks:partUploadTasks];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        
        CSSPCompleteMultipartUploadRequest *compReq = [CSSPCompleteMultipartUploadRequest new];
        compReq.object = keyName;
        compReq.uploadId = uploadId;
        
        return [cssp completeMultipartUpload:compReq];
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPCompleteMultipartUploadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPCompleteMultipartUploadOutput class]),[task.result description]);
        CSSPCompleteMultipartUploadOutput *compOutput = task.result;
        resultETag = compOutput.ETag;
 
        XCTAssertNotNil(compOutput.ETag);
        return nil;
    }] waitUntilFinished];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    
    
    CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
    listObjectReq.prefix = [NSString stringWithFormat:@"%@/%@", keyName, uploadId];
    
    [[[cssp listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPListObjectsOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPListObjectsOutput class]));
        CSSPListObjectsOutput *listObjectsOutput = task.result;
        
        BOOL match = NO;
        for (CSSPObject *object in listObjectsOutput.contents) {
            if ([object.name isEqualToString:keyName] && [object.etag isEqualToString:resultETag]) {
                match = YES;
            }
        }
        
//        XCTAssertTrue(match, @"Didn't find the uploaded object in the bucket!");
        
        return nil;
    }] waitUntilFinished];
    
    CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
    deleteObjectRequest.object = keyName;
    
    [[[cssp deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),[task.result description]);
        return nil;
    }] waitUntilFinished];
}


@end
