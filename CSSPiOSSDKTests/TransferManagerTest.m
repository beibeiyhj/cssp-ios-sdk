//
//  TransferManagerTest.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/3/18.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CSSPiOSSDKAPI.h"

@interface TransferManagerTest : XCTestCase

@end

@implementation TransferManagerTest

static NSURL *tempLargeURL = nil;
static NSURL *tempSmallURL = nil;
static NSString *baseName = nil;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    CSSPStaticCredentialsProvider *credentialsProvider = [CSSPStaticCredentialsProvider credentialsWithAccessKey:@"841bd27b5ecc48c18d828f6007bfc400" secretKey:@"6b7362b058a24000af041903b314795a"];
    
    CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn/photos"];
    
    CSSPServiceConfiguration *configuration = [CSSPServiceConfiguration configurationWithCredentialsProvider:credentialsProvider withEndpoint:endpoint];
    [[CSSPTransferManager initialize] initWithConfiguration:configuration];
    
    
    //Create a large temporary file for uploading & downloading test
    NSTimeInterval timeIntervalSinceReferenceDate = [NSDate timeIntervalSinceReferenceDate];
    
    baseName = [NSString stringWithFormat:@"%lld", (int64_t)timeIntervalSinceReferenceDate];
    
    tempLargeURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-tmTestTempLarge", baseName]]];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createFileAtPath:tempLargeURL.path contents:nil attributes:nil]) {
        CSSPLogError(@"Error: Can not create file with file path:%@",tempLargeURL.path);
    }
    error = nil;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:tempLargeURL error:&error];
    if (error) {
        CSSPLogError(@"Error: [%@]", error);
    }
    
    @autoreleasepool {
        
        NSMutableString *tempBaseString = [NSMutableString string];
        for (int32_t i = 0; i < 800000; i++) { //800000 = 4.68MB
            [tempBaseString appendFormat:@"%d", i];
        }
        
        int multiplier = 15;
        for (int32_t j = 0; j < multiplier; j++) {
            @autoreleasepool {
                [fileHandle writeData:[tempBaseString dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        [fileHandle closeFile];
        
        if (true) {
            //Create a smal temporary file for uploading & downloading test
            tempSmallURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-tmTestTempSmall", baseName]]];
            NSError *error = nil;
            if (![[NSFileManager defaultManager] createFileAtPath:tempSmallURL.path contents:nil attributes:nil]) {
                CSSPLogError(@"Error: Can not create file with file path:%@",tempSmallURL.path);
            }
            error = nil;
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:tempSmallURL error:&error];
            if (error) {
                CSSPLogError(@"Error: [%@]", error);
            }
            
            [fileHandle writeData:[tempBaseString dataUsingEncoding:NSUTF8StringEncoding]]; //baseString 800000 = 4.68MB
            
            [fileHandle closeFile];
        }
        
    }

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testTMUploadSmallSizeWithProgressFeedback {
    NSString *keyName = NSStringFromSelector(_cmd);
    
    NSError *error = nil;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempSmallURL.path]);
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",keyName, baseName];
    NSURL *testDataURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
    [[NSFileManager defaultManager] createSymbolicLinkAtURL:testDataURL withDestinationURL:tempSmallURL error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempSmallURL.path
                                                                                error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    unsigned long long fileSize = [attributes fileSize];
    
    
    CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
    uploadRequest.object = keyName;
    uploadRequest.body = testDataURL;
    
    
    __block int64_t accumulatedUploadBytes = 0;
    __block int64_t totalUploadedBytes = 0;
    __block int64_t totalExpectedUploadBytes = 0;
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
        NSLog(@"keyName:%@ bytesSent: %lld, totalBytesSent: %lld, totalBytesExpectedToSend: %lld",keyName,bytesSent,totalBytesSent,totalBytesExpectedToSend);
        accumulatedUploadBytes += bytesSent;
        totalUploadedBytes = totalBytesSent;
        totalExpectedUploadBytes = totalBytesExpectedToSend;
    };
    
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateNotStarted);
    
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerUploadOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateCompleted);

