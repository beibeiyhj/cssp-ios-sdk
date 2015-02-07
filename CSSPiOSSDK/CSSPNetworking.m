//
//  CSSPNetworking.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/5.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPNetworking.h"
#import "Bolts.h"
#import "CSSPURLSessionManager.h"

NSString *const CSSPNetworkingErrorDomain = @"com.cssp.csspNetworkingErrorDomain";

@implementation CSSPNetworkingConfiguration

+(instancetype)defaultConfiguration{
    CSSPNetworkingConfiguration *configuration =[[CSSPNetworkingConfiguration alloc] init];
    configuration.requestSerializer = [[CSSPURLRequestSerializer alloc] init];
    
    return configuration;
}

- (NSURL *)URL {
    if (!self.URLString) {
        return self.baseURL;
    }
    
    return [NSURL URLWithString:self.URLString
                  relativeToURL:self.baseURL];
}

- (id)copyWithZone:(NSZone *)zone {
    CSSPNetworkingConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.baseURL = [self.baseURL copy];
    configuration.URLString = [self.URLString copy];
    configuration.HTTPMethod = self.HTTPMethod;
    configuration.headers = [self.headers copy];
    configuration.requestSerializer = self.requestSerializer;
    configuration.requestInterceptors = [self.requestInterceptors copy];
    configuration.responseSerializer = self.responseSerializer;
    configuration.responseInterceptors = [self.responseInterceptors copy];
//    configuration.retryHandler = self.retryHandler;
    
    return configuration;
}

@end

#pragma mark - CSSPNetworkingRequest

@interface CSSPNetworkingRequest()

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;

@end

@implementation CSSPNetworkingRequest

+ (instancetype)requestForDataTask:(CSSPHTTPMethod)HTTPMethod
                         URLString:(NSString *)URLString {
    CSSPNetworkingRequest *request = [CSSPNetworkingRequest new];
    request.HTTPMethod = HTTPMethod;
    request.URLString = URLString;
    
    return request;
}

+ (instancetype)requestForDownloadTask:(CSSPHTTPMethod)HTTPMethod
                             URLString:(NSString *)URLString
                    downloadingFileURL:(NSURL *)downloadingFileURL {
    CSSPNetworkingRequest *request = [CSSPNetworkingRequest new];
    request.HTTPMethod = HTTPMethod;
    request.URLString = URLString;
    request.downloadingFileURL = downloadingFileURL;
    
    return request;
}

+ (instancetype)requestForUploadTask:(CSSPHTTPMethod)HTTPMethod
                           URLString:(NSString *)URLString
                    uploadingFileURL:(NSURL *)uploadingFileURL {
    CSSPNetworkingRequest *request = [CSSPNetworkingRequest new];
    request.HTTPMethod = HTTPMethod;
    request.URLString = URLString;
    request.uploadingFileURL = uploadingFileURL;
    
    return request;
}

- (void)assignProperties:(CSSPNetworkingConfiguration *)configuration {
    if (!self.baseURL) {
        self.baseURL = configuration.baseURL;
    }
    
    if (!self.URLString) {
        self.URLString = configuration.URLString;
    }
    
    if (!self.HTTPMethod) {
        self.HTTPMethod = configuration.HTTPMethod;
    }
    
    if (configuration.headers) {
        NSMutableDictionary *mutableCopy = [configuration.headers mutableCopy];
        [self.headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [mutableCopy setObject:obj forKey:key];
        }];
        self.headers = mutableCopy;
    }
    
    if (!self.requestSerializer) {
        self.requestSerializer = configuration.requestSerializer;
    }
    
    if (configuration.requestInterceptors) {
        self.requestInterceptors = configuration.requestInterceptors;
    }
    
    if (!self.responseSerializer) {
        self.responseSerializer = configuration.responseSerializer;
    }
    
    if (configuration.responseInterceptors) {
        self.responseInterceptors = configuration.responseInterceptors;
    }
    
//    if (!self.retryHandler) {
//        self.retryHandler = configuration.retryHandler;
//    }
}

- (void)setTask:(NSURLSessionTask *)task {
    @synchronized(self) {
        if (!_cancelled) {
            _task = task;
        } else {
            _task = nil;
        }
    }
}

- (BOOL)isCancelled {
    @synchronized(self) {
        return _cancelled;
    }
}

- (void)cancel {
    @synchronized(self) {
        if (!_cancelled) {
            _cancelled = YES;
            [self.task cancel];
        }
    }
}

- (void)pause {
    @synchronized(self) {
        [self.task cancel];
    }
}

@end


#pragma mark - CSSPHTTPMethod

@implementation NSString (CSSPHTTPMethod)

+ (instancetype)cssp_stringWithHTTPMethod:(CSSPHTTPMethod)HTTPMethod {
    NSString *string = nil;
    switch (HTTPMethod) {
        case CSSPHTTPMethodGET:
            string = @"GET";
            break;
        case CSSPHTTPMethodHEAD:
            string = @"HEAD";
            break;
        case CSSPHTTPMethodPOST:
            string = @"POST";
            break;
        case CSSPHTTPMethodPUT:
            string = @"PUT";
            break;
        case CSSPHTTPMethodPATCH:
            string = @"PATCH";
            break;
        case CSSPHTTPMethodDELETE:
            string = @"DELETE";
            break;
            
        default:
            break;
    }
    
    return string;
}

@end

#pragma mark - AWSNetworking

@interface CSSPNetworking()

@property (nonatomic, strong) CSSPURLSessionManager *networkManager;

@end

@implementation CSSPNetworking

- (instancetype)init {
    if (self = [super init]) {
        CSSPURLSessionManager *sessionManager = [CSSPURLSessionManager new];
        self.networkManager = sessionManager;
    }
    
    return self;
}

+ (instancetype)networking:(CSSPNetworkingConfiguration *)configuration {
    CSSPNetworking *networking = [CSSPNetworking new];
    networking.networkManager.configuration = configuration;
    
    return networking;
}

- (BFTask *)sendRequest:(CSSPNetworkingRequest *)request{
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    
    return taskCompletionSource.task;
}

@end
