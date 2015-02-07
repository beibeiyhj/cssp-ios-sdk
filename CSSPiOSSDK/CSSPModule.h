//
//  CSSPModel.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/4.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSPNetworking.h"

typedef NS_ENUM(NSInteger, CSSPErrorType) {
    CSSPErrorUnknown,
    CSSPErrorAccessDenied,
    CSSPErrorExpiredToken,
    CSSPErrorInvalidAccessKeyId,
    CSSPErrorInvalidToken,
    CSSPErrorSignatureDoesNotMatch,
    CSSPErrorTokenRefreshRequired,
    CSSPErrorBucketAlreadyExists,
    CSSPErrorNoSuchBucket,
    CSSPErrorNoSuchKey,
    CSSPErrorNoSuchUpload,
    CSSPErrorObjectAlreadyInActiveTier,
    CSSPErrorObjectNotInActiveTier,
};

typedef NS_ENUM(NSInteger, CSSPBucketCannedACL) {
    CSSPBucketCannedACLUnknown,
    CSSPBucketCannedACLPrivate,
    CSSPBucketCannedACLPublicRead,
    CSSPBucketCannedACLPublicReadWrite,
    CSSPBucketCannedACLAuthenticatedRead,
};

typedef NS_ENUM(NSInteger, CSSPBucketLocationConstraint) {
    CSSPBucketLocationConstraintUnknown,
    CSSPBucketLocationConstraintEU,
    CSSPBucketLocationConstraintEUWest1,
    CSSPBucketLocationConstraintUSWest1,
    CSSPBucketLocationConstraintUSWest2,
    CSSPBucketLocationConstraintAPSoutheast1,
    CSSPBucketLocationConstraintAPSoutheast2,
    CSSPBucketLocationConstraintAPNortheast1,
    CSSPBucketLocationConstraintSAEast1,
    CSSPBucketLocationConstraintBlank,
    CSSPBucketLocationConstraintCNNorth1,
    CSSPBucketLocationConstraintEUCentral1,
};

typedef NS_ENUM(NSInteger, CSSPBucketLogsPermission) {
    CSSPBucketLogsPermissionUnknown,
    CSSPBucketLogsPermissionFullControl,
    CSSPBucketLogsPermissionRead,
    CSSPBucketLogsPermissionWrite,
};

typedef NS_ENUM(NSInteger, CSSPBucketVersioningStatus) {
    CSSPBucketVersioningStatusUnknown,
    CSSPBucketVersioningStatusEnabled,
    CSSPBucketVersioningStatusSuspended,
};

typedef NS_ENUM(NSInteger, CSSPEncodingType) {
    CSSPEncodingTypeUnknown,
    CSSPEncodingTypeURL,
};

typedef NS_ENUM(NSInteger, CSSPEvent) {
    CSSPEventUnknown,
    CSSPEventS3ReducedRedundancyLostObject,
    CSSPEventS3ObjectCreatedPut,
    CSSPEventS3ObjectCreatedPost,
    CSSPEventS3ObjectCreatedCopy,
    CSSPEventS3ObjectCreatedCompleteMultipartUpload,
};

typedef NS_ENUM(NSInteger, CSSPExpirationStatus) {
    CSSPExpirationStatusUnknown,
    CSSPExpirationStatusEnabled,
    CSSPExpirationStatusDisabled,
};

typedef NS_ENUM(NSInteger, CSSPMFADelete) {
    CSSPMFADeleteUnknown,
    CSSPMFADeleteEnabled,
    CSSPMFADeleteDisabled,
};

typedef NS_ENUM(NSInteger, CSSPMFADeleteStatus) {
    CSSPMFADeleteStatusUnknown,
    CSSPMFADeleteStatusEnabled,
    CSSPMFADeleteStatusDisabled,
};

typedef NS_ENUM(NSInteger, CSSPMetadataDirective) {
    CSSPMetadataDirectiveUnknown,
    CSSPMetadataDirectiveCopy,
    CSSPMetadataDirectiveReplace,
};

typedef NS_ENUM(NSInteger, CSSPObjectCannedACL) {
    CSSPObjectCannedACLUnknown,
    CSSPObjectCannedACLPrivate,
    CSSPObjectCannedACLPublicRead,
    CSSPObjectCannedACLPublicReadWrite,
    CSSPObjectCannedACLAuthenticatedRead,
    CSSPObjectCannedACLBucketOwnerRead,
    CSSPObjectCannedACLBucketOwnerFullControl,
};

typedef NS_ENUM(NSInteger, CSSPObjectStorageClass) {
    CSSPObjectStorageClassUnknown,
    CSSPObjectStorageClassStandard,
    CSSPObjectStorageClassReducedRedundancy,
    CSSPObjectStorageClassGlacier,
};