//    XCTAssertEqual(totalUploadedBytes, accumulatedUploadBytes, @"total of accumulatedUploadBytes is not equal to totalUploadedBytes");
//    XCTAssertEqual(fileSize, totalUploadedBytes, @"totalUploaded Bytes is not equal to fileSize");
//    XCTAssertEqual(fileSize, totalExpectedUploadBytes);
    
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
    
    [[[[CSSP initialize] listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPListObjectsOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPListObjectsOutput class]));
        CSSPListObjectsOutput *listObjectsOutput = task.result;
        
        BOOL match = NO;
        for (CSSPObject *object in listObjectsOutput.contents) {
            if ([object.name isEqualToString:keyName]) {
                if ( [object.size unsignedIntegerValue] == fileSize) {
                    match = YES;
                } else {
                    XCTFail(@"file size is different on the server. expected:%lu, but got: %lu",(unsigned long)fileSize,(unsigned long)[object.size unsignedIntegerValue]);
                }
            }
        }
        
        XCTAssertTrue(match, @"Didn't find the uploaded object in the bucket!");
        
        return nil;
    }] waitUntilFinished];
    
    CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
    deleteObjectRequest.object= keyName;
    
    [[[[CSSP initialize] deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
}

- (void)testTMUploadLargeSizeWithProgressFeedback {
    NSString *keyName = NSStringFromSelector(_cmd);
    
    NSError *error = nil;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempLargeURL.path]);
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",NSStringFromSelector(_cmd),baseName];
    NSURL *testDataURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
    [[NSFileManager defaultManager] createSymbolicLinkAtURL:testDataURL withDestinationURL:tempLargeURL error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempLargeURL.path
                                                                                error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    unsigned long long fileSize = [attributes fileSize];
    
    
    CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
    uploadRequest.object = keyName;
    uploadRequest.body = testDataURL;
    
    __block int64_t accumulatedUploadBytes = 0;
    __block int64_t totalUploadedBytes = 0;
    __block int64_t totalExpectedUploadBytes = 0;
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
        //NSLog(@"keyName:%@ bytesSent: %lld, totalBytesSent: %lld, totalBytesExpectedToSend: %lld",keyName,bytesSent,totalBytesSent,totalBytesExpectedToSend);
        accumulatedUploadBytes += bytesSent;
        totalUploadedBytes = totalBytesSent;
        totalExpectedUploadBytes = totalBytesExpectedToSend;
    };
    
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateNotStarted);
    
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerUploadOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateCompleted);
    
//    XCTAssertEqual(totalUploadedBytes, accumulatedUploadBytes, @"total of accumulatedUploadBytes is not equal to totalUploadedBytes");
//    XCTAssertEqual(fileSize, totalUploadedBytes, @"totalUploaded Bytes is not equal to fileSize");
//    XCTAssertEqual(fileSize, totalExpectedUploadBytes);
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    CSSPHeadObjectRequest *headObjectReq = [CSSPHeadObjectRequest new];
    headObjectReq.object = keyName;
    
    [[[[CSSP initialize] headObject:headObjectReq] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPHeadObjectOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPHeadObjectOutput class]));
        CSSPHeadObjectOutput *headObjectsOutput = task.result;

        XCTAssertTrue([headObjectsOutput.contentLength unsignedIntegerValue] == fileSize, @"filesize %lld, got %@", fileSize, headObjectsOutput.contentLength);
        
        return nil;
    }] waitUntilFinished];
    
//    CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
//    deleteObjectRequest.object = keyName;
//    
//    [[[[CSSP initialize] deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
//        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
//        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),NSStringFromClass([task.result class]));
//        return nil;
//    }] waitUntilFinished];
}


