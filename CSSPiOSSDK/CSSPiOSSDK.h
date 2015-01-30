//
//  CSSPiOSSDK.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/26.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "CSSPRequestSerialization.h"

@interface CSSPHTTPRequestManager : AFHTTPRequestOperationManager<NSSecureCoding, NSCopying>

@property (readonly, nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) CSSPRequestSerialization<AFURLRequestSerialization> *requestSerializer;

-(id) initWithAccessKeyID:(NSString *) accessKey
            withSecretKey:(NSString *) secretKey;

-(AFHTTPRequestOperation *) enqueueRequestOpetation:(NSString *) method
                                           withPath:(NSString *) path
                                     withParameters:(NSDictionary *) parameters
                                            success:(void (^)(id responseObject)) success
                                            failure:(void (^) (NSError *error)) failure;


-(AFHTTPRequestOperation *) deleteObject:(NSString *) object
                                 success:(void (^)(id responseObject)) success
                                 failure:(void (^) (NSError *error)) failure;

-(AFHTTPRequestOperation *) getContainerAcl:(NSString *) containerName
                                    success:(void (^)(id responseObject)) success
                                    failure:(void (^) (NSError *error)) failure;

-(AFHTTPRequestOperation *) getObject:(NSString *) object
                             progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
                              success:(void (^)(id responseObject, NSData *responseData))success
                              failure:(void (^)(NSError *error))failure;

-(AFHTTPRequestOperation *) getObject:(NSString *) object
                         outputStream:(NSOutputStream *)outputStream
                             progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
                              success:(void (^)(id responseObject, NSData *responseData))success
                              failure:(void (^)(NSError *error))failure;

-(AFHTTPRequestOperation *) headContainer:(NSString *) containerName
                                  success:(void (^)(id responseObject)) success
                                  failure:(void (^) (NSError *error)) failure;

-(AFHTTPRequestOperation *) headObject:(NSString *) object
                               success:(void (^)(id responseObject)) success
                               failure:(void (^) (NSError *error)) failure;



@end

@interface CSSPHTTPSessionManager : AFHTTPSessionManager<NSSecureCoding, NSCopying>

@end