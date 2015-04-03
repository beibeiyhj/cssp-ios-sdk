
//  CSSPTest.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/11.
//  Copyright (c) 2015年 cssp. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CSSPiOSSDKAPI.h"


@interface iOTest :XCTestCase
@end

@implementation iOTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    CSSPServiceConfiguration *configuration = [iOTest setupCredentialsProvider];
    [[CSSP initialize] initWithConfiguration:configuration];
    [[CSSPTransferManager initialize] initWithConfiguration:configuration];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


+ (CSSPServiceConfiguration *)setupCredentialsProvider {
    CSSPStaticCredentialsProvider *credentialsProvider = [CSSPStaticCredentialsProvider credentialsWithAccessKey:@"841bd27b5ecc48c18d828f6007bfc400" secretKey:@"6b7362b058a24000af041903b314795a"];
    //error key
    //credentialsWithAccessKey:@"b24be74d8f27405eac0853294abb280c" secretKey:@"6b7362b058a24000af041903b314795a"];
    
    
    //CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn/byliu"];
    //CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn/1111"];
    //CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://demo.hfdn.openstorage.cn/byliu"];
    CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openstorage.cn/111"];
    //error endpoint
    //CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia.hfdn.openspeech.cn/111"];
    //CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"http://yyxia10.hfdn.openstorage.cn/111"];
    
    CSSPServiceConfiguration *configuration = [CSSPServiceConfiguration configurationWithCredentialsProvider:credentialsProvider withEndpoint:endpoint];
    return configuration;
}


- (void)testHeadContainer {
    
    [[[[CSSP initialize] headContainer] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed---------. error:  [%@]", task.error);
        CSSPHeadContainerOutput *headcontainerOutput = task.result;
        NSLog(@"objectcount: %@",headcontainerOutput.objectCount);
        NSLog(@"--------------------------------------------");
        NSLog(@"byteused: %@",headcontainerOutput.bytesUsed);
        NSLog(@"--------------------------------------------");
        NSLog(@"metadata: %@",headcontainerOutput.metadata);
        return nil;
        
    }]waitUntilFinished];
}



- (void)testListObjects {
    
    CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
    //[limit]
    //listObjectReq.limit = [NSNumber numberWithInt:300]; ／／个数大于总数1个
    //listObjectReq.limit= [NSNumber numberWithInt:291]; ／／个数等于总数
    //listObjectReq.limit= [NSNumber numberWithInt:290]; ／／个数小于总数1个
    //listObjectReq.limit= [NSNumber numberWithInt:-1];  ／／个数为－1
    //listObjectReq.limit= [NSNumber numberWithInt:0];   ／／个数为0
    //listObjectReq.limit= [NSNumber numberWithInt:10];  ／／个数为小于总数的任意数
    
    //[marker]
    //listObjectReq.marker = @"object5"; //不存在的marker
    //listObjectReq.marker= @"语音云产品计划-11月.xlsx"; ／／倒数第二个object
    //listObjectReq.marker= @"银行利息.doc"; ／／倒数第一个object
    //listObjectReq.marker= @"1.jpg"; ／／第一个object
    
    
    //[prefix&delimiter]
    //listObjectReq.prefix = @"1234/";
    //listObjectReq.delimiter = @"/";
    
    //listObjectReq.prefix= @"1435345";
    //listObjectReq.delimiter= @"/";
    
    
    //[End marker]
    listObjectReq.endMarker= @"银行利息.doc";
    //listObjectReq.endMarker= @"";
    
    [[[[CSSP initialize]listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPListObjectsOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPListObjectsOutput class]));
        CSSPListObjectsOutput *listObjectsOutput = task.result;
        //        XCTAssertEqualObjects(listObjectsOutput.name, @"ios-test-listobjects");
        
        for (CSSPObject *object in listObjectsOutput.contents)
        {
            XCTAssertTrue([object.lastModified isKindOfClass:[NSDate class]], @"listObject doesn't contain LastModified(NSDate)");
            NSLog(@"name: %@", object.name);
            NSLog(@"size: %@", object.size);
            NSLog(@"etag: %@", object.etag);
            NSLog(@"lastmodified: %@", object.lastModified);
            NSLog(@"-------------------------------------------------");
            
        }
        
        for (CSSPSubdir *subdir in listObjectsOutput.subdirs)
        {
            
            NSLog(@"%@" , subdir);
            
        }
        return nil;
    }] waitUntilFinished];
    
    
}




