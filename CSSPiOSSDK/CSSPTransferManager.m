//
//  CSSPTransferManager.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/3/17.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPTransferManager.h"
#import "TMCache.h"

NSUInteger const CSSPTransferManagerMinimumPartSize = 5 * 1024 * 1024; // 5MB
NSString *const CSSPTransferManagerCacheName = @"com.iflytekcssp.CSSPTransferManager.CacheName";
NSString *const CSSPTransferManagerErrorDomain = @"com.iflytekcssp.CSSPTransferManagerErrorDomain";
NSUInteger const CSSPTransferManagerByteLimitDefault = 5 * 1024 * 1024; // 5MB
NSTimeInterval const CSSPTransferManagerAgeLimitDefault = 0.0; // Keeps the data indefinitely unless it hits the size limit.

@interface CSSPTransferManager()

@property (nonatomic, strong) TMCache *cache;

@end

@implementation CSSPTransferManager

+(CSSPTransferManager *)initialize {
    static CSSPTransferManager *shareObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObj = [[self alloc] init];
    });
    return shareObj;
}

- (instancetype)initWithConfiguration:(CSSPServiceConfiguration *)configuration {
    NSString *accessKey = nil;
    if ([configuration.credentialsProvider performSelector:@selector(accessKey)])
        accessKey = [configuration.credentialsProvider performSelector:@selector(accessKey)];
    
    if (self = [self initWithConfiguration:configuration
                                 cacheName:[NSString stringWithFormat:@"%@.%@", CSSPTransferManagerCacheName, accessKey]]) {
    }
    
    return self;
}

- (instancetype)initWithConfiguration:(CSSPServiceConfiguration *)configuration
                            cacheName:(NSString *)cacheName {
    if (self = [super init]) {
        [[CSSP initialize] initWithConfiguration:configuration];
        _cache = [[TMCache alloc] initWithName:cacheName
                                      rootPath:[NSTemporaryDirectory() stringByAppendingPathComponent:CSSPTransferManagerCacheName]];
        _cache.diskCache.byteLimit = CSSPTransferManagerByteLimitDefault;
        _cache.diskCache.ageLimit = CSSPTransferManagerAgeLimitDefault;
    }
    return self;
}

- (BFTask *)upload:(CSSPTransferManagerUploadRequest *)uploadRequest {
    //validate input
    if ([uploadRequest.bucket length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'bucket' name can not be empty", nil)};
        return [BFTask taskWithError:[NSError errorWithDomain:AWSS3TransferManagerErrorDomain code:AWSS3TransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }
    if ([uploadRequest.key length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'key' name can not be empty", nil)};
        return [BFTask taskWithError:[NSError errorWithDomain:AWSS3TransferManagerErrorDomain code:AWSS3TransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }
    if (uploadRequest.body == nil) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'body' can not be nil", nil)};
        return [BFTask taskWithError:[NSError errorWithDomain:AWSS3TransferManagerErrorDomain code:AWSS3TransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
        
    } else if ([uploadRequest.body isKindOfClass:[NSURL class]] == NO) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid 'body' Type, must be an instance of NSURL Class", nil)};
        return [BFTask taskWithError:[NSError errorWithDomain:AWSS3TransferManagerErrorDomain code:AWSS3TransferManagerErrorInvalidParameters userInfo:userInfo]];
    }
    
    //Check if the task has already completed
    if (uploadRequest.state == AWSS3TransferManagerRequestStateCompleted) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to upload a completed task", nil)]};
        return [BFTask taskWithError:[NSError errorWithDomain:AWSS3TransferManagerErrorDomain code:AWSS3TransferManagerErrorCompleted userInfo:userInfo]];
    } else if (uploadRequest.state == AWSS3TransferManagerRequestStateCanceling){
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to upload a cancelled task.", nil)]};
        return [BFTask taskWithError:[NSError errorWithDomain:AWSS3TransferManagerErrorDomain code:AWSS3TransferManagerErrorCancelled userInfo:userInfo]];
    } else {
        //change state to running
        [uploadRequest setValue:[NSNumber numberWithInteger:AWSS3TransferManagerRequestStateRunning] forKey:@"state"];
    }
    
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[uploadRequest.body path] stringByResolvingSymlinksInPath]
                                                                                error:&error];
    if (error) {
        return [BFTask taskWithError:error];
    }
    
    unsigned long long fileSize = [attributes fileSize];
    
    BFTask *task = [BFTask taskWithResult:nil];
    task = [[[task continueWithSuccessBlock:^id(BFTask *task) {
        [self.cache setObject:uploadRequest
                       forKey:cacheKey];
        return nil;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (fileSize > AWSS3TransferManagerMinimumPartSize) {
            return [self multipartUpload:uploadRequest fileSize:fileSize cacheKey:cacheKey];
        } else {
            return [self putObject:uploadRequest fileSize:fileSize cacheKey:cacheKey];
        }
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:NSURLErrorDomain]
                && task.error.code == NSURLErrorCancelled) {
                if (uploadRequest.state == AWSS3TransferManagerRequestStatePaused) {
                    return [BFTask taskWithError:[NSError errorWithDomain:AWSS3TransferManagerErrorDomain
                                                                     code:AWSS3TransferManagerErrorPaused
                                                                 userInfo:task.error.userInfo]];
                } else {
                    return [BFTask taskWithError:[NSError errorWithDomain:AWSS3TransferManagerErrorDomain
                                                                     code:AWSS3TransferManagerErrorCancelled
                                                                 userInfo:task.error.userInfo]];
                }
            } else {
                return [BFTask taskWithError:task.error];
            }
        } else {
            [uploadRequest setValue:[NSNumber numberWithInteger:AWSS3TransferManagerRequestStateCompleted]
                             forKey:@"state"];
            return [BFTask taskWithResult:task.result];
        }
    }];
    
    return task;
}

- (BFTask *)download:(CSSPTransferManagerDownloadRequest *)downloadRequest {
    return nil;
}

- (BFTask *)cancelAll {
    return nil
}

- (BFTask *)pauseAll {
    
}

- (BFTask *)resumeAll:(CSSPTransferManagerResumeAllBlock)block {
    
}

- (BFTask *)clearCache {
    
}
@end


@interface CSSPTransferManagerUploadRequest ()

@property (nonatomic, assign) CSSPTransferManagerRequestState state;
@property (nonatomic, assign) NSUInteger currentUploadingPartNumber;
@property (nonatomic, strong) NSMutableArray *completedPartsArray;
@property (nonatomic, strong) NSString *uploadId;
@property (nonatomic, strong) NSString *cacheIdentifier;
@property (atomic, strong) CSSPUploadPartRequest *currentUploadingPart;

@property (atomic, assign) int64_t totalSuccessfullySentPartsDataLength;
@end


@implementation CSSPTransferManagerUploadRequest

-(instancetype)init {
    if (self = [super init]) {
        _state = CSSPTransferManagerRequestStateNotStarted;
    }
    
    return self;
}

- (BFTask *)cancel {
    if (self.state != CSSPTransferManagerRequestStateCompleted) {
        self.state = CSSPTransferManagerRequestStateCanceling;
        
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self.body path] stringByResolvingSymlinksInPath]
                                                                                    error:nil];
        unsigned long long fileSize = [attributes fileSize];
        if (fileSize > CSSPTransferManagerMinimumPartSize) {
            //If using multipart upload, need to cancel current parts upload and send AbortMultiPartUpload Request.
            [self.currentUploadingPart cancel];
            
        } else {
            //Otherwise, just call super to cancel current task.
            return [super cancel];
        }
    }
    return [BFTask taskWithResult:nil];
}

