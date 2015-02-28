//
//  CSSPModel.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/4.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPModule.h"
#import "CSSPCategory.h"

NSString *const CSSPErrorDomain = @"com.iflycssp.CSSPErrorDomain";

@implementation CSSPAbortMultipartUploadRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"object" : @"Object",
             @"uploadId" : @"UploadId",
             };
}

@end

@implementation CSSPAccessControlPolicy

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"grants" : @"Grants",
             @"owner" : @"Owner",
             };
}

+ (NSValueTransformer *)grantsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPGrant class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPOwner class]];
}

@end



@implementation CSSPCompleteMultipartUploadOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"ETag" : @"ETag",
             @"expiration" : @"Expiration",
             @"object" : @"Object",
             @"location" : @"Location",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)expirationJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"AES256"]) {
            return @(CSSPServerSideEncryptionAES256);
        }
        return @(CSSPServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPServerSideEncryptionAES256:
                return @"AES256";
            case CSSPServerSideEncryptionUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation CSSPCompleteMultipartUploadRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"object" : @"Object",
             @"multipartUpload" : @"MultipartUpload",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)multipartUploadJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPCompletedMultipartUpload class]];
}

@end

@implementation CSSPCompletedMultipartUpload

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"parts" : @"Parts",
             };
}

+ (NSValueTransformer *)partsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPCompletedPart class]];
}

@end

@implementation CSSPCompletedPart

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ETag" : @"ETag",
             @"partNumber" : @"PartNumber",
             };
}

@end


@implementation CSSPCreateMultipartUploadOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"object" : @"Object",
             @"uploadId" : @"UploadId",
             };
}
@end

@implementation CSSPCreateMultipartUploadRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ACL" : @"ACL",
             @"container" : @"Container",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentType" : @"ContentType",
             @"expires" : @"Expires",
             @"grantFullControl" : @"GrantFullControl",
             @"grantRead" : @"GrantRead",
             @"grantReadACP" : @"GrantReadACP",
             @"grantWriteACP" : @"GrantWriteACP",
             @"object" : @"Object",
             @"metadata" : @"Metadata",
             @"storageClass" : @"StorageClass",
             };
}

+ (NSValueTransformer *)ACLJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"private"]) {
            return @(CSSPObjectCannedACLPrivate);
        }
        if ([value isEqualToString:@"public-read"]) {
            return @(CSSPObjectCannedACLPublicRead);
        }
        if ([value isEqualToString:@"public-read-write"]) {
            return @(CSSPObjectCannedACLPublicReadWrite);
        }
        if ([value isEqualToString:@"authenticated-read"]) {
            return @(CSSPObjectCannedACLAuthenticatedRead);
        }
        if ([value isEqualToString:@"container-owner-read"]) {
            return @(CSSPObjectCannedACLContainerOwnerRead);
        }
        if ([value isEqualToString:@"container-owner-full-control"]) {
            return @(CSSPObjectCannedACLContainerOwnerFullControl);
        }
        return @(CSSPObjectCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPObjectCannedACLPrivate:
                return @"private";
            case CSSPObjectCannedACLPublicRead:
                return @"public-read";
            case CSSPObjectCannedACLPublicReadWrite:
                return @"public-read-write";
            case CSSPObjectCannedACLAuthenticatedRead:
                return @"authenticated-read";
            case CSSPObjectCannedACLContainerOwnerRead:
                return @"container-owner-read";
            case CSSPObjectCannedACLContainerOwnerFullControl:
                return @"container-owner-full-control";
            case CSSPObjectCannedACLUnknown:
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)expiresJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}


+ (NSValueTransformer *)storageClassJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"STANDARD"]) {
            return @(CSSPStorageClassStandard);
        }
        if ([value isEqualToString:@"REDUCED_REDUNDANCY"]) {
            return @(CSSPStorageClassReducedRedundancy);
        }
        return @(CSSPStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPStorageClassStandard:
                return @"STANDARD";
            case CSSPStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            case CSSPStorageClassUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation CSSPDeleteObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"deleteMarker" : @"DeleteMarker",
             };
}

@end

@implementation CSSPDeleteObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"object" : @"Object",
             };
}

@end

@implementation CSSPGetContainerAclOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"grants" : @"Grants",
             @"owner" : @"Owner",
             };
}

+ (NSValueTransformer *)grantsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPGrant class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPOwner class]];
}

@end

@implementation CSSPGetContainerAclRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             };
}

@end

