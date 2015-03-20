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

@interface CSSPTransferManagerUploadRequest ()

@property (nonatomic, assign) CSSPTransferManagerRequestState state;
@property (nonatomic, assign) NSUInteger currentUploadingPartNumber;
@property (nonatomic, strong) NSMutableArray *completedPartsArray;
@property (nonatomic, strong) NSString *uploadId;
@property (nonatomic, strong) NSString *cacheIdentifier;
@property (atomic, strong) CSSPUploadPartRequest *currentUploadingPart;

@property (atomic, assign) int64_t totalSuccessfullySentPartsDataLength;
@end

@interface CSSPTransferManagerDownloadRequest ()

@property (nonatomic, assign) CSSPTransferManagerRequestState state;
@property (nonatomic, strong) NSString *cacheIdentifier;

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

- (void)initWithConfiguration:(CSSPServiceConfiguration *)configuration {
    NSString *accessKey = nil;
    if ([configuration.credentialsProvider performSelector:@selector(accessKey)])
        accessKey = [configuration.credentialsProvider performSelector:@selector(accessKey)];
    
    [self initWithConfiguration:configuration
                      cacheName:[NSString stringWithFormat:@"%@.%@", CSSPTransferManagerCacheName, accessKey]];
}

- (void)initWithConfiguration:(CSSPServiceConfiguration *)configuration
                            cacheName:(NSString *)cacheName {
    if ([super init]) {
        [[CSSP initialize] initWithConfiguration:configuration];
        _cache = [[TMCache alloc] initWithName:cacheName
                                      rootPath:[NSTemporaryDirectory() stringByAppendingPathComponent:CSSPTransferManagerCacheName]];
        _cache.diskCache.byteLimit = CSSPTransferManagerByteLimitDefault;
        _cache.diskCache.ageLimit = CSSPTransferManagerAgeLimitDefault;
    }
}

- (BFTask *)upload:(CSSPTransferManagerUploadRequest *)uploadRequest {
    
    NSString *cacheKey = nil;
    if ([uploadRequest valueForKey:@"cacheIdentifier"]) {
        cacheKey = [uploadRequest valueForKey:@"cacheIdentifier"];
    } else {
        cacheKey = [[NSProcessInfo processInfo] globallyUniqueString];
        [uploadRequest setValue:cacheKey forKey:@"cacheIdentifier"];
    }
    
    return [self upload:uploadRequest cacheKey:cacheKey];
}


- (BFTask *)upload:(CSSPTransferManagerUploadRequest *)uploadRequest
          cacheKey:(NSString *)cacheKey {
    
    //validate input
    if ([uploadRequest.object length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'key' name can not be empty", nil)};
        return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }
    if (uploadRequest.body == nil) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'body' can not be nil", nil)};
        return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
        
    } else if ([uploadRequest.body isKindOfClass:[NSURL class]] == NO) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid 'body' Type, must be an instance of NSURL Class", nil)};
        return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorInvalidParameters userInfo:userInfo]];
    }
    
    //Check if the task has already completed
    if (uploadRequest.state == CSSPTransferManagerRequestStateCompleted) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to upload a completed task", nil)]};
        return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorCompleted userInfo:userInfo]];
    } else if (uploadRequest.state == CSSPTransferManagerRequestStateCanceling){
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to upload a cancelled task.", nil)]};
        return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorCancelled userInfo:userInfo]];
    } else {
        //change state to running
        [uploadRequest setValue:[NSNumber numberWithInteger:CSSPTransferManagerRequestStateRunning] forKey:@"state"];
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
        if (fileSize > CSSPTransferManagerMinimumPartSize) {
            return [self multipartUpload:uploadRequest fileSize:fileSize cacheKey:cacheKey];
        } else {
            return [self putObject:uploadRequest fileSize:fileSize cacheKey:cacheKey];
        }
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:NSURLErrorDomain]
                && task.error.code == NSURLErrorCancelled) {
                if (uploadRequest.state == CSSPTransferManagerRequestStatePaused) {
                    return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain
                                                                     code:CSSPTransferManagerErrorPaused
                                                                 userInfo:task.error.userInfo]];
                } else {
                    return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain
                                                                     code:CSSPTransferManagerErrorCancelled
                                                                 userInfo:task.error.userInfo]];
                }
            } else {
                return [BFTask taskWithError:task.error];
            }
        } else {
            [uploadRequest setValue:[NSNumber numberWithInteger:CSSPTransferManagerRequestStateCompleted]
                             forKey:@"state"];
            return [BFTask taskWithResult:task.result];
        }
    }];
    
    return task;
}

