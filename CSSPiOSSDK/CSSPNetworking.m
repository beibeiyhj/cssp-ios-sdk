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
#import "CSSPCategory.h"

NSString *const CSSPNetworkingErrorDomain = @"com.cssp.csspNetworkingErrorDomain";


#pragma mark - CSSPURLRequestSerializer

@implementation CSSPURLRequestSerializer

- (BFTask *)validateRequest:(NSURLRequest *)request {
    return [BFTask taskWithResult:nil];
}

- (BFTask *)serializeRequest:(NSMutableURLRequest *)request
                     headers:(NSDictionary *)header
                  parameters:(NSDictionary *)parameters {
    if ([request.HTTPMethod isEqualToString:@"GET"]) {
        NSMutableString *URLparameters = [NSMutableString new];
        for (id o in parameters) {
            if ([URLparameters length] > 0) {
                [URLparameters appendString:@"&"];
            }
            
            [URLparameters appendFormat:@"%@=%@", o, [parameters objectForKey:o]];
        }
        
        NSString *escapedURLParameters = [[URLparameters stringByRemovingPercentEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",
                                            [request.URL absoluteString],
                                            request.URL.query ? @"&" : @"?",
                                            escapedURLParameters]];
    }
    return [BFTask taskWithResult:nil];
}

@end

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

@interface CSSPRequest()

@property (nonatomic, strong) CSSPNetworkingRequest *internalRequest;
@property (nonatomic, assign) NSNumber *shouldWriteDirectly;

@end

@implementation CSSPRequest

- (instancetype)init {
    if (self = [super init]) {
        _internalRequest = [CSSPNetworkingRequest new];
    }
    
    return self;
}

- (void)setUploadProgress:(CSSPNetworkingUploadProgressBlock)uploadProgress {
    self.internalRequest.uploadProgress = uploadProgress;
}

- (void)setDownloadProgress:(CSSPNetworkingDownloadProgressBlock)downloadProgress {
    self.internalRequest.downloadProgress = downloadProgress;
}

- (BOOL)isCancelled {
    return [self.internalRequest isCancelled];
}

- (BFTask *)cancel {
    [self.internalRequest cancel];
    return [BFTask taskWithResult:nil];
}

- (BFTask *)pause {
    [self.internalRequest pause];
    return [BFTask taskWithResult:nil];
}

- (NSDictionary *)dictionaryValue {
    NSDictionary *dictionaryValue = [super dictionaryValue];
    NSMutableDictionary *mutableDictionaryValue = [dictionaryValue mutableCopy];
    
    [dictionaryValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"internalRequest"]) {
            [mutableDictionaryValue removeObjectForKey:key];
        }
    }];
    
    return mutableDictionaryValue;
}

@end


@interface CSSPNetworkingRequestInterceptor()

@end

@implementation CSSPNetworkingRequestInterceptor

- (NSString *)userAgent {
    static NSString *_userAgent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *systemName = [[[UIDevice currentDevice] systemName] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
        _userAgent = [NSString stringWithFormat:@"cssp-sdk-iOS/%@/%@ %@", systemName, systemVersion, localeIdentifier];
    });
    
    return _userAgent;
}

- (BFTask *)interceptRequest:(NSMutableURLRequest *)request {
    
    NSString *userAgent = [self userAgent];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    return [BFTask taskWithResult:nil];
}

@end
