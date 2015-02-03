//
//  CSSPNetworking.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/2.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSPModel.h"

FOUNDATION_EXPORT NSString *const CSSPNetworkingErrorDomain;
typedef NS_ENUM(NSInteger, CSSPNetworkingErrorType) {
    CSSPNetworkingErrorUnknown,
    CSSPNetworkingErrorCancelled
};

typedef NS_ENUM(NSInteger, CSSPNetworkingRetryType) {
    CSSPNetworkingRetryTypeUnknown,
    CSSPNetworkingRetryTypeShouldNotRetry,
    CSSPNetworkingRetryTypeShouldRetry,
    CSSPNetworkingRetryTypeShouldRefreshCredentialsAndRetry,
    CSSPNetworkingRetryTypeShouldCorrectClockSkewAndRetry
};

@class CSSPNetworkingConfiguration;
@class CSSPNetworkingRequest;
@class BFTask;

typedef void (^CSSPNetworkingUploadProgressBlock) (int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^CSSPNetworkingDownloadProgressBlock) (int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^CSSPNetworkingCompletionHandlerBlock)(id responseObject, NSError *error);

#pragma mark - CSSPHTTPMethod

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

#pragma mark - CSSPNetworking

@interface CSSPNetworking : NSObject

+ (instancetype)standardNetworking;
+ (instancetype)networking:(CSSPNetworkingConfiguration *)configuration;

- (BFTask *)sendRequest:(CSSPNetworkingRequest *)request;

- (BFTask *)sendDownloadRequest:(CSSPNetworkingRequest *)request;

- (BFTask *)sendUploadRequest:(CSSPNetworkingRequest *)request;

- (BFTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters;

- (BFTask *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters;

- (BFTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters;

- (BFTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters;

- (BFTask *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters;

- (BFTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters;

@end

#pragma mark - Protocols

@protocol CSSPURLRequestSerializer <NSObject>

@required
- (BFTask *)validateRequest:(NSURLRequest *)request;
- (BFTask *)serializeRequest:(NSMutableURLRequest *)request
                     headers:(NSDictionary *)headers
                  parameters:(NSDictionary *)parameters;

@end

@protocol CSSPNetworkingRequestInterceptor <NSObject>

@required
- (BFTask *)interceptRequest:(NSMutableURLRequest *)request;

@end

@protocol CSSPNetworkingHTTPResponseInterceptor <NSObject>

@required
- (BFTask *)interceptResponse:(NSHTTPURLResponse *)response
                         data:(id)data
              originalRequest:(NSURLRequest *)originalRequest
               currentRequest:(NSURLRequest *)currentRequest;

@end

@protocol CSSPHTTPURLResponseSerializer <NSObject>

@required

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
             fromRequest:(NSURLRequest *)request
                    data:(id)data
                   error:(NSError *__autoreleasing *)error;
- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                originalRequest:(NSURLRequest *)originalRequest
                 currentRequest:(NSURLRequest *)currentRequest
                           data:(id)data
                          error:(NSError *__autoreleasing *)error;

@end

@protocol CSSPURLRequestRetryHandler <NSObject>

@required

@property (nonatomic, assign) uint32_t maxRetryCount;

- (CSSPNetworkingRetryType)shouldRetry:(uint32_t)currentRetryCount
                             response:(NSHTTPURLResponse *)response
                                 data:(NSData *)data
                                error:(NSError *)error;

- (NSTimeInterval)timeIntervalForRetry:(uint32_t)currentRetryCount
                              response:(NSHTTPURLResponse *)response
                                  data:(NSData *)data
                                 error:(NSError *)error;

@end

#pragma mark - CSSPURLRequestSerializer

@interface CSSPURLRequestSerializer : NSObject <CSSPURLRequestSerializer>

@end

#pragma mark - CSSPNetworkingConfiguration

@interface CSSPNetworkingConfiguration : NSObject <NSCopying>

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, assign) CSSPHTTPMethod HTTPMethod;
@property (nonatomic, strong) NSDictionary *headers;

@property (nonatomic, strong) id<CSSPURLRequestSerializer> requestSerializer;
@property (nonatomic, strong) NSArray *requestInterceptors; // Array of CSSPNetworkingRequestInterceptor.
@property (nonatomic, strong) id<CSSPHTTPURLResponseSerializer> responseSerializer;
@property (nonatomic, strong) NSArray *responseInterceptors; // Array of CSSPNetworkingResponseInterceptor.
@property (nonatomic, strong) id<CSSPURLRequestRetryHandler> retryHandler;

+ (instancetype)defaultConfiguration;

@end

#pragma mark - CSSPNetworkingRequest

@interface CSSPNetworkingRequest : CSSPNetworkingConfiguration

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSURL *uploadingFileURL;
@property (nonatomic, strong) NSURL *downloadingFileURL;
@property (nonatomic, assign) BOOL shouldWriteDirectly;

@property (nonatomic, copy) CSSPNetworkingUploadProgressBlock uploadProgress;
@property (nonatomic, copy) CSSPNetworkingDownloadProgressBlock downloadProgress;

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;

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

@interface CSSPRequest : CSSPModel

@property (nonatomic, copy) CSSPNetworkingUploadProgressBlock uploadProgress;
@property (nonatomic, copy) CSSPNetworkingDownloadProgressBlock downloadProgress;
@property (nonatomic, assign, readonly, getter = isCancelled) BOOL cancelled;
@property (nonatomic, strong) NSURL *downloadingFileURL;

- (BFTask *)cancel;
- (BFTask *)pause;

@end

@interface CSSPNetworkingRequestInterceptor : NSObject <CSSPNetworkingRequestInterceptor>

@end