- (BFTask *)pause {
    switch (self.state) {
        case CSSPTransferManagerRequestStateCompleted: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Can not pause a completed task.", nil)]};
            return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorCompleted userInfo:userInfo]];
        }
            break;
        case CSSPTransferManagerRequestStateCanceling: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Can not pause a cancelled task.", nil)]};
            return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorCancelled userInfo:userInfo]];
        }
            break;
        default: {
            //change state to Paused
            self.state = CSSPTransferManagerRequestStatePaused;
            //pause the current uploadTask
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self.body path] stringByResolvingSymlinksInPath]
                                                                                        error:nil];
            unsigned long long fileSize = [attributes fileSize];
            if (fileSize > CSSPTransferManagerMinimumPartSize) {
                //If using multipart upload, need to check state flag and then pause the current parts upload and save the current status.
                [self.currentUploadingPart pause];
            } else {
                //otherwise, pause the current task. (cancel without set isCancelled flag)
                [super pause];
            }
            
            return [BFTask taskWithResult:nil];
        }
            break;
    }
}

@end

@implementation CSSPTransferManagerUploadOutput

@end

@interface CSSPTransferManagerDownloadRequest ()

@property (nonatomic, assign) CSSPTransferManagerRequestState state;
@property (nonatomic, strong) NSString *cacheIdentifier;

@end

@implementation CSSPTransferManagerDownloadRequest

- (instancetype)init {
    if (self = [super init]) {
        _state = CSSPTransferManagerRequestStateNotStarted;
    }
    
    return self;
}

- (BFTask *)cancel {
    if (self.state != CSSPTransferManagerRequestStateCompleted) {
        self.state = CSSPTransferManagerRequestStateCanceling;
        return [super cancel];
    }
    return [BFTask taskWithResult:nil];
}

- (BFTask *)pause {
    switch (self.state) {
        case CSSPTransferManagerRequestStateCompleted: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Can not pause a completed task.", nil)]};
            return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorCompleted userInfo:userInfo]];
        }
            break;
        case CSSPTransferManagerRequestStateCanceling: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Can not pause a cancelled task.", nil)]};
            return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorCancelled userInfo:userInfo]];
        }
            break;
        default: {
            //change state to Paused
            self.state = CSSPTransferManagerRequestStatePaused;
            //pause the current download task (i.e. cancel without set the isCancelled flag)
            [super pause];
            return [BFTask taskWithResult:nil];
        }
            break;
    }
}

@end

@implementation CSSPTransferManagerDownloadOutput

@end