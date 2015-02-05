//
//  CSSPiOSSDK.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/26.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSPRequestSerialization.h"
#import "CSSPModel.h"

@class BFTask;


@interface CSSPiOSSDK : NSObject

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
