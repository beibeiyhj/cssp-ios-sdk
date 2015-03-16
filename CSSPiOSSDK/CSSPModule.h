//
//  CSSPModel.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/4.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSPNetworking.h"


typedef NS_ENUM(NSInteger, CSSPEncodingType) {
    CSSPEncodingTypeUnknown,
    CSSPEncodingTypeURL,
};


typedef NS_ENUM(NSInteger, CSSPProtocol) {
    CSSPProtocolUnknown,
    CSSPProtocolHTTP,
    CSSPProtocolHTTPS,
};


@class CSSPAbortMultipartUploadRequest;
@class CSSPCompleteMultipartUploadOutput;
@class CSSPCompleteMultipartUploadRequest;
@class CSSPCompletedPart;
@class CSSPCreateMultipartUploadOutput;
@class CSSPCreateMultipartUploadRequest;
@class CSSPDeleteObjectOutput;
@class CSSPDeleteObjectRequest;
@class CSSPGetContainerAclOutput;
@class CSSPGetContainerAclRequest;
@class CSSPGetObjectOutput;
@class CSSPGetObjectRequest;
@class CSSPHeadContainerRequest;
@class CSSPHeadContainerOutput;
@class CSSPHeadObjectOutput;
@class CSSPHeadObjectRequest;
@class CSSPListMultipartUploadsOutput;
@class CSSPListMultipartUploadsRequest;
@class CSSPListObjectsOutput;
@class CSSPListObjectsRequest;
@class CSSPListPartsOutput;
@class CSSPListPartsRequest;
@class CSSPObject;
@class CSSPPart;
@class CSSPPutContainerAclRequest;
@class CSSPPutObjectOutput;
@class CSSPPutObjectRequest;
@class CSSPReplicateObjectOutput;
@class CSSPReplicateObjectRequest;
@class CSSPReplicateObjectResult;
@class CSSPUploadPartOutput;
@class CSSPUploadPartRequest;


@interface CSSPAbortMultipartUploadRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;
@property (nonatomic, strong) NSString *uploadId;

@end


@interface CSSPCompleteMultipartUploadOutput : CSSPModel

/**
 * Entity tag of the object.
 */
@property (nonatomic, strong) NSString *ETag;

@property (nonatomic, strong) NSString *object;
@end


@interface CSSPCompletedPart : CSSPModel


/**
 * Entity tag returned when the part was uploaded.
 */
@property (nonatomic, strong) NSString *ETag;

/**
 * Part number that identifies the part.
 */
@property (nonatomic, strong) NSNumber *partNumber;

@end

@interface CSSPCompleteMultipartUploadRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;
@property (nonatomic, strong) NSString *uploadId;
@property (nonatomic, strong) NSString *manifest;

@end


@interface CSSPCreateMultipartUploadOutput : CSSPModel

/**
 * Object key for which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString *object;


/**
 * ID for the initiated multipart upload.
 */
@property (nonatomic, strong) NSString *uploadId;

@end

@interface CSSPCreateMultipartUploadRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@end


@interface CSSPDeleteObjectOutput : CSSPModel

@end


@interface CSSPDeleteObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@end


@interface CSSPGetContainerAclOutput : CSSPModel


/**
 * A list of grants.
 */
@property (nonatomic, strong) NSArray *grants;

@end

@interface CSSPGetContainerAclRequest : CSSPRequest

@end


@interface CSSPGetObjectOutput : CSSPModel

@property (nonatomic, strong) NSString *acceptRanges;

/**
 * Object data.
 */
@property (nonatomic, strong) id body;

/**
 * Size of the body in bytes.
 */
@property (nonatomic, strong) NSNumber *contentLength;

/**
 * A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString *contentType;


/**
 * An ETag is an opaque identifier assigned by a web server to a specific version of a resource found at a URL
 */
@property (nonatomic, strong) NSString *ETag;

/**
 * The date and time at which the object is no longer cacheable.
 */
@property (nonatomic, strong) NSDate *expires;

/**
 * Last modified date of the object
 */
@property (nonatomic, strong) NSDate *lastModified;

/**
 * A map of metadata to store with the object in S3.
 */
@property (nonatomic, strong) NSDictionary *metadata;


@end


@interface CSSPGetObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@end

@interface CSSPHeadContainerRequest : CSSPRequest


@end

@interface CSSPHeadContainerOutput : CSSPModel

@property (nonatomic, strong) NSNumber *objectCount;
@property (nonatomic, strong) NSNumber *bytesUsed;
@property (nonatomic, strong) NSString *grantRead;
@property (nonatomic, strong) NSDictionary *metadata;

@end

@interface CSSPHeadObjectOutput : CSSPModel

@property (nonatomic, strong) NSString *acceptRanges;

/**
 * Specifies caching behavior along the request/reply chain.
 */
@property (nonatomic, strong) NSString *cacheControl;

/**
 * Specifies presentational information for the object.
 */
@property (nonatomic, strong) NSString *contentDisposition;

/**
 * Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field.
 */
@property (nonatomic, strong) NSString *contentEncoding;

/**
 * Size of the body in bytes.
 */
@property (nonatomic, strong) NSNumber *contentLength;

/**
 * A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString *contentType;


/**
 * An ETag is an opaque identifier assigned by a web server to a specific version of a resource found at a URL
 */
@property (nonatomic, strong) NSString *ETag;


/**
 * The date and time at which the object is no longer cacheable.
 */
