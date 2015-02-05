//
//  CSSPModel.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/4.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CSSPContainerCannedACL) {
    CSSPContainerCannedACLUnknown,
    CSSPContainerCannedACLPrivate,
    CSSPContainerCannedACLPublicRead,
    CSSPContainerCannedACLPublicReadWrite,
    CSSPContainerCannedACLAuthenticatedRead,
};

typedef NS_ENUM(NSInteger, CSSPMetadataDirective) {
    CSSPS3MetadataDirectiveUnknown,
    CSSPS3MetadataDirectiveCopy,
    CSSPS3MetadataDirectiveReplace,
};

@interface CSSPOwner

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *ID;

@end

@interface CSSPAccessControlPolicy


/**
 * A list of grants.
 */
@property (nonatomic, strong) NSArray *grants;
@property (nonatomic, strong) CSSPOwner *owner;

@end

@interface CSSPRequest : NSObject

@end


@interface CSSPAbortMultipartUploadRequest : CSSPRequest

@property (nonatomic, strong) NSString *bucket;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *uploadId;

@end


@interface CSSPCompletedMultipartUpload : NSObject

@property (nonatomic, strong) NSArray *parts;

@end

@interface CSSPCompleteMultipartUploadRequest : CSSPRequest

@property (nonatomic, strong) NSString *bucket;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) CSSPCompletedMultipartUpload *multipartUpload;
@property (nonatomic, strong) NSString *uploadId;

@end


@interface CSSPDeleteObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@end

@interface CSSPGetContainerAclRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;

@end

@interface CSSPGetObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@property (nonatomic, strong) NSOutputStream * outputStream;

@end

@interface CSSPHeadContainerRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;

@end

@interface CSSPHeaderObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@end


@interface CSSPListObjectsRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;

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

@interface CSSPListPartsRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;
@property (nonatomic, strong) NSString *object;

/**
 * Sets the maximum number of parts to return.
 */
@property (nonatomic, strong) NSNumber *maxParts;

/**
 * Specifies the part after which listing should begin. Only parts with higher part numbers will be listed.
 */
@property (nonatomic, strong) NSNumber *partNumberMarker;

/**
 * Upload ID identifying the multipart upload whose parts are being listed.
 */
@property (nonatomic, strong) NSString *uploadId;

@end

@interface CSSPPutContainerAclRequest : CSSPRequest


/**
 * The canned ACL to apply to the container.
 */
@property (nonatomic, assign) CSSPContainerCannedACL ACL;
@property (nonatomic, strong) CSSPAccessControlPolicy *accessControlPolicy;
@property (nonatomic, strong) NSString *container;
@property (nonatomic, strong) NSString *contentMD5;

/**
 * Allows grantee the read, write, read ACP, and write ACP permissions on the container.
 */
@property (nonatomic, strong) NSString *grantFullControl;

/**
 * Allows grantee to list the objects in the container.
 */
@property (nonatomic, strong) NSString *grantRead;

/**
 * Allows grantee to read the container ACL.
 */
@property (nonatomic, strong) NSString *grantReadACP;

/**
 * Allows grantee to create, overwrite, and delete any object in the container.
 */
@property (nonatomic, strong) NSString *grantWrite;

/**
 * Allows grantee to write the ACL for the applicable container.
 */
@property (nonatomic, strong) NSString *grantWriteACP;

@end

@interface CSSPPutObjectRequest : CSSPRequest

/**
 * Object data.
 */
@property (nonatomic, strong) id body;
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
 * The language the content is in.
 */
@property (nonatomic, strong) NSString *contentLanguage;

/**
 * Size of the body in bytes. This parameter is useful when the size of the body cannot be determined automatically.
 */
@property (nonatomic, strong) NSNumber *contentLength;
@property (nonatomic, strong) NSString *contentMD5;

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
 * The language the content is in.
 */
@property (nonatomic, strong) NSString *contentLanguage;

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

/**
 * Specifies whether the metadata is copied from the source object or replaced with metadata provided in the request.
 */
@property (nonatomic, assign) CSSPMetadataDirective metadataDirective;
@property (nonatomic, strong) NSString *replicateSource;
@property (nonatomic, strong) NSString *replicateSourceIfMatch;
@property (nonatomic, strong) NSDate *replicateSourceIfModifiedSince;
@property (nonatomic, strong) NSString *replicateSourceIfNoneMatch;
@property (nonatomic, strong) NSDate *replicateSourceIfUnmodifiedSince;

@end

@interface CSSPUploadPartRequest : CSSPRequest

@property (nonatomic, strong) id body;
@property (nonatomic, strong) NSString *container;

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