- (BFTask *)putObject:(CSSPTransferManagerUploadRequest *)uploadRequest
             fileSize:(unsigned long long) fileSize
             cacheKey:(NSString *)cacheKey {
    uploadRequest.contentLength = [NSNumber numberWithUnsignedLongLong:fileSize];
    CSSPPutObjectRequest *putObjectRequest = [CSSPPutObjectRequest new];
    [putObjectRequest cssp_copyPropertiesFromObject:uploadRequest];
    
    BFTask *uploadTask = [[[CSSP initialize] putObject:putObjectRequest] continueWithBlock:^id(BFTask *task) {
        
        //delete cached Object if state is not Paused
        if (uploadRequest.state != CSSPTransferManagerRequestStatePaused) {
            [self.cache removeObjectForKey:cacheKey];
        }
        if (task.error) {
            return [BFTask taskWithError:task.error];
        }
        
        CSSPTransferManagerUploadOutput *uploadOutput = [CSSPTransferManagerUploadOutput new];
        if (task.result) {
            CSSPPutObjectOutput *putObjectOutput = task.result;
            [uploadOutput cssp_copyPropertiesFromObject:putObjectOutput];
        }
        
        return uploadOutput;
    }];
    
    return uploadTask;
}

- (BFTask *)multipartUpload:(CSSPTransferManagerUploadRequest *)uploadRequest
                   fileSize:(unsigned long long) fileSize
                   cacheKey:(NSString *)cacheKey {
    NSUInteger partCount = ceil((double)fileSize / CSSPTransferManagerMinimumPartSize);
    
    BFTask *initRequest = nil;
    
    //if it is a new request, Init multipart upload request
    if ([[uploadRequest valueForKey:@"currentUploadingPartNumber"] integerValue] == 0) {
        CSSPCreateMultipartUploadRequest *createMultipartUploadRequest = [CSSPCreateMultipartUploadRequest new];
        [createMultipartUploadRequest cssp_copyPropertiesFromObject:uploadRequest];
        [createMultipartUploadRequest setValue:[CSSPNetworkingRequest new] forKey:@"internalRequest"]; //recreate a new internalRequest
        initRequest = [[CSSP initialize] createMultipartUpload:createMultipartUploadRequest];
        [uploadRequest setValue:[NSMutableArray arrayWithCapacity:partCount] forKey:@"completedPartsArray"];
    } else {
        //if it is a paused request, skip initMultipart Upload request.
        initRequest = [BFTask taskWithResult:nil];
    }
    
    CSSPCompleteMultipartUploadRequest *completeMultipartUploadRequest = [CSSPCompleteMultipartUploadRequest new];
    [completeMultipartUploadRequest cssp_copyPropertiesFromObject:uploadRequest];
    [completeMultipartUploadRequest setValue:[CSSPNetworkingRequest new] forKey:@"internalRequest"]; //recreate a new internalRequest
    
    BFTask *uploadTask = [[[initRequest continueWithSuccessBlock:^id(BFTask *task) {
        CSSPCreateMultipartUploadOutput *output = task.result;
        
        if (output.uploadId) {
            completeMultipartUploadRequest.uploadId = output.uploadId;
            uploadRequest.uploadId = output.uploadId; //pass uploadId to the request for reference.
        } else {
            completeMultipartUploadRequest.uploadId = uploadRequest.uploadId;
        }
        
        BFTask *uploadPartsTask = [BFTask taskWithResult:nil];
        NSInteger c = [[uploadRequest valueForKey:@"currentUploadingPartNumber"] integerValue];
        if (c == 0) {
            c = 1;
        }
        
        __block int64_t multiplePartsTotalBytesSent = 0;
        
        for (NSInteger i = c; i < partCount + 1; i++) {
            uploadPartsTask = [uploadPartsTask continueWithSuccessBlock:^id(BFTask *task) {
                
                //Cancel this task if state is canceling
                if (uploadRequest.state == CSSPTransferManagerRequestStateCanceling) {
                    //return a error task
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"S3 MultipartUpload has been cancelled.", nil)]};
                    return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorCancelled userInfo:userInfo]];
                }
                //Pause this task if state is Paused
                if (uploadRequest.state == CSSPTransferManagerRequestStatePaused) {
                    
                    //return an error task
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"S3 MultipartUpload has been paused.", nil)]};
                    return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorPaused userInfo:userInfo]];
                }
                
                //if task can be contiuned, set the count, save the current partCount number
                [uploadRequest setValue:[NSNumber numberWithInteger:i] forKey:@"currentUploadingPartNumber"];
                
                NSUInteger dataLength = i == partCount ? (NSUInteger)fileSize - ((i - 1) * CSSPTransferManagerMinimumPartSize) : CSSPTransferManagerMinimumPartSize;
                
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[uploadRequest.body path]];
                [fileHandle seekToFileOffset:(i - 1) * CSSPTransferManagerMinimumPartSize];
                NSData *partData = [fileHandle readDataOfLength:dataLength];
                NSURL *tempURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]]];
                [partData writeToURL:tempURL atomically:YES];
                partData = nil;
                [fileHandle closeFile];
                
                CSSPUploadPartRequest *uploadPartRequest = [CSSPUploadPartRequest new];
                uploadPartRequest.object = uploadRequest.object;
                uploadPartRequest.partNumber = @(i);
                uploadPartRequest.body = tempURL;
                uploadPartRequest.contentLength = @(dataLength);
                uploadPartRequest.uploadId = output.uploadId?output.uploadId:uploadRequest.uploadId;
                
                uploadRequest.currentUploadingPart = uploadPartRequest; //retain the current uploading parts for cancel/pause purpose
                
                //reprocess the progressFeed received from s3 client
                uploadPartRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                    
                    CSSPNetworkingRequest *internalRequest = [uploadRequest valueForKey:@"internalRequest"];
                    if (internalRequest.uploadProgress) {
                        int64_t previousSentDataLengh = [[uploadRequest valueForKey:@"totalSuccessfullySentPartsDataLength"] longLongValue];
                        if (multiplePartsTotalBytesSent == 0) {
                            multiplePartsTotalBytesSent += bytesSent;
                            multiplePartsTotalBytesSent += previousSentDataLengh;
                            internalRequest.uploadProgress(bytesSent,multiplePartsTotalBytesSent,fileSize);
                        } else {
                            multiplePartsTotalBytesSent += bytesSent;
                            internalRequest.uploadProgress(bytesSent,multiplePartsTotalBytesSent,fileSize);
                        }
                    }
                };
                
                return [[[[CSSP initialize] uploadPart:uploadPartRequest] continueWithSuccessBlock:^id(BFTask *task) {
                    CSSPUploadPartOutput *partOuput = task.result;
                    
                    CSSPCompletedPart *completedPart = [CSSPCompletedPart new];
                    completedPart.partNumber = @(i);
                    completedPart.ETag = partOuput.ETag;
                    
                    NSMutableArray *completedParts = [uploadRequest valueForKey:@"completedPartsArray"];
                    
                    if (![completedParts containsObject:completedPart]) {
                        [completedParts addObject:completedPart];
                    }
                    
                    int64_t totalSentLenght = [[uploadRequest valueForKey:@"totalSuccessfullySentPartsDataLength"] longLongValue];
                    totalSentLenght += dataLength;
                    
                    [uploadRequest setValue:@(totalSentLenght) forKey:@"totalSuccessfullySentPartsDataLength"];
                    
                    //set currentUploadingPartNumber to i+1 to prevent it be downloaded again if pause happened right after parts finished.
                    [uploadRequest setValue:[NSNumber numberWithInteger:i+1] forKey:@"currentUploadingPartNumber"];
                    
                    return nil;
                }] continueWithBlock:^id(BFTask *task) {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtURL:tempURL
                                                              error:&error];
                    if (error) {
                        CSSPLogError(@"Failed to delete a temporary file for part upload: [%@]", error);
                    }
                    
                    if (task.error) {
                        return [BFTask taskWithError:task.error];
                    } else {
                        return nil;
                    }
                }];
            }];
        }
        
        return uploadPartsTask;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        
        //If all parts upload succeed, send completeMultipartUpload request
        NSMutableArray *completedParts = [uploadRequest valueForKey:@"completedPartsArray"];
        if ([completedParts count] != partCount) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"completedParts count is not equal to totalPartCount. expect %lu but got %lu",(unsigned long)partCount,(unsigned long)[completedParts count]],@"completedParts":completedParts};
            return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain
                                                             code:CSSPTransferManagerErrorUnknown
                                                         userInfo:userInfo]];
        }
        
        completeMultipartUploadRequest.object = uploadRequest.object;
        completeMultipartUploadRequest.uploadId = uploadRequest.uploadId;
        
        return [[CSSP initialize]completeMultipartUpload:completeMultipartUploadRequest];
    }] continueWithBlock:^id(BFTask *task) {
        
        //delete cached Object if state is not Paused
        if (uploadRequest.state != CSSPTransferManagerRequestStatePaused) {
            [self.cache removeObjectForKey:cacheKey];
        }
        
        if (uploadRequest.state == CSSPTransferManagerRequestStateCanceling) {
            [self abortMultipartUploadsForRequest:uploadRequest];
        }
        
        if (task.error) {
            return [BFTask taskWithError:task.error];
        }
        
        CSSPTransferManagerUploadOutput *uploadOutput = [CSSPTransferManagerUploadOutput new];
        if (task.result) {
            CSSPCompleteMultipartUploadOutput *completeMultipartUploadOutput = task.result;
            [uploadOutput cssp_copyPropertiesFromObject:completeMultipartUploadOutput];
        }
        
        return uploadOutput;
    }];
    
    return uploadTask;
}

