//
//  CSSPNetworking.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/5.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "CSSPURLSessionManager.h"

FOUNDATION_EXPORT NSString *const CSSPNetworkingErrorDomain;

typedef NS_ENUM(NSInteger, CSSPNetworkingErrorType) {
    CSSPNetworkingErrorUnknown,
    CSSPNetworkingErrorCancelled
};

@class CSSPNetworkingConfiguration;
@class CSSPNetworkingRequest;
@class CSSPURLSessionManager;
@class BFTask;

typedef void (^CSSPNetworkingUploadProgressBlock) (int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^CSSPNetworkingDownloadProgressBlock) (int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^CSSPNetworkingCompletionHandlerBlock)(id responseObject, NSError *error);

typedef NS_ENUM(NSInteger, CSSPHTTPMethod) {
    CSSPHTTPMethodUnknown,
    CSSPHTTPMethodGET,
    CSSPHTTPMethodHEAD,
    CSSPHTTPMethodPOST,
    CSSPHTTPMethodPUT,
    CSSPHTTPMethodPATCH,
    CSSPHTTPMethodDELETE
};

@interface NSString (CSSPHTTPMethod)

+ (instancetype)cssp_stringWithHTTPMethod:(CSSPHTTPMethod)HTTPMethod;

@end

#pragma mark - CSSPURLRequestSerializer

@interface CSSPURLRequestSerializer : NSObject <AFURLRequestSerialization>

@end


#pragma mark - CSSPNetworkingConfiguration

@interface CSSPNetworkingConfiguration : NSObject <NSCopying>

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, assign) CSSPHTTPMethod HTTPMethod;
@property (nonatomic, strong) NSDictionary *headers;

@property (nonatomic, strong) id<AFURLRequestSerialization> requestSerializer;
@property (nonatomic, strong) NSArray *requestInterceptors;
@property (nonatomic, strong) id<AFURLResponseSerialization> responseSerializer;
@property (nonatomic, strong) NSArray *responseInterceptors;
//@property (nonatomic, strong) id<CSSPURLRequestRetryHandler> retryHandler;

+ (instancetype)defaultConfiguration;

@end


@interface CSSPNetworkingRequest : CSSPNetworkingConfiguration

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSURL *uploadingFileURL;
@property (nonatomic, strong) NSURL *downloadingFileURL;
@property (nonatomic, assign) BOOL shouldWriteDirectly;

@property (nonatomic, copy) CSSPNetworkingUploadProgressBlock uploadProgress;
@property (nonatomic, copy) CSSPNetworkingDownloadProgressBlock downloadProgress;

@property (readonly, nonatomic, strong) NSURLSessionTask *task;
@property (readonly, nonatomic, assign, getter = isCancelled) BOOL cancelled;

+ (instancetype)requestForDataTask:(CSSPHTTPMethod)HTTPMethod
                         URLString:(NSString *)URLString;
+ (instancetype)requestForDownloadTask:(CSSPHTTPMethod)HTTPMethod
                             URLString:(NSString *)URLString
                    downloadingFileURL:(NSURL *)downloadingFileURL;
+ (instancetype)requestForUploadTask:(CSSPHTTPMethod)HTTPMethod
                           URLString:(NSString *)URLString
                    uploadingFileURL:(NSURL *)uploadingFileURL;

- (void)assignProperties:(CSSPNetworkingConfiguration *)configuration;
- (void)cancel;
- (void)pause;

@end


@interface CSSPNetworking : NSObject

+(instancetype) networking:(CSSPNetworkingConfiguration *)configuration;

- (BFTask *)sendRequest:(CSSPNetworkingRequest *)request;

@end