@implementation CSSPGetObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"acceptRanges" : @"AcceptRanges",
             @"body" : @"Body",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentLength" : @"ContentLength",
             @"contentType" : @"ContentType",
             @"deleteMarker" : @"DeleteMarker",
             @"ETag" : @"ETag",
             @"expiration" : @"Expiration",
             @"expires" : @"Expires",
             @"lastModified" : @"LastModified",
             @"metadata" : @"Metadata",
             };
}

+ (NSValueTransformer *)expirationJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

+ (NSValueTransformer *)expiresJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

@end

@implementation CSSPGetObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"object" : @"Object",
             @"range" : @"Range",
             @"responseExpires" : @"ResponseExpires",
             };
}

+ (NSValueTransformer *)responseExpiresJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

@end


@implementation CSSPGrant

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"grantee" : @"Grantee",
             @"permission" : @"Permission",
             };
}

+ (NSValueTransformer *)granteeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPGrantee class]];
}

+ (NSValueTransformer *)permissionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"FULL_CONTROL"]) {
            return @(CSSPPermissionFullControl);
        }
        if ([value isEqualToString:@"WRITE"]) {
            return @(CSSPPermissionWrite);
        }
        if ([value isEqualToString:@"WRITE_ACP"]) {
            return @(CSSPPermissionWriteAcp);
        }
        if ([value isEqualToString:@"READ"]) {
            return @(CSSPPermissionRead);
        }
        if ([value isEqualToString:@"READ_ACP"]) {
            return @(CSSPPermissionReadAcp);
        }
        return @(CSSPPermissionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPPermissionFullControl:
                return @"FULL_CONTROL";
            case CSSPPermissionWrite:
                return @"WRITE";
            case CSSPPermissionWriteAcp:
                return @"WRITE_ACP";
            case CSSPPermissionRead:
                return @"READ";
            case CSSPPermissionReadAcp:
                return @"READ_ACP";
            case CSSPPermissionUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation CSSPGrantee

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"displayName" : @"DisplayName",
             @"emailAddress" : @"EmailAddress",
             @"ID" : @"ID",
             @"type" : @"Type",
             @"URI" : @"URI",
             };
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"CanonicalUser"]) {
            return @(CSSPTypeCanonicalUser);
        }
        if ([value isEqualToString:@"AmazonCustomerByEmail"]) {
            return @(CSSPTypeAmazonCustomerByEmail);
        }
        if ([value isEqualToString:@"Group"]) {
            return @(CSSPTypeGroup);
        }
        return @(CSSPTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPTypeCanonicalUser:
                return @"CanonicalUser";
            case CSSPTypeAmazonCustomerByEmail:
                return @"AmazonCustomerByEmail";
            case CSSPTypeGroup:
                return @"Group";
            case CSSPTypeUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation CSSPHeadContainerRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             };
}

@end

@implementation CSSPHeadObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"acceptRanges" : @"AcceptRanges",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentLength" : @"ContentLength",
             @"contentType" : @"ContentType",
             @"deleteMarker" : @"DeleteMarker",
             @"ETag" : @"ETag",
             @"expiration" : @"Expiration",
             @"expires" : @"Expires",
             @"lastModified" : @"LastModified",
             @"metadata" : @"Metadata",
             };
}

+ (NSValueTransformer *)expirationJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

+ (NSValueTransformer *)expiresJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

@end

@implementation CSSPHeadObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"object" : @"Object",
             };
}

@end


@implementation CSSPInitiator

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"displayName" : @"DisplayName",
             @"ID" : @"ID",
             };
}

@end

@implementation CSSPCommonPrefix

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"prefix" : @"Prefix",
             };
}

@end

@implementation CSSPListMultipartUploadsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"commonPrefixes" : @"CommonPrefixes",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"isTruncated" : @"IsTruncated",
             @"keyMarker" : @"KeyMarker",
             @"maxUploads" : @"MaxUploads",
             @"nextKeyMarker" : @"NextKeyMarker",
             @"nextUploadIdMarker" : @"NextUploadIdMarker",
             @"prefix" : @"Prefix",
             @"uploadIdMarker" : @"UploadIdMarker",
             @"uploads" : @"Uploads",
             };
}

+ (NSValueTransformer *)commonPrefixesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPCommonPrefix class]];
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"url"]) {
            return @(CSSPEncodingTypeURL);
        }
        return @(CSSPEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPEncodingTypeURL:
                return @"url";
            case CSSPEncodingTypeUnknown:
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)uploadsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPMultipartUpload class]];
}

@end

@implementation CSSPListMultipartUploadsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"keyMarker" : @"KeyMarker",
             @"maxUploads" : @"MaxUploads",
             @"prefix" : @"Prefix",
             @"uploadIdMarker" : @"UploadIdMarker",
             };
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"url"]) {
            return @(CSSPEncodingTypeURL);
        }
        return @(CSSPEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPEncodingTypeURL:
                return @"url";
            case CSSPEncodingTypeUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation CSSPObject

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"etag" : @"hash",
             @"name" : @"name",
             @"lastModified" : @"last_modified",
             @"size" : @"bytes",
             @"contentType" : @"content_type",
             };
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

@end

@implementation CSSPSubdir
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name" : @"name"
             };
}
@end


@implementation CSSPListObjectsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contents" : @"object",
             @"subdirs" : @"subdir"
             };
}

+ (NSValueTransformer *)contentsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPObject class]];
}

+ (NSValueTransformer *)subdirsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPSubdir class]];
}

@end

@implementation CSSPListObjectsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"marker" : @"Marker",
             @"limit" : @"MaxKeys",
             @"prefix" : @"Prefix",
             };
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"url"]) {
            return @(CSSPEncodingTypeURL);
        }
        return @(CSSPEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPEncodingTypeURL:
                return @"url";
            case CSSPEncodingTypeUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation CSSPListPartsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"initiator" : @"Initiator",
             @"isTruncated" : @"IsTruncated",
             @"object" : @"Object",
             @"maxParts" : @"MaxParts",
             @"nextPartNumberMarker" : @"NextPartNumberMarker",
             @"owner" : @"Owner",
             @"partNumberMarker" : @"PartNumberMarker",
             @"parts" : @"Parts",
             @"storageClass" : @"StorageClass",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)initiatorJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPInitiator class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPOwner class]];
}

+ (NSValueTransformer *)partsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPPart class]];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"STANDARD"]) {
            return @(CSSPStorageClassStandard);
        }
        if ([value isEqualToString:@"REDUCED_REDUNDANCY"]) {
            return @(CSSPStorageClassReducedRedundancy);
        }
        return @(CSSPStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPStorageClassStandard:
                return @"STANDARD";
            case CSSPStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            case CSSPStorageClassUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation CSSPListPartsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"object" : @"Object",
             @"maxParts" : @"MaxParts",
             @"partNumberMarker" : @"PartNumberMarker",
             @"uploadId" : @"UploadId",
             };
}

@end

@implementation CSSPMultipartUpload

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"initiated" : @"Initiated",
             @"initiator" : @"Initiator",
             @"object" : @"Object",
             @"owner" : @"Owner",
             @"storageClass" : @"StorageClass",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)initiatedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

+ (NSValueTransformer *)initiatorJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPInitiator class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPOwner class]];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"STANDARD"]) {
            return @(CSSPStorageClassStandard);
        }
        if ([value isEqualToString:@"REDUCED_REDUNDANCY"]) {
            return @(CSSPStorageClassReducedRedundancy);
        }
        return @(CSSPStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPStorageClassStandard:
                return @"STANDARD";
            case CSSPStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            case CSSPStorageClassUnknown:
            default:
                return nil;
        }
    }];
}

@end



@implementation CSSPOwner

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"displayName" : @"DisplayName",
             @"ID" : @"ID",
             };
}

@end


@implementation CSSPPart

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ETag" : @"ETag",
             @"lastModified" : @"LastModified",
             @"partNumber" : @"PartNumber",
             @"size" : @"Size",
             };
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

@end



@implementation CSSPPutContainerAclRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ACL" : @"ACL",
             @"accessControlPolicy" : @"AccessControlPolicy",
             @"container" : @"Container",
             @"contentMD5" : @"ContentMD5",
             @"grantFullControl" : @"GrantFullControl",
             @"grantRead" : @"GrantRead",
             @"grantReadACP" : @"GrantReadACP",
             @"grantWrite" : @"GrantWrite",
             @"grantWriteACP" : @"GrantWriteACP",
             };
}

+ (NSValueTransformer *)ACLJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"private"]) {
            return @(CSSPContainerCannedACLPrivate);
        }
        if ([value isEqualToString:@"public-read"]) {
            return @(CSSPContainerCannedACLPublicRead);
        }
        if ([value isEqualToString:@"public-read-write"]) {
            return @(CSSPContainerCannedACLPublicReadWrite);
        }
        if ([value isEqualToString:@"authenticated-read"]) {
            return @(CSSPContainerCannedACLAuthenticatedRead);
        }
        return @(CSSPContainerCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPContainerCannedACLPrivate:
                return @"private";
            case CSSPContainerCannedACLPublicRead:
                return @"public-read";
            case CSSPContainerCannedACLPublicReadWrite:
                return @"public-read-write";
            case CSSPContainerCannedACLAuthenticatedRead:
                return @"authenticated-read";
            case CSSPContainerCannedACLUnknown:
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)accessControlPolicyJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPAccessControlPolicy class]];
}