- (void)abortMultipartUploadsForRequest:(CSSPTransferManagerUploadRequest *)uploadRequest{
    CSSPAbortMultipartUploadRequest *abortMultipartUploadRequest = [CSSPAbortMultipartUploadRequest new];
    abortMultipartUploadRequest.object = uploadRequest.object;
    abortMultipartUploadRequest.uploadId = uploadRequest.uploadId;
    
    [[[CSSP initialize] abortMultipartUpload:abortMultipartUploadRequest] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            CSSPLogDebug(@"Received response for abortMultipartUpload with Error:%@",task.error);
        } else {
            CSSPLogDebug(@"Received response for abortMultipartUpload.");
        }
        return nil;
    }];
}

- (BFTask *)download:(CSSPTransferManagerDownloadRequest *)downloadRequest {
    NSString *cacheKey = nil;
    if ([downloadRequest valueForKey:@"cacheIdentifier"]) {
        cacheKey = [downloadRequest valueForKey:@"cacheIdentifier"];
    } else {
        cacheKey = [[NSProcessInfo processInfo] globallyUniqueString];
        [downloadRequest setValue:cacheKey forKey:@"cacheIdentifier"];
    }
    
    return [self download:downloadRequest cacheKey:cacheKey];
}


- (BFTask *)download:(CSSPTransferManagerDownloadRequest *)downloadRequest
            cacheKey:(NSString *)cacheKey {
   
    if ([downloadRequest.object length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'key' name can not be empty", nil)};
        return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }
    
    
    //Check if the task has already completed
    if (downloadRequest.state == CSSPTransferManagerRequestStateCompleted) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to download a completed task", nil)]};
        return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorCompleted userInfo:userInfo]];
    } else if (downloadRequest.state == CSSPTransferManagerRequestStateCanceling){
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to download a cancelled task.", nil)]};
        return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorCancelled userInfo:userInfo]];
    }
    
    //if it is a new request.
    if (downloadRequest.state != CSSPTransferManagerRequestStatePaused) {
        
        //If downloadFileURL is nil, create a URL in temporary folder for user.
        if (downloadRequest.downloadingFileURL == nil) {
            NSString *adjustedKeyName = [[downloadRequest.object componentsSeparatedByString:@"/"] lastObject];
            NSString *generatedfileName = adjustedKeyName;
            
            
            //check if the file already exists, if yes, create another fileName;
            NSUInteger suffixCount = 2;
            while ([[NSFileManager defaultManager] fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:generatedfileName]]) {
                NSMutableArray *components = [[adjustedKeyName componentsSeparatedByString:@"."] mutableCopy];
                if ([components count] == 1) {
                    generatedfileName = [NSString stringWithFormat:@"%@ (%lu)",adjustedKeyName,(unsigned long)suffixCount];
                } else if ([components count] >= 2) {
                    NSString *modifiedFileName = [NSString stringWithFormat:@"%@ (%lu)",[components objectAtIndex:[components count]-2],(unsigned long)suffixCount];
                    [components replaceObjectAtIndex:[components count]-2 withObject:modifiedFileName];
                    generatedfileName = [components componentsJoinedByString:@"."];
                    
                } else {
                    CSSPLogError(@"[generatedPath componentsSeparatedByString] returns empty array or nil, generatedfileName:%@",generatedfileName);
                    NSString *errorString = [NSString stringWithFormat:@"[generatedPath componentsSeparatedByString] returns empty array or nil, generatedfileName:%@",generatedfileName];
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(errorString, nil)};
                    return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain code:CSSPTransferManagerErrorInternalInConsistency userInfo:userInfo]];
                }
                suffixCount++;
            }
            
            downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:generatedfileName]];
        } else {
            //if file already existed, remove it to avoid received data has been appended to exist file.
            [[NSFileManager defaultManager] removeItemAtURL:downloadRequest.downloadingFileURL error:nil];
        }
        
    } else {
        //if the is a paused task, set the range
        NSURL *tempFileURL = downloadRequest.downloadingFileURL;
        if (tempFileURL) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempFileURL.path] == NO) {
                CSSPLogError(@"tempfile is not exist, unable to resume");
            }
            NSError *error = nil;
            NSString *tempFilePath = tempFileURL.path;
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[tempFilePath stringByResolvingSymlinksInPath]
                                                                                        error:&error];
            if (error) {
                CSSPLogError(@"Unable to resume download task: Failed to retrival tempFileURL. [%@]",error);
            }
            unsigned long long fileSize = [attributes fileSize];
            downloadRequest.range = [NSString stringWithFormat:@"bytes=%llu-",fileSize];
            
        }
    }
    
    //change state to running
    [downloadRequest setValue:[NSNumber numberWithInteger:CSSPTransferManagerRequestStateRunning] forKey:@"state"];
    
    //set shouldWriteDirectly to YES
    [downloadRequest setValue:@YES forKey:@"shouldWriteDirectly"];
    
    
    BFTask *task = [BFTask taskWithResult:nil];
    task = [[task continueWithSuccessBlock:^id(BFTask *task) {
        [self.cache setObject:downloadRequest forKey:cacheKey];
        return nil;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        return [self getObject:downloadRequest cacheKey:cacheKey];
    }];
    
    return task;
}

