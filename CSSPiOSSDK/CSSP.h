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

@interface CSSPServiceConfiguration : CSSPNetworkingConfiguration

@property (nonatomic, strong, readonly) id<CSSPCredentialsProvider> credentialsProvider;
@property (nonatomic, assign) int32_t maxRetryCount;

+ (instancetype)configurationWithCredentialsProvider:(id<CSSPCredentialsProvider>)credentialsProvider;

@end

@class BFTask;

@interface CSSP: NSObject

@property (nonatomic, strong, readonly) CSSPServiceConfiguration *configuration;

+ (instancetype)defaultCSSP;

- (instancetype)initWithConfiguration:(CSSPServiceConfiguration *)configuration;

- (BFTask *)abortMultipartUpload:(CSSPAbortMultipartUploadRequest *)request;

- (BFTask *)completeMultipartUpload:(CSSPCompleteMultipartUploadRequest *)request;

-(BFTask *) deleteObject:(CSSPDeleteObjectRequest *)request;

-(BFTask *) getContainerAcl:(CSSPGetContainerAclRequest*)request;

-(BFTask *) getObject:(CSSPGetObjectRequest *)request;

-(BFTask *) headContainer:(CSSPHeadContainerRequest *)request;

-(BFTask *) headObject:(CSSPHeaderObjectRequest *)request;

-(BFTask *) listObjects:(CSSPListObjectsRequest *)request;

-(BFTask *) listParts:(CSSPListPartsRequest *) request;

-(BFTask *) putContainerAcl:(CSSPPutContainerAclRequest *)request;

-(BFTask *) putObject:(CSSPPutObjectRequest *)request;

-(BFTask *) replicateObject:(CSSPReplicateObjectRequest *) request;

-(BFTask *) uploadPart:(CSSPUploadPartRequest *) request;

@end