-(void)testPutobject{
    
    
    NSString *filepath = @"/Users/yayu/Project/cssp-ios-sdk/1.txt";
    //NSString *filepath = @"/Users/yayu/Project/cssp-ios-sdk/200m";
    //NSString *filepath = @"/Users/yayu/Project/cssp-ios-sdk/2G";
    //NSString *filepath = @"/Users/yayu/Project/cssp-ios-sdk/5G";
    
    //NSString *filecontents= [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil ];
    NSData *filecontents2= [NSData dataWithContentsOfFile:filepath ];
    
    
    //NSString *keyName = @"IOStest/obj1";
    //NSString *keyName = @"IOStest/obj2";
    //NSString *keyName = @"IOStest/obj3";
    NSString *keyName = @"IOStest/obj-del1";
    
    
    
    
    //NSString *testObjectStr = @"a test object string.";
    //NSData *testObjectData = [testObjectStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *userMetaData = @{@"User-Data-1": @"user-metadata-value1",
                                   @"User-Data-2": @"user-metadata-value2"};
    
    CSSPPutObjectRequest *putObjectRequest = [CSSPPutObjectRequest new];
    
    putObjectRequest.object = keyName;
    //putObjectRequest.body = testObjectData;
    putObjectRequest.body = filecontents2;
    //putObjectRequest.contentLength = [NSNumber numberWithUnsignedInteger:[testObjectData length]];
    putObjectRequest.contentLength = [NSNumber numberWithUnsignedInteger:[filecontents2 length]];
    putObjectRequest.contentType = @"video/mpeg";
    putObjectRequest.metadata= userMetaData;
    
    
    [[[[CSSP initialize]putObject:putObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPPutObjectOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPPutObjectOutput class]));
        CSSPPutObjectOutput *putObjectsOutput = task.result;
        XCTAssertNotNil(putObjectsOutput.ETag);
        NSLog(@"----object:etag: %@" , putObjectsOutput.ETag);
        
        return nil;
    }] waitUntilFinished];
    
    
}




-(void)testGetobject{
    
    //NSString *keyName = @"IOStest/obj1"; ／／不同大小的object
    //NSString *keyName = @"IOStest/obj2";
    //NSString *keyName = @"IOStest/obj3";
    //NSString *keyName = @"IOStest/obj5"; //不存在的object
    NSString *keyName = @"银行利息.doc"; //中文名称的object
    
    
    CSSPGetObjectRequest *getObjectRequest = [CSSPGetObjectRequest new];
    
    getObjectRequest.object=keyName;
    
    [[[[CSSP initialize] getObject:getObjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPGetObjectOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPGetObjectOutput class]));
        
        CSSPGetObjectOutput *getObjectOutput = task.result;
        
        NSData *receivedBody = getObjectOutput.body;
        
        NSLog(@"%@",getObjectOutput.ETag);
        
        NSString *filename = @"/Users/yayu/Project/cssp-ios-sdk/银行利息";
        //[filename stringByAppendingString:keyName];
        [receivedBody writeToFile:filename atomically:NO];
        
        return nil;
    }] waitUntilFinished];
    
}



-(void)testheadobject{
    
    //NSString *keyName = @"IOStest/obj1";
    //NSString *keyName = @"IOStest/obj5";  //不存在
    NSString *keyName = @"银行利息.doc"; //中文名
    
    
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




-(void)testdeleteobject{
    //NSString *keyname = @"IOStest/obj-del1";
    NSString *keyname = @"IOStest/obj-del10"; //不存在的obj
    
    
    CSSPDeleteObjectRequest *deleteobjectRequest = [CSSPDeleteObjectRequest new];
    deleteobjectRequest.object = keyname;
    
    [[[[CSSP initialize] deleteObject:deleteobjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPDeleteObjectOutput class]));
        
        //CSSPDeleteObjectOutput *deleteObjectOutput = task.result;
        
        //NSLog(@"the etag of object is : %@",deleteObjectOutput);
        
        return nil;
    }] waitUntilFinished];
    
}



