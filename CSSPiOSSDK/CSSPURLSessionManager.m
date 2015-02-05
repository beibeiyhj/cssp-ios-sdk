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

static NSString* const CSSPMobileURLSessionManagerCacheDomain = @"com.CSSP.CSSPURLSessionManager";

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
    
    [[[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
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
            
//            if ([request.requestSerializer respondsToSelector:@selector(serializeRequest:headers:parameters:)]) {
//                BFTask *resultTask = [request.requestSerializer serializeRequest:mutableURLRequest
//                                                                         headers:request.headers
//                                                                      parameters:request.parameters];
//                //if serialization has error, abort task.
//                if (resultTask.error) {
//                    return resultTask;
//                }
//            }
//            
//            BFTask *sequencialTask = [BFTask taskWithResult:nil];
//            for(id<CSSPNetworkingRequestInterceptor>interceptor in request.requestInterceptors) {
//                if ([interceptor respondsToSelector:@selector(interceptRequest:)]) {
//                    sequencialTask = [sequencialTask continueWithSuccessBlock:^id(BFTask *task) {
//                        return [interceptor interceptRequest:mutableURLRequest];
//                    }];
//                }
//            }
        
            return task;
    }]continueWithSuccessBlock:^id(BFTask *task) {
//        CSSPNetworkingRequest *request = delegate.request;
//        if ([request.requestSerializer respondsToSelector:@selector(validateRequest:)]) {
//            return [request.requestSerializer validateRequest:mutableURLRequest];
//        } else {
//            return [BFTask taskWithResult:nil];
//        }
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

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *))completionHandler{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler{
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}
@end