- (void)testTMUploadPauseAndResumeSmallSizeWithProgressFeedback {
    
    //Upload a file to the bucket
    NSString *keyName = NSStringFromSelector(_cmd);
    
    NSError *error = nil;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempSmallURL.path]);
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",NSStringFromSelector(_cmd),baseName];
    NSURL *testDataURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
    [[NSFileManager defaultManager] createSymbolicLinkAtURL:testDataURL withDestinationURL:tempSmallURL error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempSmallURL.path
                                                                                error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    unsigned long long fileSize = [attributes fileSize];
    
    CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
    uploadRequest.object = keyName;
    uploadRequest.body = testDataURL;
    
   
    __block int64_t accumulatedUploadBytes = 0;
    __block int64_t totalUploadedBytes = 0;
    __block int64_t totalExpectedUploadBytes = 0;
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
        //NSLog(@"keyName:%@ bytesSent: %lld, totalBytesSent: %lld, totalBytesExpectedToSend: %lld",keyName,bytesSent,totalBytesSent,totalBytesExpectedToSend);
        accumulatedUploadBytes += bytesSent;
        totalUploadedBytes = totalBytesSent;
        totalExpectedUploadBytes = totalBytesExpectedToSend;
    };
    
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateNotStarted);
    
    BFTask *uploadTaskSmall = [[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error,@"Expect got 'Cancelled' Error, but got nil");
        XCTAssertEqualObjects(CSSPTransferManagerErrorDomain, task.error.domain);
        XCTAssertEqual(CSSPTransferManagerErrorPaused, task.error.code);
        return nil;
    }];
    
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateRunning);
    
    //wait a few moment and pause the task
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    [[[uploadRequest pause] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error); //should not return error if successfully paused.
        return nil;
    }] waitUntilFinished];
    
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStatePaused);
    
    [uploadTaskSmall waitUntilFinished];
    
    //resume the upload
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerUploadOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
    
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateCompleted);
    
    //XCTAssertEqual(fileSize, accumulatedUploadBytes, @"total of accumulatedUploadBytes is not equal to fileSize");