-(void)testcopyobject{
    
    //不同container的object
    //NSString *srcobject = @"/iattest/object5";
    //NSString *dstobject= @"IOStest/copy1";
    
    //不存在的srcobject
    //NSString *srcobject = @"/iattest/notexists.jpg";
    //NSString *dstobject= @"IOStest/copy2";
    
    //NSString *srcobject = @"/iattest1/2.txt";
    //NSString *dstobject= @"IOStest/copy3";
    
    
    //相同container的object
    NSString *srcobject = @"/111/IOStest/obj2";
    NSString *dstobject= @"copy8";
    
    
    //中文命名的object
    //NSString *srcobject = @"/iattest/工具c++test3.txt";
    //NSString *dstobject= @"IOStest/拷贝5";
    
    
    CSSPReplicateObjectRequest *copyobjectRequest = [CSSPReplicateObjectRequest new];
    copyobjectRequest.object= dstobject;
    copyobjectRequest.replicateSource= srcobject;
    
    [[[[CSSP initialize] replicateObject:copyobjectRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPReplicateObjectOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPReplicateObjectOutput class]));
        
        CSSPReplicateObjectOutput *copyobjectOutput = task.result;
        
        NSLog(@"the etag of object is : %@",copyobjectOutput.ETag);
        NSLog(@"-----------------------------");
        
        return nil;
    }] waitUntilFinished];
}






- (void)testMultipartUploadWithComplete {
    
    
    NSString *keyName = @"IOStest/multiput10";
    
    NSMutableString *testString = [NSMutableString string];
    for (int64_t i = 0; i < 4000000000; i++) {
        [testString appendFormat:@"%lld", i];
    }
    
    NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    __block NSString *uploadId = @"";
    __block NSString *resultETag = @"";
    __block NSUInteger const transferManagerMinimumPartSize = 1 * 1024 * 1024* 1024;
    
    NSUInteger partCount = ceil((double)[testData length] / transferManagerMinimumPartSize);
    
    
    
    CSSPCreateMultipartUploadRequest *createReq = [CSSPCreateMultipartUploadRequest new];
    createReq.object = keyName;
    
    
    
    [[[[[[CSSP initialize]createMultipartUpload:createReq] continueWithBlock:^id(BFTask *task) {
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
            
            [partUploadTasks addObject:[[[CSSP initialize]uploadPart:uploadPartRequest] continueWithSuccessBlock:^id(BFTask *task) {
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
        
        return [[CSSP initialize]completeMultipartUpload:compReq];
        
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPCompleteMultipartUploadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPCompleteMultipartUploadOutput class]),[task.result description]);
        
        CSSPCompleteMultipartUploadOutput *compOutput = task.result;
        
        resultETag = compOutput.ETag;
        
        XCTAssertNotNil(compOutput.ETag);
        return nil;
    }] waitUntilFinished];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    
    
}


-(void)testTransfermanageupload{
    //NSString *keyname = @"transferupload-1G";
    //虚拟目录
    //NSString *keyname = @"IOStest/transferupload";
    //中文命名
    NSString *keyname = @"IOStest/数据流上传";
    
    
    NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/1.txt";
    //NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/5m";
    //NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/6m";
    //NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/10m";
    //NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/1G";
    
    NSURL *testDataURL=[NSURL URLWithString:filepath];
    
    CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
    uploadRequest.body= testDataURL;
    uploadRequest.object= keyname;
    
    __block int64_t accumulatedUploadBytes = 0;
    __block int64_t totalUploadBytes = 0;
    __block int64_t totalExpectedUploadBytes= 0;
    
    uploadRequest.uploadProgress = ^(int64_t bytesSend, int64_t totalBytesSend, int64_t totalBytesExpectedToSend){
        NSLog(@"-------------------------------------------");
        NSLog(@"object : %@ bytesSend : %lld, totalBytestSend : %lld, totalBytesExceptedToSend : %lld ", keyname ,bytesSend,totalBytesSend , totalBytesExpectedToSend);
        accumulatedUploadBytes += bytesSend;
        totalUploadBytes = totalBytesSend;
        totalExpectedUploadBytes = totalBytesExpectedToSend;
        
    };
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerUploadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPTransferManagerUploadOutput class]),[task.result description]);
        CSSPTransferManagerUploadOutput *uploadoutput = task.result;
        NSLog(@"*****************************************");
        NSLog(@"%@",uploadoutput.ETag);
        
        return nil;
    }]waitUntilFinished];
    
}

