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
             @"object" : @"Object",
             @"uploadId" : @"UploadId",
             };
}

@end

@implementation CSSPCompleteMultipartUploadOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"ETag" : @"ETag",
             @"object" : @"Object"
             };
}

+ (NSValueTransformer *)expirationJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate cssp_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
        return [date cssp_stringValue:CSSPDateISO8601DateFormat1];
    }];
}

@end

@implementation CSSPCompleteMultipartUploadRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"object" : @"Object",
             @"manifest" : @"Manifest",
             @"uploadId" : @"UploadId",
             };
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
             @"object" : @"Object"
             };
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
             @"object" : @"Object",
             };
}

@end

@implementation CSSPGetContainerAclOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"grants" : @"Grants"
             };
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
             @"body" : @"Body",
             @"contentLength" : @"ContentLength",
             @"contentType" : @"ContentType",
             @"ETag" : @"ETag",
             @"lastModified" : @"LastModified",
             @"metadata" : @"Metadata",
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

@implementation CSSPGetObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
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

@implementation CSSPHeadContainerOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"objectCount" : @"ObjectCount",
             @"bytesUsed" : @"BytesUsed",
             @"grantRead" : @"GrantRead",
             @"metadata" : @"Metadata",
             };
}

@end

@implementation CSSPHeadContainerRequest

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
             @"ETag" : @"ETag",
             @"expires" : @"Expires",
             @"lastModified" : @"LastModified",
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
             @"object" : @"Object",
             };
}

@end


@implementation CSSPListMultipartUploadsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"uploads" : @"object",
             };
}

+ (NSValueTransformer *)uploadsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPObject class]];
}

@end


@implementation CSSPListMultipartUploadsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"object":@"Object",
             @"maxUploads" : @"MaxUploads",
             @"prefix" : @"Prefix",
             @"uploadId" : @"UploadId",
             };
}

@end

@implementation CSSPObject

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"etag" : @"ETag",
             @"name" : @"Name",
             @"lastModified" : @"LastModified",
             @"size" : @"Size",
             @"contentType" : @"ContentType",
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
             @"contents" : @"ObjectList",
             @"subdirs" : @"SubdirList"
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
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"marker" : @"Marker",
             @"limit" : @"MaxKeys",
             @"prefix" : @"Prefix",
             @"endMarker":@"EndMarker"
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
             @"contents" : @"object"
             };
}

+ (NSValueTransformer *)contentsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPObject class]];
}

@end

@implementation CSSPListPartsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"object" : @"Object",
             @"uploadID":@"UploadID",
             @"prefix" : @"Prefix",
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
             @"grantRead" : @"GrantRead"
             };
}

@end

@implementation CSSPPutObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ETag" : @"ETag"
             };
}

@end

@implementation CSSPPutObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"body" : @"Body",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
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

@implementation CSSPReplicateObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ETag" : @"ETag"
             };
}

@end

@implementation CSSPReplicateObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"object" : @"Object",
             @"contentLength" : @"ContentLength",
             @"replicateSource" : @"CopySource"
             };
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
             @"contentLength" : @"ContentLength",
             @"contentMD5" : @"ContentMD5",
             @"object" : @"Object",
             @"partNumber" : @"PartNumber",
             @"uploadId" : @"UploadId",
             };
}

@end