- (BFTask *)getObject:(CSSPTransferManagerDownloadRequest *)downloadRequest
             cacheKey:(NSString *)cacheKey {
    CSSPGetObjectRequest *getObjectRequest = [CSSPGetObjectRequest new];
    [getObjectRequest cssp_copyPropertiesFromObject:downloadRequest];
    
    BFTask *downloadTask = [[[[CSSP initialize] getObject:getObjectRequest] continueWithBlock:^id(BFTask *task) {
        
        //delete cached Object if state is not Paused
        if (downloadRequest.state != CSSPTransferManagerRequestStatePaused) {
            [self.cache removeObjectForKey:cacheKey];
        }
        
        if (task.error) {
            
            return [BFTask taskWithError:task.error];
        }
        
        CSSPTransferManagerDownloadOutput *downloadOutput = [CSSPTransferManagerDownloadOutput new];
        if (task.result) {
            CSSPGetObjectOutput *getObjectOutput = task.result;
            
            if (downloadRequest.downloadingFileURL)
                getObjectOutput.body = downloadRequest.downloadingFileURL;
            
            [downloadOutput cssp_copyPropertiesFromObject:getObjectOutput];
        }
        [downloadRequest setValue:[NSNumber numberWithInteger:CSSPTransferManagerRequestStateCompleted]
                           forKey:@"state"];
        return downloadOutput;
        
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:NSURLErrorDomain]
                && task.error.code == NSURLErrorCancelled) {
                if (downloadRequest.state == CSSPTransferManagerRequestStatePaused) {
                    return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain
                                                                     code:CSSPTransferManagerErrorPaused
                                                                 userInfo:task.error.userInfo]];
                } else {
                    return [BFTask taskWithError:[NSError errorWithDomain:CSSPTransferManagerErrorDomain
                                                                     code:CSSPTransferManagerErrorCancelled
                                                                 userInfo:task.error.userInfo]];
                }
                
            } else {
                return [BFTask taskWithError:task.error];
            }
        } else {
            return [BFTask taskWithResult:task.result];
        }
    }];
    
    return downloadTask;
}