-(void)testTransfermanagedownload{
    //NSString *keyname = @"transferupload";
    //NSString *keyname = @"transferupload-10m";
    //NSString *keyname = @"transferupload-1G";
    //虚拟目录
    //NSString *keyname = @"IOStest/transferupload";
    //中文命名
    NSString *keyname = @"IOStest/数据流上传";
    
    //NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/d-1.txt";
    //NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/d-5m";
    //NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/d-6m";
    //NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/d-10m";
    
    //NSURL *testDataURL=[NSURL URLWithString:filepath];
    
    CSSPTransferManagerDownloadRequest *downloadRequest = [CSSPTransferManagerDownloadRequest new];
    downloadRequest.object= keyname;
    
    __block int64_t accumulatedDownloadBytes = 0;
    __block int64_t totalDownloadBytes = 0;
    __block int64_t totalExpectedDownloadBytes= 0;
    
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWtite){
        NSLog(@"-------------------------------------------");
        NSLog(@"object : %@ bytesWritten : %lld, totalBytesWritten : %lld, totalBytesExpectedToWtite : %lld ", keyname ,bytesWritten,totalBytesWritten , totalBytesExpectedToWtite);
        accumulatedDownloadBytes += bytesWritten;
        totalDownloadBytes = totalBytesWritten;
        totalExpectedDownloadBytes = totalBytesExpectedToWtite;
    };
    
    [[[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerDownloadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPTransferManagerDownloadOutput class]),[task.result description]);
        CSSPTransferManagerDownloadOutput *downloadoutput = task.result;
        NSURL *testDataURL=  downloadoutput.body;
        
        NSLog(@"%@",testDataURL);
        NSLog(@"*****************************************");
        
        
        return nil;
    }]waitUntilFinished];
    
}


-(void)testpauseupload{
    NSString *keyname = @"pauseupload-20m";
    NSString  *filepath= @"file:///Users/yayu/Project/cssp-ios-sdk/20m";
    NSURL *testDataURL=[NSURL URLWithString:filepath];
    
    
    CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
    uploadRequest.body= testDataURL;
    uploadRequest.object= keyname;
    
    __block int64_t accumulatedUploadBytes = 0;
    __block int64_t totalUploadBytes = 0;
    __block int64_t totalExpectedUploadBytes= 0;
    
    uploadRequest.uploadProgress = ^(int64_t bytesSend, int64_t totalBytesSend, int64_t totalBytesExpectedToSend){
        NSLog(@" totalBytestSend : %lld, ", totalBytesSend );
        accumulatedUploadBytes += bytesSend;
        totalUploadBytes = totalBytesSend;
        totalExpectedUploadBytes = totalBytesExpectedToSend;
        
    };
    
    
    BFTask *pausedtask = [[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error,@" Except got 'cancelld' Error ,but got nil");
        XCTAssertNil(task.result,@"task result shuld be nil since it has alreadly been cancelled");
        XCTAssertEqual(CSSPTransferManagerErrorDomain, task.error.domain);
        XCTAssertEqual(CSSPTransferManagerErrorPaused, task.error.code);
        return nil;
    }];
    
    //download 进行中
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateRunning);
    
    //等待3s
    NSLog(@"aaaaaaaaaaaaaaaaaaaaaaaaaa");
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    
    
    
    //上传暂停
    [[[uploadRequest pause] continueWithBlock:^id(BFTask *task){
        XCTAssertNil(task.error, @"the request failed. error:[%@]",task.error);
        return nil;
    }]waitUntilFinished];
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStatePaused);
    [pausedtask waitUntilFinished];
    
    NSLog(@"bbbbbbbbbbbbbbbbbbbbbbbbbbbb");
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:15]];
    
    
    //恢复上传
    uploadRequest.uploadProgress = ^(int64_t bytesSend, int64_t totalBytesSend, int64_t totalBytesExpectedToSend){
        NSLog(@"-------------------------------------------");
        NSLog(@"object : %@ bytesSend : %lld, totalBytestSend : %lld, totalBytesExceptedToSend : %lld ", keyname ,bytesSend,totalBytesSend , totalBytesExpectedToSend);
        accumulatedUploadBytes += bytesSend;
        totalUploadBytes = totalBytesSend;
        totalExpectedUploadBytes = totalBytesExpectedToSend;
        
    };
    
    
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerUploadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPTransferManagerUploadOutput class]),[task.result description]);
        CSSPTransferManagerUploadOutput *uploadouput = task.result;
        
        NSLog(@"%@",uploadouput.ETag);
        return nil;
    }]waitUntilFinished];
    
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateCompleted);
    
    
}



