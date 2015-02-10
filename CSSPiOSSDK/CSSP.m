//
//  CSSPiOSSDK.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/26.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSP.h"
#import "CSSPNetworking.h"
#import "CSSPSignature.h"
#import "CSSPCategory.h"
#import "CSSPNetworking.h"
#import "CSSPURLRequestSerialization.h"
#import "CSSPURLResponseSerialization.h"

static NSString *CSSPAPIVersion = @"cssp-2015-02-09";

@implementation CSSPEndpoint

-(instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _URL = url;
        _hostName = [url host];
        NSArray *pathComponents = [url pathComponents];
        
        if ([pathComponents count] > 1)
            _containerName = [pathComponents objectAtIndex:1];
    }
    return self;
}


+(instancetype)endpointWithURL:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CSSPEndpoint *endpoint = [[CSSPEndpoint alloc] initWithURL:url];
    return endpoint;
}


@end

@implementation CSSPServiceConfiguration

- (instancetype)initWithCredentialsProvider:(id<CSSPCredentialsProvider>)credentialsProvider
                               withEndpoint:(CSSPEndpoint *)endpoint{
    if (self = [super init]) {
        _credentialsProvider = credentialsProvider;
        _endpoint = endpoint;
    }
    return self;
}

+ (instancetype)configurationWithCredentialsProvider:(id<CSSPCredentialsProvider>)credentialsProvider
                                        withEndpoint:(CSSPEndpoint *)endpoint {
    CSSPServiceConfiguration *configuration = [[CSSPServiceConfiguration alloc] initWithCredentialsProvider:credentialsProvider withEndpoint:endpoint];
    return configuration;
}


- (id)copyWithZone:(NSZone *)zone {
    CSSPServiceConfiguration *configuration = [[[self class] allocWithZone:zone] initWithCredentialsProvider: self.credentialsProvider withEndpoint:self.endpoint];
    return configuration;
}

- (void)setEndpoint:(CSSPEndpoint *)endpoint {
    _endpoint = endpoint;
}

@end

@interface CSSPRequest()

@property (nonatomic, strong) CSSPNetworkingRequest *internalRequest;

@end


@interface CSSP()

@property (nonatomic, strong) CSSPNetworking *networking;
@property (nonatomic, strong) CSSPServiceConfiguration *configuration;

@end

@implementation CSSP

-(instancetype)initWithConfiguration:(CSSPServiceConfiguration *)configuration withEndpoint:(CSSPEndpoint *)endpoint {
    if (self = [super init]) {
        _configuration = configuration;
        _configuration.endpoint = endpoint;
        
        CSSPSignatureSigner *signer = [CSSPSignatureSigner signerWithCredentialsProvider:configuration.credentialsProvider];
        _configuration.baseURL = _configuration.endpoint.URL;
        _configuration.requestInterceptors = @[[CSSPNetworkingRequestInterceptor new], signer];
        
        _configuration.headers = @{
                                   @"Host" : _configuration.endpoint.hostName,
                                   };
    
        _networking = [CSSPNetworking networking:_configuration];
    }
    return self;
}


- (BFTask *)invokeRequest:(CSSPRequest *)request
               HTTPMethod:(CSSPHTTPMethod)HTTPMethod
                URLString:(NSString *) URLString
             targetPrefix:(NSString *)targetPrefix
            operationName:(NSString *)operationName
              outputClass:(Class)outputClass {
    if (!request) {
        request = [CSSPRequest new];
    }
    
    CSSPNetworkingRequest *networkingRequest = request.internalRequest;
    if (request) {
        networkingRequest.parameters = [[MTLJSONAdapter JSONDictionaryFromModel:request] cssp_removeNullValues];
    } else {
        networkingRequest.parameters = @{};
    }
    networkingRequest.shouldWriteDirectly = [[request valueForKey:@"shouldWriteDirectly"] boolValue];
    networkingRequest.downloadingFileURL = request.downloadingFileURL;
    networkingRequest.HTTPMethod = HTTPMethod;
    networkingRequest.responseSerializer = [CSSPXMLResponseSerializer serializerWithResource:CSSPAPIVersion
                                                                                actionName:operationName
                                                                               outputClass:outputClass];
    networkingRequest.requestSerializer = [CSSPXMLRequestSerializer serializerWithResource:CSSPAPIVersion
                                                                               actionName:operationName];
    
    return [self.networking sendRequest:networkingRequest];
}

