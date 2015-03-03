//
//  CSSPiOSSDK.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/26.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bolts.h"
#import "CSSPNetworking.h"
#import "CSSPCategory.h"
#import "CSSPCredentialsProvider.h"
#import "CSSPLogging.h"
#import "CSSPModule.h"

#pragma mark - CSSPEndpoint

@interface CSSPEndpoint : NSObject

@property (nonatomic, readonly) NSString *containerName;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSString *hostName;

+ (instancetype)endpointWithURL:(NSString *)urlString;

@end


@interface CSSPServiceConfiguration : CSSPNetworkingConfiguration

@property (nonatomic, strong, readonly) id<CSSPCredentialsProvider> credentialsProvider;
@property (nonatomic, strong, readonly) CSSPEndpoint *endpoint;

+ (instancetype)configurationWithCredentialsProvider:(id<CSSPCredentialsProvider>)credentialsProvider
                                        withEndpoint:(CSSPEndpoint *)endpoint;

@end

@class BFTask;

@interface CSSP: NSObject

@property (nonatomic, strong, readonly) CSSPServiceConfiguration *configuration;

- (instancetype)initWithConfiguration:(CSSPServiceConfiguration *)configuration;

- (BFTask *)abortMultipartUpload:(CSSPAbortMultipartUploadRequest *)request;

- (BFTask *)completeMultipartUpload:(CSSPCompleteMultipartUploadRequest *)request;

- (BFTask *)createMultipartUpload:(CSSPCreateMultipartUploadRequest *)request;

- (BFTask *) deleteObject:(CSSPDeleteObjectRequest *)request;

- (BFTask *) getObject:(CSSPGetObjectRequest *)request;

- (BFTask *) headContainer:(CSSPHeadContainerRequest *)request;

- (BFTask *) headObject:(CSSPHeadObjectRequest *)request;

- (BFTask *) listObjects:(CSSPListObjectsRequest *)request;

- (BFTask *)listMultipartUploads:(CSSPListMultipartUploadsRequest *)request;

- (BFTask *) putObject:(CSSPPutObjectRequest *)request;

- (BFTask *) uploadPart:(CSSPUploadPartRequest *) request;

@end