-(void)testpuasedownload{
    NSString *keyname = @"pauseupload-20m";
    CSSPTransferManagerDownloadRequest *downloadRequest = [CSSPTransferManagerDownloadRequest new];
    downloadRequest.object= keyname;
    
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateNotStarted);
    
    //调用download
    __block int64_t accumulatedDownloadBytes = 0;
    __block int64_t totalDownloadBytes = 0;
    __block int64_t totalExpectedDownloadBytes= 0;
    
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWtite){
        
        NSLog(@"totalBytesWritten : %lld,", totalBytesWritten );
        accumulatedDownloadBytes += bytesWritten;
        totalDownloadBytes = totalBytesWritten;
        totalExpectedDownloadBytes = totalBytesExpectedToWtite;
    };
    
    
    
    BFTask *pausedtask = [[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error,@" Except got 'cancelld' Error ,but got nil");
        XCTAssertNil(task.result,@"task result shuld be nil since it has alreadly been cancelled");
        XCTAssertEqual(CSSPTransferManagerErrorDomain, task.error.domain);
        XCTAssertEqual(CSSPTransferManagerErrorPaused, task.error.code);
        return nil;
    }];
    
    //download 进行中
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateRunning);
    
    //等待3s
    NSLog(@"aaaaaaaaaaaaaaaaaaaaaaaaaa");
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    
    
    //下载暂停
    [[[downloadRequest pause] continueWithBlock:^id(BFTask *task){
        XCTAssertNil(task.error, @"the request failed. error:[%@]",task.error);
        return nil;
    }]waitUntilFinished];
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStatePaused);
    [pausedtask waitUntilFinished];
    NSLog(@"bbbbbbbbbbbbbbbbbbbbbbbbbbbb");
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:15]];
    
    
    
    
    
    //恢复下载
    
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWtite){
        NSLog(@"-------------------------------------------");
        NSLog(@"object : %@ bytesWritten : %lld, totalBytesWritten : %lld, totalBytesExpectedToWtite : %lld ", keyname ,bytesWritten,totalBytesWritten , totalBytesExpectedToWtite);
        accumulatedDownloadBytes += bytesWritten;
        totalDownloadBytes = totalBytesWritten;
        totalExpectedDownloadBytes = totalBytesExpectedToWtite;
    };
    
    
    [[[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerDownloadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPTransferManagerDownloadOutput class]),[task.result description]);
        CSSPTransferManagerDownloadOutput *downloadoutput = task.result;
        NSURL *testDataURL=  downloadoutput.body;
        NSLog(@"%@",testDataURL);
        NSLog(@"*****************************************");
        return nil;
    }]waitUntilFinished];
    
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateCompleted);
    
    
}


@end