@end

@implementation CSSPPutObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ETag" : @"ETag",
             @"expiration" : @"Expiration",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)expirationJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"AES256"]) {
            return @(CSSPServerSideEncryptionAES256);
        }
        return @(CSSPServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPServerSideEncryptionAES256:
                return @"AES256";
            case CSSPServerSideEncryptionUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation CSSPPutObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"body" : @"Body",
             @"container" : @"Container",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentLength" : @"ContentLength",
             @"contentMD5" : @"ContentMD5",
             @"contentType" : @"ContentType",
             @"expires" : @"Expires",
             @"object" : @"Object",
             @"metadata" : @"Metadata",
             };
}


+ (NSValueTransformer *)expiresJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

@end

@implementation CSSPReplicateObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ACL" : @"ACL",
             @"container" : @"Container",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentType" : @"ContentType",
             @"expires" : @"Expires",
             @"grantFullControl" : @"GrantFullControl",
             @"grantRead" : @"GrantRead",
             @"grantReadACP" : @"GrantReadACP",
             @"grantWriteACP" : @"GrantWriteACP",
             @"object" : @"Object",
             @"metadata" : @"Metadata",
             @"metadataDirective" : @"MetadataDirective",
             @"replicateSource" : @"CopySource",
             };
}

+ (NSValueTransformer *)ACLJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"private"]) {
            return @(CSSPObjectCannedACLPrivate);
        }
        if ([value isEqualToString:@"public-read"]) {
            return @(CSSPObjectCannedACLPublicRead);
        }
        if ([value isEqualToString:@"public-read-write"]) {
            return @(CSSPObjectCannedACLPublicReadWrite);
        }
        if ([value isEqualToString:@"authenticated-read"]) {
            return @(CSSPObjectCannedACLAuthenticatedRead);
        }
        if ([value isEqualToString:@"container-owner-read"]) {
            return @(CSSPObjectCannedACLContainerOwnerRead);
        }
        if ([value isEqualToString:@"container-owner-full-control"]) {
            return @(CSSPObjectCannedACLContainerOwnerFullControl);
        }
        return @(CSSPObjectCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPObjectCannedACLPrivate:
                return @"private";
            case CSSPObjectCannedACLPublicRead:
                return @"public-read";
            case CSSPObjectCannedACLPublicReadWrite:
                return @"public-read-write";
            case CSSPObjectCannedACLAuthenticatedRead:
                return @"authenticated-read";
            case CSSPObjectCannedACLContainerOwnerRead:
                return @"container-owner-read";
            case CSSPObjectCannedACLContainerOwnerFullControl:
                return @"container-owner-full-control";
            case CSSPObjectCannedACLUnknown:
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)expiresJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

+ (NSValueTransformer *)metadataDirectiveJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"COPY"]) {
            return @(CSSPMetadataDirectiveCopy);
        }
        if ([value isEqualToString:@"REPLACE"]) {
            return @(CSSPMetadataDirectiveReplace);
        }
        return @(CSSPMetadataDirectiveUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPMetadataDirectiveCopy:
                return @"COPY";
            case CSSPMetadataDirectiveReplace:
                return @"REPLACE";
            case CSSPMetadataDirectiveUnknown:
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"STANDARD"]) {
            return @(CSSPStorageClassStandard);
        }
        if ([value isEqualToString:@"REDUCED_REDUNDANCY"]) {
            return @(CSSPStorageClassReducedRedundancy);
        }
        return @(CSSPStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case CSSPStorageClassStandard:
                return @"STANDARD";
            case CSSPStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            case CSSPStorageClassUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation CSSPReplicateObjectResult

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ETag" : @"ETag",
             @"lastModified" : @"LastModified",
             };
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

@end

@implementation CSSPReplicateObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"expiration" : @"Expiration",
             @"replicateObjectResult" : @"CopyObjectResult",
             };
}

+ (NSValueTransformer *)expirationJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

+ (NSValueTransformer *)replicateObjectResultJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CSSPReplicateObjectResult class]];
}

@end

@implementation CSSPUploadPartOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ETag" : @"ETag",
             };
}

@end

@implementation CSSPUploadPartRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"body" : @"Body",
             @"container" : @"Container",
             @"contentLength" : @"ContentLength",
             @"contentMD5" : @"ContentMD5",
             @"object" : @"Object",
             @"partNumber" : @"PartNumber",
             @"uploadId" : @"UploadId",
             };
}

@end