//    XCTAssertEqual(fileSize, totalUploadedBytes, @"totalUploaded Bytes is not equal to fileSize");
//    XCTAssertEqual(fileSize, totalExpectedUploadBytes);
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
    
    [[[[CSSP initialize] listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPListObjectsOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPListObjectsOutput class]));
        CSSPListObjectsOutput *listObjectsOutput = task.result;
        
        BOOL match = NO;
        for (CSSPObject *object in listObjectsOutput.contents) {
            if ([object.name isEqualToString:keyName]) {
                if ( [object.size unsignedIntegerValue] == fileSize) {
                    match = YES;
                } else {
                    XCTFail(@"file size is different on the server. expected:%lu, but got: %lu",(unsigned long)fileSize,(unsigned long)[object.size unsignedIntegerValue]);
                }
            }
        }
        
        XCTAssertTrue(match, @"Didn't find the uploaded object in the bucket!");
        
        return nil;
    }] waitUntilFinished];
    
    CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
    deleteObjectRequest.object = keyName;
    
    [[[[CSSP initialize] deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
}

-(void) testPutObjectWithProcessFeedback {
    
    NSString *keyName = NSStringFromSelector(_cmd);
    
    NSError *error = nil;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempSmallURL.path]);
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",keyName, baseName];
    NSURL *testDataURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
    [[NSFileManager defaultManager] createSymbolicLinkAtURL:testDataURL withDestinationURL:tempSmallURL error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempSmallURL.path
                                                                                error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    unsigned long long fileSize = [attributes fileSize];
    
    
    CSSPPutObjectRequest *uploadRequest = [CSSPPutObjectRequest new];
    uploadRequest.object = keyName;
    uploadRequest.body = testDataURL;
    uploadRequest.contentLength = [NSNumber numberWithUnsignedLongLong:fileSize];
    
    __block int64_t accumulatedUploadBytes = 0;
    __block int64_t totalUploadedBytes = 0;
    __block int64_t totalExpectedUploadBytes = 0;
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
        NSLog(@"keyName:%@ bytesSent: %lld, totalBytesSent: %lld, totalBytesExpectedToSend: %lld",keyName,bytesSent,totalBytesSent,totalBytesExpectedToSend);
        accumulatedUploadBytes += bytesSent;
        totalUploadedBytes = totalBytesSent;
        totalExpectedUploadBytes = totalBytesExpectedToSend;
    };
    
    [[[[CSSP initialize] putObject:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPPutObjectOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
    
    [[[[CSSP initialize] listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPListObjectsOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPListObjectsOutput class]));
        CSSPListObjectsOutput *listObjectsOutput = task.result;
        
        BOOL match = NO;
        for (CSSPObject *object in listObjectsOutput.contents) {
            if ([object.name isEqualToString:keyName]) {
                if ( [object.size unsignedIntegerValue] == fileSize) {
                    match = YES;
                } else {
                    XCTFail(@"file size is different on the server. expected:%lu, but got: %lu",(unsigned long)fileSize,(unsigned long)[object.size unsignedIntegerValue]);
                }
            }
        }
        
        XCTAssertTrue(match, @"Didn't find the uploaded object in the bucket!");
        
        return nil;
    }] waitUntilFinished];
    
    CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
    deleteObjectRequest.object= keyName;
    
    [[[[CSSP initialize] deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
}


- (void)testTMDownloadSmallSizeWithProgressFeedback {
    
    //Upload a file to the bucket
    NSString *keyName = NSStringFromSelector(_cmd);
    
    NSError *error = nil;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempSmallURL.path]);
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",NSStringFromSelector(_cmd),baseName];
    NSURL *testDataURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
    [[NSFileManager defaultManager] createSymbolicLinkAtURL:testDataURL withDestinationURL:tempSmallURL error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempSmallURL.path
                                                                                error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    
    
    CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
    uploadRequest.object = keyName;
    uploadRequest.body = testDataURL;
    
    
    
    __block int64_t accumulatedUploadBytes = 0;
    __block int64_t totalUploadedBytes = 0;
    __block int64_t totalExpectedUploadBytes = 0;
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
        //NSLog(@"keyName:%@ bytesSent: %lld, totalBytesSent: %lld, totalBytesExpectedToSend: %lld",keyName,bytesSent,totalBytesSent,totalBytesExpectedToSend);
        accumulatedUploadBytes += bytesSent;
        totalUploadedBytes = totalBytesSent;
        totalExpectedUploadBytes = totalBytesExpectedToSend;
    };
    
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerUploadOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
//    XCTAssertEqual(totalUploadedBytes, accumulatedUploadBytes, @"total of accumulatedUploadBytes is not equal to totalUploadedBytes");
//    XCTAssertEqual(fileSize, totalUploadedBytes, @"totalUploaded Bytes is not equal to fileSize");
//    XCTAssertEqual(fileSize, totalExpectedUploadBytes);
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    //Download the same file from the bucket
    CSSPTransferManagerDownloadRequest *downloadRequest = [CSSPTransferManagerDownloadRequest new];
    downloadRequest.object = keyName;
    
    NSString *downloadFileName = [NSString stringWithFormat:@"%@-downloaded-%@",NSStringFromSelector(_cmd),baseName];
    downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:downloadFileName]];
    
    //Create a situation that there is a file has already existed on that downloadingFileURL Path
    NSString *getObjectFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"cssp-2015-02-09" ofType:@"json"];
    [[NSFileManager defaultManager] copyItemAtPath:getObjectFilePath toPath:downloadRequest.downloadingFileURL.path error:nil];
    
    __block int64_t accumulatedDownloadBytes = 0;
    __block int64_t totalDownloadedBytes = 0;
    __block int64_t totalExpectedDownloadBytes = 0;
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        accumulatedDownloadBytes += bytesWritten;
        totalDownloadedBytes = totalBytesWritten;
        totalExpectedDownloadBytes = totalBytesExpectedToWrite;
        NSLog(@"keyName:%@ bytesWritten: %lld, totalBytesWritten: %lld, totalBytesExpectedtoWrite: %lld",NSStringFromSelector(_cmd), bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    };
    
    [[[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerDownloadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPTransferManagerDownloadOutput class]),NSStringFromClass([task.result class]));
        CSSPTransferManagerDownloadOutput *output = task.result;
        NSURL *receivedBodyURL = output.body;
        XCTAssertTrue([receivedBodyURL isKindOfClass:[NSURL class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([receivedBodyURL class]));
        
        //Compare file content
        XCTAssertTrue([[NSFileManager defaultManager] contentsEqualAtPath:receivedBodyURL.path andPath:[[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:testDataURL.path error:nil]], @"received and sent file are different1");
        
        return nil;
        
    }] waitUntilFinished];
    
