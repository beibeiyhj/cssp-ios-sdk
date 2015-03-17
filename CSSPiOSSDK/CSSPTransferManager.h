//
//  CSSPTransferManager.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/3/17.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSP.h"

FOUNDATION_EXPORT NSString *const CSSPTransferManagerErrorDomain;
typedef NS_ENUM(NSInteger, CSSPTransferManagerErrorType) {
    CSSPTransferManagerErrorUnknown,
    CSSPTransferManagerErrorCancelled,
    CSSPTransferManagerErrorPaused,
    CSSPTransferManagerErrorCompleted,
    CSSPTransferManagerErrorInternalInConsistency,
    CSSPTransferManagerErrorMissingRequiredParameters,
    CSSPTransferManagerErrorInvalidParameters,
};

typedef NS_ENUM(NSInteger, CSSPTransferManagerRequestState) {
    CSSPTransferManagerRequestStateNotStarted,
    CSSPTransferManagerRequestStateRunning,
    CSSPTransferManagerRequestStatePaused,
    CSSPTransferManagerRequestStateCanceling,
    CSSPTransferManagerRequestStateCompleted,
};

typedef void (^CSSPTransferManagerResumeAllBlock) (CSSPRequest *request);

@class CSSPTransferManagerUploadRequest;
@class CSSPTransferManagerUploadOutput;
@class CSSPTransferManagerDownloadRequest;
@class CSSPTransferManagerDownloadOutput;

@interface CSSPTransferManager : NSObject

+ (CSSPTransferManager *)initialize;

- (instancetype)initWithConfiguration:(CSSPServiceConfiguration *)configuration;

/**
 *  Schedules a new transfer to upload data to Amazon S3.
 *
 *  @param uploadRequest The upload request.
 *
 *  @return BFTask.
 */
- (BFTask *)upload:(CSSPTransferManagerUploadRequest *)uploadRequest;

/**
 *  Schedules a new transfer to download data from Amazon S3 and save it to the specified file.
 *
 *  @param downloadRequest The download request.
 *
 *  @return BFTask.
 */
- (BFTask *)download:(CSSPTransferManagerDownloadRequest *)downloadRequest;

/**
 *  Cancels all of the upload and download requests.
 *
 *  @return BFTask.
 */
- (BFTask *)cancelAll;

/**
 *  Pauses all of the upload and download requests.
 *
 *  @return BFTask.
 */
- (BFTask *)pauseAll;

/**
 *  Resumes all of the upload and download requests.
 *
 *  @param block The block to optionally re-set the progress blocks to the requests.
 *
 *  @return BFTask.
 */
- (BFTask *)resumeAll:(CSSPTransferManagerResumeAllBlock)block;

/**
 *  Clears the local cache.
 *
 *  @return BFTask.
 */
- (BFTask *)clearCache;

@end

@interface CSSPTransferManagerUploadRequest : CSSPPutObjectRequest

@property (nonatomic, assign, readonly) CSSPTransferManagerRequestState state;
@property (nonatomic, strong) NSURL *body;

@end

@interface CSSPTransferManagerUploadOutput : CSSPPutObjectOutput

@end

@interface CSSPTransferManagerDownloadRequest : CSSPGetObjectRequest

@property (nonatomic, assign, readonly) CSSPTransferManagerRequestState state;

@end

@interface CSSPTransferManagerDownloadOutput : CSSPGetObjectOutput

@end
