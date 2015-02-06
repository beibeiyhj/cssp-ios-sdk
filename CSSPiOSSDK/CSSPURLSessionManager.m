//
//  CSSPURLSessionManager.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/5.
//  Copyright (c) 2015年 cssp. All rights reserved.
//
#import "CSSPURLSessionManager.h"
#import "CSSPSynchronizedMutableDictionary.h"
#import "Bolts.h"

#pragma mark - CSSPURLSessionManagerDelegate

static NSString* const CSSPMobileURLSessionManagerCacheDomain = @"com.cssp.CSSPURLSessionManager";

typedef NS_ENUM(NSInteger, CSSPURLSessionTaskType) {
    CSSPURLSessionTaskTypeUnknown,
    CSSPURLSessionTaskTypeData,
    CSSPURLSessionTaskTypeDownload,
    CSSPURLSessionTaskTypeUpload
};

@interface CSSPURLSessionManagerDelegate : NSObject

@property (nonatomic, assign) CSSPURLSessionTaskType taskType;
@property (nonatomic, copy)   CSSPNetworkingCompletionHandlerBlock dataTaskCompletionHandler;
@property (nonatomic, strong) CSSPNetworkingRequest *request;
@property (nonatomic, strong) NSURL *uploadingFileURL;
@property (nonatomic, strong) NSURL *downloadingFileURL;

@property (nonatomic, assign) uint32_t currentRetryCount;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSFileHandle *responseFilehandle;
@property (nonatomic, strong) NSURL *tempDownloadedFileURL;
@property (nonatomic, assign) BOOL shouldWriteDirectly;
@property (nonatomic, assign) BOOL shouldWriteToFile;

@property (atomic, assign) int64_t lastTotalLengthOfChunkSignatureSent;
@property (atomic, assign) int64_t payloadTotalBytesWritten;

@end

@implementation CSSPURLSessionManagerDelegate

- (instancetype)init {
    if (self = [super init]) {
        _taskType = CSSPURLSessionTaskTypeUnknown;
    }
    
    return self;
}

@end

#pragma mark - CSSPNetworkingRequest

@interface CSSPNetworkingRequest()

@property (nonatomic, strong) NSURLSessionTask *task;

@end

#pragma mark - CSSPURLSessionManager

@interface CSSPURLSessionManager()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) CSSPSynchronizedMutableDictionary *sessionManagerDelegates;

@end

@implementation CSSPURLSessionManager