@property (nonatomic, strong) NSDate *expires;

/**
 * Last modified date of the object
 */
@property (nonatomic, strong) NSDate *lastModified;

/**
 * A map of metadata to store with the object in S3.
 */
@property (nonatomic, strong) NSDictionary *metadata;

@end

@interface CSSPHeadObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@end




@interface CSSPListMultipartUploadsOutput : CSSPModel

@property (nonatomic, strong) NSArray *uploads;

@end

@interface CSSPListMultipartUploadsRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

/**
 * Sets the maximum number of multipart uploads, from 1 to 1,000, to return in the response body. 1,000 is the maximum number of uploads that can be returned in a response.
 */
@property (nonatomic, strong) NSNumber *maxUploads;

/**
 * Lists in-progress uploads only for those keys that begin with the specified prefix.
 */
@property (nonatomic, strong) NSString *prefix;

@property (nonatomic, strong) NSString *uploadId;

@end


@interface CSSPObject : CSSPModel

@property (nonatomic, strong) NSString *etag;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSString *contentType;

@end

@interface CSSPSubdir : CSSPModel

@property (nonatomic, strong) NSString *name;

@end

@interface CSSPListObjectsOutput : CSSPModel


@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSArray *subdirs;

@end


@interface CSSPListObjectsRequest : CSSPRequest
/**
 * A delimiter is a character you use to group keys.
 */
@property (nonatomic, strong) NSString *delimiter;
/**
 * Specifies the key to start with when listing objects in a container.
 */
@property (nonatomic, strong) NSString *marker;

/**
 * Sets the maximum number of objects returned in the response. The response might contain fewer objects but will never contain more.
 */
@property (nonatomic, strong) NSNumber *limit;

/**
 * Limits the response to objects that begin with the specified prefix.
 */
@property (nonatomic, strong) NSString *prefix;

@end



@interface CSSPListPartsOutput : CSSPModel

@property (nonatomic, strong) NSArray *contents;

@end


@interface CSSPListPartsRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;
@property (nonatomic, strong) NSString *uploadId;

@property (nonatomic, strong) NSString *prefix;

@end

@interface CSSPPart : CSSPModel


/**
 * Entity tag returned when the part was uploaded.
 */
@property (nonatomic, strong) NSString *ETag;

/**
 * Date and time at which the part was uploaded.
 */
@property (nonatomic, strong) NSDate *lastModified;

/**
 * Part number identifying the part.
 */
@property (nonatomic, strong) NSNumber *partNumber;

/**
 * Size of the uploaded part data.
 */
@property (nonatomic, strong) NSNumber *size;

@end


@interface CSSPPutContainerAclRequest : CSSPRequest


@end

@interface CSSPPutObjectOutput : CSSPModel


/**
 * Entity tag for the uploaded object.
 */
@property (nonatomic, strong) NSString *ETag;

@end

@interface CSSPPutObjectRequest : CSSPRequest

/**
 * Object data.
 */
@property (nonatomic, strong) id body;

/**
 * Size of the body in bytes. This parameter is useful when the size of the body cannot be determined automatically.
 */
@property (nonatomic, strong) NSNumber *contentLength;
@property (nonatomic, strong) NSString *contentMD5;

/**
 * A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString *contentType;


@property (nonatomic, strong) NSString *object;

/**
 * A map of metadata to store with the object.
 */
@property (nonatomic, strong) NSDictionary *metadata;

@end

@interface CSSPReplicateObjectResult : CSSPModel

@property (nonatomic, strong) NSString *ETag;
@property (nonatomic, strong) NSDate *lastModified;

@end

@interface CSSPReplicateObjectOutput : CSSPModel


/**
 * If the object expiration is configured, the response includes this header.
 */
@property (nonatomic, strong) NSDate *expiration;
@property (nonatomic, strong) CSSPReplicateObjectResult *replicateObjectResult;

@end

@interface CSSPReplicateObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;

/**
 * Specifies caching behavior along the request/reply chain.
 */
@property (nonatomic, strong) NSString *cacheControl;

/**
 * Specifies presentational information for the object.
 */
@property (nonatomic, strong) NSString *contentDisposition;

/**
 * Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field.
 */
@property (nonatomic, strong) NSString *contentEncoding;


/**
 * A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString *contentType;

/**
 * The date and time at which the object is no longer cacheable.
 */
@property (nonatomic, strong) NSDate *expires;

@property (nonatomic, strong) NSString *object;

/**
 * A map of metadata to store with the object.
 */
@property (nonatomic, strong) NSDictionary *metadata;

@property (nonatomic, strong) NSString *replicateSource;

@end


@interface CSSPUploadPartOutput : CSSPModel


/**
 * Entity tag for the uploaded object.
 */
@property (nonatomic, strong) NSString *ETag;

@end


@interface CSSPUploadPartRequest : CSSPRequest

@property (nonatomic, strong) id body;

/**
 * Size of the body in bytes. This parameter is useful when the size of the body cannot be determined automatically.
 */
@property (nonatomic, strong) NSNumber *contentLength;
@property (nonatomic, strong) NSString *contentMD5;
@property (nonatomic, strong) NSString *object;

/**
 * Part number of part being uploaded.
 */
@property (nonatomic, strong) NSNumber *partNumber;

/**
 * Upload ID identifying the multipart upload whose part is being uploaded.
 */
@property (nonatomic, strong) NSString *uploadId;

@end