//    XCTAssertEqual(totalDownloadedBytes, accumulatedDownloadBytes, @"accumulatedDownloadBytes is not equal to totalDownloadedBytes");
//    XCTAssertEqual(fileSize, totalDownloadedBytes,@"total downloaded fileSize is not equal to uploaded fileSize");
//    XCTAssertEqual(fileSize, totalExpectedDownloadBytes);
    
    
    //Delete the object
    CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
    deleteObjectRequest.object = keyName;
    
    [[[[CSSP initialize] deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
}


- (void)testTMDownloadLargeSizeWithProgressFeedback {
    //Upload a file to the bucket
    NSString *keyName = NSStringFromSelector(_cmd);
    NSError *error = nil;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempLargeURL.path]);
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",NSStringFromSelector(_cmd),baseName];
    NSURL *testDataURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
    [[NSFileManager defaultManager] createSymbolicLinkAtURL:testDataURL withDestinationURL:tempLargeURL error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempLargeURL.path
                                                                                error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    unsigned long long fileSize = [attributes fileSize];
    
    CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
    uploadRequest.object = keyName;
    uploadRequest.body = testDataURL;
    
    
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerUploadOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    //Download the same file from the bucket
    CSSPTransferManagerDownloadRequest *downloadRequest = [CSSPTransferManagerDownloadRequest new];
    downloadRequest.object = keyName;
    
    NSString *downloadFileName = [NSString stringWithFormat:@"%@-downloaded-%@",NSStringFromSelector(_cmd),baseName];
    downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:downloadFileName]];
    
    __block int64_t accumulatedDownloadBytes = 0;
    __block int64_t totalDownloadedBytes = 0;
    __block int64_t totalExpectedDownloadBytes = 0;
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        accumulatedDownloadBytes += bytesWritten;
        totalDownloadedBytes = totalBytesWritten;
        totalExpectedDownloadBytes = totalBytesExpectedToWrite;
        //NSLog(@"keyName:%@ bytesWritten: %lld, totalBytesWritten: %lld, totalBytesExpectedtoWrite: %lld",NSStringFromSelector(_cmd), bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    };
    
    [[[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerDownloadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPTransferManagerDownloadOutput class]),NSStringFromClass([task.result class]));
        CSSPTransferManagerDownloadOutput *output = task.result;
        NSURL *receivedBodyURL = output.body;
        XCTAssertTrue([receivedBodyURL isKindOfClass:[NSURL class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([receivedBodyURL class]));
             
        return nil;
        
    }] waitUntilFinished];
    