- (BFTask *)cancelAll {
    NSMutableArray *keys = [NSMutableArray new];
    [self.cache.diskCache enumerateObjectsWithBlock:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        [keys addObject:key];
    }];
    
    NSMutableArray *tasks = [NSMutableArray new];
    for (NSString *key in keys) {
        CSSPRequest *cachedObject = [self.cache objectForKey:key];
        if ([cachedObject isKindOfClass:[CSSPTransferManagerUploadRequest class]]
            || [cachedObject isKindOfClass:[CSSPTransferManagerDownloadRequest class]]) {
            [tasks addObject:[cachedObject cancel]];
        }
    }
    
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)pauseAll {
    NSMutableArray *keys = [NSMutableArray new];
    [self.cache.diskCache enumerateObjectsWithBlock:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        [keys addObject:key];
    }];
    
    NSMutableArray *tasks = [NSMutableArray new];
    for (NSString *key in keys) {
        CSSPRequest *cachedObject = [self.cache objectForKey:key];
        if ([cachedObject isKindOfClass:[CSSPTransferManagerUploadRequest class]]
            || [cachedObject isKindOfClass:[CSSPTransferManagerDownloadRequest class]]) {
            [tasks addObject:[cachedObject pause]];
        }
    }
    
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)resumeAll:(CSSPTransferManagerResumeAllBlock)block {
    NSMutableArray *keys = [NSMutableArray new];
    [self.cache.diskCache enumerateObjectsWithBlock:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        [keys addObject:key];
    }];
    
    NSMutableArray *tasks = [NSMutableArray new];
    NSMutableArray *results = [NSMutableArray new];
    for (NSString *key in keys) {
        id cachedObject = [self.cache objectForKey:key];
        if (block) {
            if ([cachedObject isKindOfClass:[CSSPRequest class]]) {
                block(cachedObject);
            }
        }
        
        if ([cachedObject isKindOfClass:[CSSPTransferManagerUploadRequest class]]) {
            [tasks addObject:[[self upload:cachedObject cacheKey:key] continueWithSuccessBlock:^id(BFTask *task) {
                [results addObject:task.result];
                return nil;
            }]];
        }
        if ([cachedObject isKindOfClass:[CSSPTransferManagerDownloadRequest class]]) {
            [tasks addObject:[[self download:cachedObject cacheKey:key] continueWithSuccessBlock:^id(BFTask *task){
                [results addObject:task.result];
                return nil;
            }]];
        }
        
        //remove Resumed Object
        [self.cache removeObjectForKey:key];
    }
    
    return [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            return [BFTask taskWithError:task.error];
        }
        
        return [BFTask taskWithResult:results];
    }];
}

- (BFTask *)clearCache {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource new];
    [self.cache removeAllObjects:^(TMCache *cache) {
        taskCompletionSource.result = nil;
    }];
    
    return taskCompletionSource.task;
}


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