-(BFTask *)abortMultipartUpload:(CSSPAbortMultipartUploadRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodDELETE
                     URLString:@"/{Container}/{Object+}"
                  targetPrefix:@""
                 operationName:@"AbortMultipartUpload"
                   outputClass:nil];
}

- (BFTask *)completeMultipartUpload:(CSSPCompleteMultipartUploadRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodPOST
                     URLString:@"/{Container}/{Object+}"
                  targetPrefix:@""
                 operationName:@"CompleteMultipartUpload"
                   outputClass:[CSSPCompleteMultipartUploadOutput class]];
}

- (BFTask *)createMultipartUpload:(CSSPCreateMultipartUploadRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodPOST
                     URLString:@"/{Container}/{Object+}?uploads"
                  targetPrefix:@""
                 operationName:@"CreateMultipartUpload"
                   outputClass:[CSSPCreateMultipartUploadOutput class]];
}

- (BFTask *)deleteObject:(CSSPDeleteObjectRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodDELETE
                     URLString:@"/{Container}/{Object+}"
                  targetPrefix:@""
                 operationName:@"DeleteObject"
                   outputClass:[CSSPDeleteObjectOutput class]];
}

- (BFTask *)getContainerAcl:(CSSPGetContainerAclRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodGET
                     URLString:@"/{Container}?acl"
                  targetPrefix:@""
                 operationName:@"GetContainerAcl"
                   outputClass:[CSSPGetContainerAclOutput class]];
}

- (BFTask *)getObject:(CSSPGetObjectRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodGET
                     URLString:@"/{Container}/{Object+}"
                  targetPrefix:@""
                 operationName:@"GetObject"
                   outputClass:[CSSPGetObjectOutput class]];
}
- (BFTask *)headContainer:(CSSPHeadContainerRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodHEAD
                     URLString:@"/{Container}"
                  targetPrefix:@""
                 operationName:@"HeadContainer"
                   outputClass:nil];
}

- (BFTask *)headObject:(CSSPHeadObjectRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodHEAD
                     URLString:@"/{Container}/{Object+}"
                  targetPrefix:@""
                 operationName:@"HeadObject"
                   outputClass:[CSSPHeadObjectOutput class]];
}

- (BFTask *)listMultipartUploads:(CSSPListMultipartUploadsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodGET
                     URLString:@"/{Container}?uploads"
                  targetPrefix:@""
                 operationName:@"ListMultipartUploads"
                   outputClass:[CSSPListMultipartUploadsOutput class]];
}


- (BFTask *)listObjects:(CSSPListObjectsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodGET
                     URLString:@"/{Container}"
                  targetPrefix:@""
                 operationName:@"ListObjects"
                   outputClass:[CSSPListObjectsOutput class]];
}

- (BFTask *)listParts:(CSSPListPartsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodGET
                     URLString:@"/{Container}/{Object+}"
                  targetPrefix:@""
                 operationName:@"ListParts"
                   outputClass:[CSSPListPartsOutput class]];
}

- (BFTask *)putContainerAcl:(CSSPPutContainerAclRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodPUT
                     URLString:@"/{Container}?acl"
                  targetPrefix:@""
                 operationName:@"PutContainerAcl"
                   outputClass:nil];
}

- (BFTask *)putObject:(CSSPPutObjectRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodPUT
                     URLString:@"/{Container}/{Object+}"
                  targetPrefix:@""
                 operationName:@"PutObject"
                   outputClass:[CSSPPutObjectOutput class]];
}

- (BFTask *)replicateObject:(CSSPReplicateObjectRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodPUT
                     URLString:@"/{Container}/{Object+}"
                  targetPrefix:@""
                 operationName:@"ReplicateObject"
                   outputClass:[CSSPReplicateObjectOutput class]];
}


- (BFTask *)uploadPart:(CSSPUploadPartRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:CSSPHTTPMethodPUT
                     URLString:@"/{Container}/{Object+}"
                  targetPrefix:@""
                 operationName:@"UploadPart"
                   outputClass:[CSSPUploadPartOutput class]];
}

@end