//    XCTAssertEqual(totalDownloadedBytes, accumulatedDownloadBytes, @"accumulatedDownloadBytes is not equal to totalDownloadedBytes");
//    XCTAssertEqual(fileSize, totalDownloadedBytes,@"total downloaded fileSize is not equal to uploaded fileSize");
//    XCTAssertEqual(fileSize, totalExpectedDownloadBytes);
    
    //Delete the object
    CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
    deleteObjectRequest.object = keyName;
    
    [[[[CSSP initialize] deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
}

- (void)testTMDownloadPauseAndResumeWithProgressFeedback {
    //Upload a file to the bucket
    NSString *keyName = NSStringFromSelector(_cmd);
    NSError *error = nil;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempLargeURL.path]);
    NSString *fileName = [NSString stringWithFormat:@"%@-%@",NSStringFromSelector(_cmd),baseName];
    NSURL *testDataURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
    [[NSFileManager defaultManager] createSymbolicLinkAtURL:testDataURL withDestinationURL:tempLargeURL error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempLargeURL.path
                                                                                error:&error];
    XCTAssertNil(error, @"The request failed. error: [%@]", error);
    unsigned long long fileSize = [attributes fileSize];
    
    
    CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
    uploadRequest.object = keyName;
    uploadRequest.body = testDataURL;
    
    
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerUploadOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    //Download the same file from the bucket
    CSSPTransferManagerDownloadRequest *downloadRequest = [CSSPTransferManagerDownloadRequest new];
    downloadRequest.object = keyName;
    
    NSString *downloadFileName = [NSString stringWithFormat:@"%@-downloaded-%@",NSStringFromSelector(_cmd),baseName];
    downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:downloadFileName]];
    
    __block int64_t accumulatedDownloadBytes = 0;
    __block int64_t totalDownloadedBytes = 0;
    __block int64_t totalExpectedDownloadBytes = 0;
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        accumulatedDownloadBytes += bytesWritten;
        totalDownloadedBytes = totalBytesWritten;
        totalExpectedDownloadBytes = totalBytesExpectedToWrite;
        //NSLog(@"keyName:%@ bytesWritten: %lld, totalBytesWritten: %lld, totalBytesExpectedtoWrite: %lld",NSStringFromSelector(_cmd), bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    };
    
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateNotStarted);
    
    BFTask *pausedTaskOne = [[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error,@"Expect got 'Cancelled' Error, but got nil");
        XCTAssertNil(task.result, @"task result should be nil since it has already been cancelled");
        XCTAssertEqualObjects(CSSPTransferManagerErrorDomain, task.error.domain);
        XCTAssertEqual(CSSPTransferManagerErrorPaused, task.error.code);
        return nil;
    }];
    
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateRunning);
    
    //wait a few seconds and then pause it.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [[[downloadRequest pause] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error); //should not return error if successfully paused.
        return nil;
    }] waitUntilFinished];
    
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStatePaused);
    
    CSSPLogDebug(@"(Transfer Manager) Download Task has been paused.");
    [pausedTaskOne waitUntilFinished]; //make sure callback has been called.
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    //resume it
    BFTask *pausedTaskTwo = [[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error,@"Expect got 'Cancelled' Error, but got nil");
        XCTAssertNil(task.result, @"task result should be nil since it has already been cancelled");
        XCTAssertEqualObjects(CSSPTransferManagerErrorDomain, task.error.domain);
        XCTAssertEqual(CSSPTransferManagerErrorPaused, task.error.code);
        return nil;
    }];
    
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateRunning);
    
    //wait and pause again
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [[[downloadRequest pause] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error); //should not return error if successfully paused.
        return nil;
    }] waitUntilFinished];
    
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStatePaused);
    
    [pausedTaskTwo waitUntilFinished]; //make sure callback has been called.
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    //resume the task
    NSLog(@"(Transfer Manager) Download Task has been resumed.");
    CSSPLogDebug(@"(Transfer Manager) Download Task has been resumed.");
    [[[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerDownloadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPTransferManagerDownloadOutput class]),NSStringFromClass([task.result class]));
        CSSPTransferManagerDownloadOutput *output = task.result;
        NSURL *receivedBodyURL = output.body;
        XCTAssertTrue([receivedBodyURL isKindOfClass:[NSURL class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([receivedBodyURL class]));
        
        return nil;
    }] waitUntilFinished];
    
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateCompleted);
    
    NSLog(@"(Transfer Manager) Download Task has been finished.");
//    XCTAssertEqual(fileSize, accumulatedDownloadBytes, @"accumulatedDownloadBytes is not equal to total file size");
//    XCTAssertEqual(fileSize, totalDownloadedBytes,@"total downloaded fileSize is not equal to uploaded fileSize");
//    XCTAssertEqual(fileSize, totalExpectedDownloadBytes);
    
    //Cleaning Up
    //Delete the object
    CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
    deleteObjectRequest.object = keyName;
    
    [[[[CSSP initialize] deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
}

@end