typedef NS_ENUM(NSInteger, CSSPObjectVersionStorageClass) {
    CSSPObjectVersionStorageClassUnknown,
    CSSPObjectVersionStorageClassStandard,
};

typedef NS_ENUM(NSInteger, CSSPPayer) {
    CSSPPayerUnknown,
    CSSPPayerRequester,
    CSSPPayerBucketOwner,
};

typedef NS_ENUM(NSInteger, CSSPPermission) {
    CSSPPermissionUnknown,
    CSSPPermissionFullControl,
    CSSPPermissionWrite,
    CSSPPermissionWriteAcp,
    CSSPPermissionRead,
    CSSPPermissionReadAcp,
};

typedef NS_ENUM(NSInteger, CSSPProtocol) {
    CSSPProtocolUnknown,
    CSSPProtocolHTTP,
    CSSPProtocolHTTPS,
};

typedef NS_ENUM(NSInteger, CSSPServerSideEncryption) {
    CSSPServerSideEncryptionUnknown,
    CSSPServerSideEncryptionAES256,
};

typedef NS_ENUM(NSInteger, CSSPStorageClass) {
    CSSPStorageClassUnknown,
    CSSPStorageClassStandard,
    CSSPStorageClassReducedRedundancy,
};

typedef NS_ENUM(NSInteger, CSSPTransitionStorageClass) {
    CSSPTransitionStorageClassUnknown,
    CSSPTransitionStorageClassGlacier,
};

typedef NS_ENUM(NSInteger, CSSPType) {
    CSSPTypeUnknown,
    CSSPTypeCanonicalUser,
    CSSPTypeAmazonCustomerByEmail,
    CSSPTypeGroup,
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


@interface CSSPAbortMultipartUploadRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *uploadId;

@end


@interface CSSPCompletedMultipartUpload : NSObject

@property (nonatomic, strong) NSArray *parts;

@end


@interface CSSPCompleteMultipartUploadOutput : CSSPModel

@property (nonatomic, strong) NSString *container;

/**
 * Entity tag of the object.
 */
@property (nonatomic, strong) NSString *ETag;

/**
 * If the object expiration is configured, this will contain the expiration date (expiry-date) and rule ID (rule-id). The value of rule-id is URL encoded.
 */
@property (nonatomic, strong) NSDate *expiration;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *location;

/**
 * Version of the object.
 */
@property (nonatomic, strong) NSString *versionId;

@end


@interface CSSPCompleteMultipartUploadRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) CSSPCompletedMultipartUpload *multipartUpload;
@property (nonatomic, strong) NSString *uploadId;

@end

@interface CSSPDeleteObjectOutput : CSSPModel

@property (nonatomic, strong) NSNumber *deleteMarker;

@end


@interface CSSPDeleteObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@end


@interface CSSPGetContainerAclOutput : CSSPModel


/**
 * A list of grants.
 */
@property (nonatomic, strong) NSArray *grants;
@property (nonatomic, strong) CSSPOwner *owner;

@end

@interface CSSPGetContainerAclRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;

@end


@interface CSSPGetObjectOutput : CSSPModel

@property (nonatomic, strong) NSString *acceptRanges;

/**
 * Object data.
 */
@property (nonatomic, strong) id body;

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
 * Size of the body in bytes.
 */
@property (nonatomic, strong) NSNumber *contentLength;

/**
 * A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString *contentType;

/**
 * Specifies whether the object retrieved was (true) or was not (false) a Delete Marker. If false, this response header does not appear in the response.
 */
@property (nonatomic, strong) NSNumber *deleteMarker;

/**
 * An ETag is an opaque identifier assigned by a web server to a specific version of a resource found at a URL
 */
@property (nonatomic, strong) NSString *ETag;

/**
 * If the object expiration is configured (see PUT Bucket lifecycle), the response includes this header. It includes the expiry-date and rule-id key value pairs providing object expiration information. The value of the rule-id is URL encoded.
 */
@property (nonatomic, strong) NSDate *expiration;

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

/**
 * This is set to the number of metadata entries not returned in x-amz-meta headers. This can happen if you create metadata using an API like SOAP that supports more flexible metadata than the REST API. For example, using SOAP, you can create metadata whose values are not legal HTTP headers.
 */
@property (nonatomic, strong) NSNumber *missingMeta;

/**
 * Provides information about object restoration operation and expiration time of the restored object copy.
 */
@property (nonatomic, strong) NSString *restore;

/**
 * If the container is configured as a website, redirects requests for this object to another object in the same container or to an external URL. Amazon S3 stores the value of this header in the object metadata.
 */
