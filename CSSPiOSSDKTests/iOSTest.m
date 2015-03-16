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

@interface iOTest :XCTestCase
@end

@implementation iOTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    CSSPServiceConfiguration *configuration = [iOTest setupCredentialsProvider];
    [[CSSP initialize] initWithConfiguration:configuration];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


+ (CSSPServiceConfiguration *)setupCredentialsProvider {
    CSSPStaticCredentialsProvider *credentialsProvider = [CSSPStaticCredentialsProvider credentialsWithAccessKey:@"841bd27b5ecc48c18d828f6007bfc400" secretKey:@"6b7362b058a24000af041903b314795a"];

    //CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn/byliu"];
    //CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn/1111"];
    //CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://demo.hfdn.openstorage.cn/byliu"];
    CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn/111"];
    
    CSSPServiceConfiguration *configuration = [CSSPServiceConfiguration configurationWithCredentialsProvider:credentialsProvider withEndpoint:endpoint];
    return configuration;
}

/*
- (void)testHeadContainer {
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];

    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration];

    CSSPHeadContainerRequest *request = [CSSPHeadContainerRequest new];

    [[[cssp headContainer:request] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        return nil;

    }]waitUntilFinished];
    
}
*/


/*
- (void)testListObjects {
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];
    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration];
    
    
    CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
    //listObjectReq.limit = [NSNumber numberWithInt:3];
    //listObjectReq.marker = @"object5";
    listObjectReq.prefix = @"1234/";
    //listObjectReq.delimiter = @"/";
    
    [[[cssp listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
        //XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPListObjectsOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPListObjectsOutput class]));
        CSSPListObjectsOutput *listObjectsOutput = task.result;
        //        XCTAssertEqualObjects(listObjectsOutput.name, @"ios-test-listobjects");
        
        for (CSSPObject *object in listObjectsOutput.contents)
        {
            XCTAssertTrue([object.lastModified isKindOfClass:[NSDate class]], @"listObject doesn't contain LastModified(NSDate)");
            NSLog(@"%@", object.name);
            NSLog(@"%@", object.size);
            NSLog(@"%@", object.etag);
            NSLog(@"%@", object.lastModified);
            NSLog(@"-------------------------------------------------");
          
        }
        
        for (CSSPSubdir *subdir in listObjectsOutput.subdirs)
        {
            
            NSLog(@"%@" , subdir);
        
        }
        return nil;
    }] waitUntilFinished];
 

}

*/


/*

-(void)testPutobject{
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];
    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration];
    
    NSString *filepath = @"/Users/yayu/Project/cssp-ios-sdk/1.txt";
    NSString *filecontents= [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil ];
    
    NSString *testObjectStr = @"a test object string.";
    NSString *keyName = @"ios-test-put-obj3";
    NSData *testObjectData = [testObjectStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *userMetaData = @{@"User-Data-1": @"user-metadata-value1",
                                   @"User-Data-2": @"user-metadata-value2"};
    
    CSSPPutObjectRequest *putObjectRequest = [CSSPPutObjectRequest new];

    putObjectRequest.object = keyName;
    //putObjectRequest.body = testObjectData;
    putObjectRequest.body = filecontents;
    putObjectRequest.contentLength = [NSNumber numberWithUnsignedInteger:[testObjectData length]];
    putObjectRequest.contentType = @"video/mpeg";
    putObjectRequest.metadata= userMetaData;
    
    
    [[[cssp putObject:putObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPPutObjectOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPPutObjectOutput class]));
        CSSPPutObjectOutput *putObjectsOutput = task.result;
        XCTAssertNotNil(putObjectsOutput.ETag);
        NSLog(@"%@" , putObjectsOutput.ETag);
      
        return nil;
    }] waitUntilFinished];
    
    
}

*/


/*
-(void)testGetobject{
    CSSPServiceConfiguration *configuration = [CSSPTest setupCredentialsProvider];
    CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration];
    
    //NSString *testObjectStr = @"a test object string.";
    NSString *keyName = @"ios-test-put-obj";
    //NSData *testObjectData = [testObjectStr dataUsingEncoding:NSUTF8StringEncoding];
    
    CSSPGetObjectRequest *getObjectRequest = [CSSPGetObjectRequest new];
    
    getObjectRequest.object=keyName;
    //getObjectRequest.contentLength = [NSNumber numberWithUnsignedInteger:[testObjectData length]];
    //getObjectRequest.contentType = @"video/mpeg";
    NSDictionary *userMetaData = @{@"User-Data-1": @"user-metadata-value1",
                                   @"User-Data-2": @"user-metadata-value2"};
    
    [[[cssp getObject:getObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPGetObjectOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPGetObjectOutput class]),[task.result description]);
        
        CSSPGetObjectOutput *getObjectOutput = task.result;
        
        NSData *receivedBody = getObjectOutput.body;
        
        //XCTAssertEqualObjects(userMetaData, getObjectOutput.metadata, @"getObjectOutput doesn't contains the metadata we expected");
        
        //XCTAssertNotNil(getObjectOutput.ETag);
        NSLog(@"%@",getObjectOutput.ETag);
        
        NSString *filename = @"/Users/yayu/Project/cssp-ios-sdk/getobject.txt";
        [receivedBody writeToFile:filename atomically:NO];
        
        return nil;
    }] waitUntilFinished];
    
}
*/

-(void)testheadobject{
    
    NSString *keyName = @"ios-test-put-obj";
    
    CSSPHeadObjectRequest *headobjectRequest = [CSSPHeadObjectRequest new];
    
    headobjectRequest.object = keyName;
    
    
    [[[[CSSP initialize] headObject:headobjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPHeadObjectOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPHeadObjectOutput class]));
        
        CSSPHeadObjectOutput *headObjectOutput = task.result;
        
        NSLog(@"the etag of object is : %@",headObjectOutput.ETag);
        NSLog(@"--------------------------------------------------");
        NSLog(@"the lastmodified of object is : %@",headObjectOutput.lastModified);
        NSLog(@"--------------------------------------------------");
        NSLog(@"the contentlength of object is :%@",headObjectOutput.contentLength);
        NSLog(@"--------------------------------------------------");
        NSLog(@"the contentypeof object is :%@",headObjectOutput.contentType);
        NSLog(@"--------------------------------------------------");
        NSLog(@"the metadata of object is :%@",headObjectOutput.metadata);
        NSLog(@"--------------------------------------------------");
    
        return nil;
    }] waitUntilFinished];
    
}





/*
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
*/
@end