- (instancetype)init {
    if (self = [super init]) {
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
        operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:operationQueue];
        _sessionManagerDelegates = [[CSSPSynchronizedMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dataTaskWithRequest:(CSSPNetworkingRequest *)request completionHandler:(CSSPNetworkingCompletionHandlerBlock)completionHandler {
    [request assignProperties:self.configuration];
    
    CSSPURLSessionManagerDelegate *delegate = [CSSPURLSessionManagerDelegate new];
    delegate.dataTaskCompletionHandler = completionHandler;
    delegate.request = request;
    delegate.taskType = CSSPURLSessionTaskTypeData;
    delegate.downloadingFileURL = request.downloadingFileURL;
    delegate.uploadingFileURL = request.uploadingFileURL;
    delegate.shouldWriteDirectly = request.shouldWriteDirectly;
    
    [self taskWithDelegate:delegate];
}

- (void)downloadTaskWithRequest:(CSSPNetworkingRequest *)request completionHandler:(CSSPNetworkingCompletionHandlerBlock)completionHandler {
    [request assignProperties:self.configuration];
    
    CSSPURLSessionManagerDelegate *delegate = [CSSPURLSessionManagerDelegate new];
    delegate.dataTaskCompletionHandler = completionHandler;
    delegate.request = request;
    delegate.taskType = CSSPURLSessionTaskTypeDownload;
    delegate.downloadingFileURL = request.downloadingFileURL;
    delegate.shouldWriteDirectly = request.shouldWriteDirectly;
}

- (void)uploadTaskWithRequest:(CSSPNetworkingRequest *)request completionHandler:(CSSPNetworkingCompletionHandlerBlock)completionHandler {
    [request assignProperties:self.configuration];
    
    CSSPURLSessionManagerDelegate *delegate = [CSSPURLSessionManagerDelegate new];
    delegate.dataTaskCompletionHandler = completionHandler;
    delegate.request = request;
    delegate.taskType = CSSPURLSessionTaskTypeUpload;
    delegate.uploadingFileURL = request.uploadingFileURL;
}

- (void)taskWithDelegate:(CSSPURLSessionManagerDelegate *)delegate{
    if (delegate.downloadingFileURL) delegate.shouldWriteToFile = YES;
    delegate.responseData = nil;
    delegate.responseObject = nil;
    delegate.error = nil;
    NSMutableURLRequest *mutableURLRequest = [NSMutableURLRequest requestWithURL:delegate.request.URL];
    
    [[[[[[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
        id signer = [delegate.request.requestInterceptors lastObject];
        if (signer) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([signer respondsToSelector:@selector(credentialsProvider)]) {
                id credentialsProvider = [signer performSelector:@selector(credentialsProvider)];
                if ([credentialsProvider respondsToSelector:@selector(refresh)]) {
                    NSString *accessKey = nil;
                    if ([credentialsProvider respondsToSelector:@selector(accessKey)]) {
                        accessKey = [credentialsProvider performSelector:@selector(accessKey)];
                    }
                    
                    NSString *secretKey = nil;
                    if ([credentialsProvider respondsToSelector:@selector(secretKey)]) {
                        secretKey = [credentialsProvider performSelector:@selector(secretKey)];
                    }
                    
                    NSDate *expiration = nil;
                    if  ([credentialsProvider respondsToSelector:@selector(expiration)]) {
                        expiration = [credentialsProvider performSelector:@selector(expiration)];
                    }
                    
                    /**
                     Preemptively refresh credentials if any of the following is true:
                     1. accessKey or secretKey is nil.
                     2. the credentials expires within 10 minutes.
                     */
                    if ((!accessKey || !secretKey)
                        || [expiration compare:[NSDate dateWithTimeIntervalSinceNow:10 * 60]] == NSOrderedAscending) {
                        return [credentialsProvider performSelector:@selector(refresh)];
                    }
            }
        }
#pragma clang diagnostic pop
    }
        return nil;
    }]continueWithSuccessBlock:^id(BFTask *task) {
            CSSPNetworkingRequest *request = delegate.request;
            if (request.isCancelled) {
                if (delegate.dataTaskCompletionHandler) {
                    CSSPNetworkingCompletionHandlerBlock completionHandler = delegate.dataTaskCompletionHandler;
                    completionHandler(nil, [NSError errorWithDomain:CSSPNetworkingErrorDomain
                                                               code:CSSPNetworkingErrorCancelled
                                                           userInfo:nil]);
                }
                return nil;
            }
            
            mutableURLRequest.HTTPMethod = [NSString cssp_stringWithHTTPMethod:delegate.request.HTTPMethod];
            
            if ([request.requestSerializer respondsToSelector:@selector(serializeRequest:headers:parameters:)]) {
                BFTask *resultTask = [request.requestSerializer serializeRequest:mutableURLRequest
                                                                         headers:request.headers
                                                                      parameters:request.parameters];
                //if serialization has error, abort task.
                if (resultTask.error) {
                    return resultTask;
                }
            }
            
            BFTask *sequencialTask = [BFTask taskWithResult:nil];
            for(id<CSSPNetworkingRequestInterceptor>interceptor in request.requestInterceptors) {
                if ([interceptor respondsToSelector:@selector(interceptRequest:)]) {
                    sequencialTask = [sequencialTask continueWithSuccessBlock:^id(BFTask *task) {
                        return [interceptor interceptRequest:mutableURLRequest];
                    }];
                }
            }
        
            return task;
    }]continueWithSuccessBlock:^id(BFTask *task) {
        CSSPNetworkingRequest *request = delegate.request;
        if ([request.requestSerializer respondsToSelector:@selector(validateRequest:)]) {
            return [request.requestSerializer validateRequest:mutableURLRequest];
        } else {
            return [BFTask taskWithResult:nil];
        }
    }] continueWithSuccessBlock:^id(BFTask *task) {
        switch (delegate.taskType) {
            case CSSPURLSessionTaskTypeData:
                delegate.request.task = [self.session dataTaskWithRequest:mutableURLRequest];
                break;
                
            case CSSPURLSessionTaskTypeDownload:
                delegate.request.task = [self.session downloadTaskWithRequest:mutableURLRequest];
                break;
                
            case CSSPURLSessionTaskTypeUpload:
                delegate.request.task = [self.session uploadTaskWithRequest:mutableURLRequest
                                                                   fromFile:delegate.uploadingFileURL];
                break;
                
            default:
                break;
        }
        
        if (delegate.request.task) {
            [self.sessionManagerDelegates setObject:delegate
                                             forKey:@(((NSURLSessionTask *)delegate.request.task).taskIdentifier)];
            [delegate.request.task resume];
        } else {
            NSLog(@"Invalid AWSURLSessionTaskType.");
        }
        
        return nil;
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            if (delegate.dataTaskCompletionHandler) {
                CSSPNetworkingCompletionHandlerBlock completionHandler = delegate.dataTaskCompletionHandler;
                completionHandler(nil, task.error);
            }
        }
        return nil;
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)sessionTask didCompleteWithError:(NSError *)error{
    [[[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
        CSSPURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(sessionTask.taskIdentifier)];
        
        if (delegate.responseFilehandle)
            [delegate.responseFilehandle closeFile];
        
        if (!delegate.error)
            delegate.error = error;
        
        //delete temporary file if the task contains error (e.g. has been canceled)
        if (error && delegate.tempDownloadedFileURL) {
            [[NSFileManager defaultManager] removeItemAtPath:delegate.tempDownloadedFileURL.path error:nil];
        }
        
        if (!delegate.error
            && [sessionTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)sessionTask.response;
            
            // need to call responseSerializer if there is no client-side error.
            if ([delegate.request.responseSerializer respondsToSelector:@selector(responseObjectForResponse:originalRequest:currentRequest:data:error:)]) {
                NSError *error = nil;
                delegate.responseObject = [delegate.request.responseSerializer responseObjectForResponse:httpResponse
                                                                                         originalRequest:sessionTask.originalRequest
                                                                                          currentRequest:sessionTask.currentRequest
                                                                                                    data:delegate.responseData
                                                                                                   error:&error];
                if (error)
                    delegate.error = error;
                    
            }else {
                delegate.responseObject = delegate.responseData;
            }
        }
        
        if (delegate.dataTaskCompletionHandler){
            CSSPNetworkingCompletionHandlerBlock completionHandler = delegate.dataTaskCompletionHandler;
            completionHandler(delegate.responseObject, delegate.error);
        }
        return nil;
    }] continueWithBlock:^id(BFTask *task) {
        [self.sessionManagerDelegates removeObjectForKey:@(sessionTask.taskIdentifier)];
        return nil;
    }];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    CSSPURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(task.taskIdentifier)];
    CSSPNetworkingUploadProgressBlock uploadProgress = delegate.request.uploadProgress;
    if (uploadProgress) {
        NSURLSessionTask *sessionTask = delegate.request.task;
//        int64_t originalDataLength = [[[sessionTask.originalRequest allHTTPHeaderFields] objectForKey:@"x-amz-decoded-content-length"] longLongValue];
//        NSInputStream *inputStream = (CSSPChunkedEncodingInputStream *)sessionTask.originalRequest.HTTPBodyStream;
//        if ([inputStream isKindOfClass:[CSSPChunkedEncodingInputStream class]]) {
//            CSSPChunkedEncodingInputStream *chunkedInputStream = (AWSS3ChunkedEncodingInputStream *)inputStream;
//            int64_t payloadBytesSent = bytesSent;
//            if (chunkedInputStream.totalLengthOfChunkSignatureSent > delegate.lastTotalLengthOfChunkSignatureSent) {
//                payloadBytesSent = bytesSent - (chunkedInputStream.totalLengthOfChunkSignatureSent - delegate.lastTotalLengthOfChunkSignatureSent);
//            }
//            delegate.lastTotalLengthOfChunkSignatureSent = chunkedInputStream.totalLengthOfChunkSignatureSent;
//            
//            uploadProgress(payloadBytesSent, totalBytesSent - chunkedInputStream.totalLengthOfChunkSignatureSent, originalDataLength);
//        }else {
//            uploadProgress(bytesSent, totalBytesSent, totalBytesExpectedToSend);
//        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *))completionHandler{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler{
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    CSSPURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(downloadTask.taskIdentifier)];
    delegate.request.task = downloadTask;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    CSSPURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(dataTask.taskIdentifier)];
    
    if (delegate.responseFilehandle) {
        [delegate.responseFilehandle writeData:data];
    } else {
        if (!delegate.responseData) {
            delegate.responseData = [NSMutableData dataWithData:data];
        } else if ([delegate.responseData isKindOfClass:[NSMutableData class]]) {
            [delegate.responseData appendData:data];
        }
    }
    
    CSSPNetworkingDownloadProgressBlock downloadProgress = delegate.request.downloadProgress;
    if (downloadProgress) {
        
        int64_t bytesWritten = [data length];
        delegate.payloadTotalBytesWritten += bytesWritten;
        int64_t byteRangeStartPosition = 0;
        int64_t totalBytesExpectedToWrite = dataTask.response.expectedContentLength;
        if ([dataTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)dataTask.response;
            NSString *contentRangeString = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
            int64_t trueContentLength = [[[contentRangeString componentsSeparatedByString:@"/"] lastObject] longLongValue];
            if (trueContentLength) {
                byteRangeStartPosition = trueContentLength - dataTask.response.expectedContentLength;
                totalBytesExpectedToWrite = trueContentLength;
            }
        }
        downloadProgress(bytesWritten,delegate.payloadTotalBytesWritten + byteRangeStartPosition,totalBytesExpectedToWrite);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    CSSPURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(dataTask.taskIdentifier)];
    
    //If the response code is not 2xx, avoid write data to disk
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 ) {
            // status is good, we can keep value of shouldWriteToFile
        } else {
            // got error status code, avoid write data to disk
            delegate.shouldWriteToFile = NO;
        }
    }
    if (delegate.shouldWriteToFile) {
        
        if (delegate.shouldWriteDirectly) {
            //If set (e..g by S3 Transfer Manager), downloaded data will be wrote to the downloadingFileURL directly, if the file already exists, it will appended to the end.
            NSLog(@"DirectWrite is On, downloaded data will be wrote to the downloadingFileURL directly, if the file already exists, it will appended to the end.\
                        Original file may be modified even the downloading task has been paused/cancelled later.");
            
            NSError *error = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:delegate.downloadingFileURL.path]) {
                NSLog(@"target file already exists, will be appended at the file path: %@",delegate.downloadingFileURL);
                delegate.responseFilehandle = [NSFileHandle fileHandleForUpdatingURL:delegate.downloadingFileURL error:&error];
                if (error) {
                    NSLog(@"Error: [%@]", error);
                }
                [delegate.responseFilehandle seekToEndOfFile];
                
            } else {
                //Create the file
                if (![[NSFileManager defaultManager] createFileAtPath:delegate.downloadingFileURL.path contents:nil attributes:nil]) {
                    NSLog(@"Error: Can not create file with file path:%@",delegate.downloadingFileURL.path);
                }
                error = nil;
                delegate.responseFilehandle = [NSFileHandle fileHandleForWritingToURL:delegate.downloadingFileURL error:&error];
                if (error) {
                    NSLog(@"Error: [%@]", error);
                }
            }
            
        } else {
//            NSError *error = nil;
//            //This is the normal case. downloaded data will be saved in a temporay folder and then moved to downloadingFileURL after downloading complete.
//            NSString *tempFileName = [NSString stringWithFormat:@"%@.%@",AWSMobileURLSessionManagerCacheDomain,[[NSProcessInfo processInfo] globallyUniqueString]];
//            NSString *tempDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.fileCache",AWSMobileURLSessionManagerCacheDomain]];
//            
//            //Create temp folder if not exist
//            [[NSFileManager defaultManager] createDirectoryAtPath:tempDirPath withIntermediateDirectories:NO attributes:nil error:nil];
//            
//            delegate.tempDownloadedFileURL  = [NSURL fileURLWithPath:[tempDirPath stringByAppendingPathComponent:tempFileName]];
//            
//            //Remove temp file if it has already exists
//            if ([[NSFileManager defaultManager] fileExistsAtPath:delegate.tempDownloadedFileURL.path]) {
//                NSLog(@"Warning: target file already exists, will be overwritten at the file path: %@",delegate.tempDownloadedFileURL);
//                [[NSFileManager defaultManager] removeItemAtPath:delegate.tempDownloadedFileURL.path error:&error];
//            }
//            if (error) {
//                NSLog(@"Error: [%@]", error);
//            }
//            
//            //Create new temp file
//            if (![[NSFileManager defaultManager] createFileAtPath:delegate.tempDownloadedFileURL.path contents:nil attributes:nil]) {
//                NSLog(@"Error: Can not create file with file path:%@",delegate.tempDownloadedFileURL.path);
//            }
//            error = nil;
//            delegate.responseFilehandle = [NSFileHandle fileHandleForWritingToURL:delegate.tempDownloadedFileURL error:&error];
//            if (error) {
//                NSLog(@"Error: [%@]", error);
//            }
        }
        
    }
    
    //    if([response isKindOfClass:[NSHTTPURLResponse class]]) {
    //        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    //        if ([[[httpResponse allHeaderFields] objectForKey:@"Content-Length"] longLongValue] >= AWSMinimumDownloadTaskSize) {
    //            completionHandler(NSURLSessionResponseBecomeDownload);
    //            return;
    //        }
    //    }
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    CSSPURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(downloadTask.taskIdentifier)];
    if (!delegate.error) {
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtURL:location
                                                toURL:delegate.downloadingFileURL
                                                error:&error];
        if (error) {
            delegate.error = error;
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    CSSPURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(downloadTask.taskIdentifier)];
    CSSPNetworkingDownloadProgressBlock downloadProgress = delegate.request.downloadProgress;
    if (downloadProgress) {
        downloadProgress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}
@end