@property (nonatomic, strong) NSString *websiteRedirectLocation;

@end


@interface CSSPGetObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@property (nonatomic, strong) NSOutputStream * outputStream;

@end

@interface CSSPHeadContainerRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;

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
 * The language the content is in.
 */
@property (nonatomic, strong) NSString *contentLanguage;

/**
 * Size of the body in bytes.
 */
@property (nonatomic, strong) NSNumber *contentLength;

/**
 * A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString *contentType;

/**
 * Specifies whether the object retrieved was (true) or was not (false) a Delete Marker. If false, this response header does not appear in the response.
 */
@property (nonatomic, strong) NSNumber *deleteMarker;

/**
 * An ETag is an opaque identifier assigned by a web server to a specific version of a resource found at a URL
 */
@property (nonatomic, strong) NSString *ETag;

/**
 * If the object expiration is configured (see PUT Bucket lifecycle), the response includes this header. It includes the expiry-date and rule-id key value pairs providing object expiration information. The value of the rule-id is URL encoded.
 */
@property (nonatomic, strong) NSDate *expiration;

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

/**
 * This is set to the number of metadata entries not returned in x-amz-meta headers. This can happen if you create metadata using an API like SOAP that supports more flexible metadata than the REST API. For example, using SOAP, you can create metadata whose values are not legal HTTP headers.
 */
@property (nonatomic, strong) NSNumber *missingMeta;

/**
 * Provides information about object restoration operation and expiration time of the restored object copy.
 */
@property (nonatomic, strong) NSString *restore;

@end

@interface CSSPHeaderObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@end


@interface CSSPListObjectsOutput : CSSPModel

@property (nonatomic, strong) NSArray *commonPrefixes;
@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSString *delimiter;

/**
 * A flag that indicates whether or not Amazon S3 returned all of the results that satisfied the search criteria.
 */
@property (nonatomic, strong) NSNumber *isTruncated;
@property (nonatomic, strong) NSString *marker;
@property (nonatomic, strong) NSNumber *maxKeys;
@property (nonatomic, strong) NSString *name;

/**
 * When response is truncated (the IsTruncated element value in the response is true), you can use the key name in this field as marker in the subsequent request to get next set of objects. Amazon S3 lists objects in alphabetical order Note: This element is returned only if you have delimiter request parameter specified. If response does not include the NextMaker and it is truncated, you can use the value of the last Key in the response as the marker in the subsequent request to get the next set of object keys.
 */
@property (nonatomic, strong) NSString *nextMarker;
@property (nonatomic, strong) NSString *prefix;

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


@interface CSSPInitiator : CSSPModel


/**
 * Name of the Principal.
 */
@property (nonatomic, strong) NSString *displayName;

/**
 * If the principal is an AWS account, it provides the Canonical User ID. If the principal is an IAM User, it provides a user ARN value.
 */
@property (nonatomic, strong) NSString *ID;

@end


@interface CSSPListPartsOutput : CSSPModel


/**
 * Name of the container to which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString *container;

/**
 * Identifies who initiated the multipart upload.
 */
@property (nonatomic, strong) CSSPInitiator *initiator;

/**
 * Indicates whether the returned list of parts is truncated.
 */
@property (nonatomic, strong) NSNumber *isTruncated;

/**
 * Object key for which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString *key;

/**
 * Maximum number of parts that were allowed in the response.
 */
@property (nonatomic, strong) NSNumber *maxParts;

/**
 * When a list is truncated, this element specifies the last part in the list, as well as the value to use for the part-number-marker request parameter in a subsequent request.
 */
@property (nonatomic, strong) NSNumber *nextPartNumberMarker;
@property (nonatomic, strong) CSSPOwner *owner;

/**
 * Part number after which listing begins.
 */
@property (nonatomic, strong) NSNumber *partNumberMarker;
@property (nonatomic, strong) NSArray *parts;

/**
 * The class of storage used to store the object.
 */
@property (nonatomic, assign) CSSPStorageClass storageClass;

/**
 * Upload ID identifying the multipart upload whose parts are being listed.
 */
@property (nonatomic, strong) NSString *uploadId;

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

@interface CSSPPutObjectOutput : CSSPModel


/**
 * Entity tag for the uploaded object.
 */
@property (nonatomic, strong) NSString *ETag;

/**
 * If the object expiration is configured, this will contain the expiration date (expiry-date) and rule ID (rule-id). The value of rule-id is URL encoded.
 */
@property (nonatomic, strong) NSDate *expiration;

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


@interface CSSPUploadPartOutput : CSSPModel


/**
 * Entity tag for the uploaded object.
 */
@property (nonatomic, strong) NSString *ETag;

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


