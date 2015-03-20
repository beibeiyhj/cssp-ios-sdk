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
/**
 *  初始化
 *
 *  @return CSSP对象
 */
+ (CSSP *) initialize;


/**
 *  设置Access Key ID、Secert Key ID、Endpoint等
 *
 *  @param configuration CSSP配置接口
 *  这个接口必须实现
 */
- (void) initWithConfiguration:(CSSPServiceConfiguration *)configuration;

/**
 *  终止分块上传任务，并删除已上传的数据
 *
 *  @param request 分块上传任务的相关信息
 *
 *  @return BFTask实例，成功的话，BFTask.error为nil，否则该次操作失败
 */
- (BFTask *) abortMultipartUpload:(CSSPAbortMultipartUploadRequest *)request;

/**
 *  完成分块上传
 *
 *  @param request 分块上传任务的相关信息
 *
 *  @return BFTask实例，成功的话，BFTask.result包含CSSPCompleteMultipartUploadOutput实例,
 *          包括Object的ETag等信息
 */
- (BFTask *) completeMultipartUpload:(CSSPCompleteMultipartUploadRequest *)request;

/**
 *  创建分块上传任务，生成UploadID
 *
 *  @param request 分块上传任务的相关信息，包括Object名等信息
 *
 *  @return BFTask实例，成功的话，BFTask.error为nil，否则删除该object失败
 */
- (BFTask *) createMultipartUpload:(CSSPCreateMultipartUploadRequest *)request;

/**
 *  删除指定的Object
 *
 *  @param request 需要删除的object信息
 *
 *  @return BFTask实例,成功的话，BFTask.result包含CSSPCreateMultipartUploadOutput实例
 */
- (BFTask *) deleteObject:(CSSPDeleteObjectRequest *)request;

/**
 *  获取指定的object
 *
 *  @param request 指定的object信息
 *
 *  @return BFTask实例，成功的话，BFTask.result包含CSSPGetObjectOutput实例,
 *          包括Object的数据、元数据、MD5等
 */
- (BFTask *) getObject:(CSSPGetObjectRequest *)request;

/**
 *  获取当前Container信息
 *
 *  @return BFTask实例,成功的话，BFTask.result包含CSSPHeadContainerOutput实例
 */
- (BFTask *) headContainer;

/**
 *  获取指定Object信息
 *
 *  @param request 指定的object信息
 *
 *  @return BFTask实例,成功的话，BFTask.result包含CSSPHeadObjectOutput实例
 */
- (BFTask *) headObject:(CSSPHeadObjectRequest *)request;

/**
 *  列举出当前Container中包含的所有Object
 *
 *  @param request 列举Objects时的各种过滤参数
 *
 *  @return BFTask实例,成功的话，BFTask.result包含CSSPListObjectsOutput实例，包含符合条件的object实例
 */
- (BFTask *) listObjects:(CSSPListObjectsRequest *)request;

/**
 *  列举当前已上传的分块
 *
 *  @param request 分块上传的相关信息
 *
 *  @return BFTask实例,成功的话，BFTask.result包含CSSPListMultipartUploadsOutput实例
 */
- (BFTask *) listMultipartUploads:(CSSPListMultipartUploadsRequest *)request;

/**
 *  上传Object
 *
 *  @param request 需要上传的object信息
 *
 *  @return BFTask实例,成功的话，BFTask.result包含CSSPPutObjectOutput实例
 */
- (BFTask *) putObject:(CSSPPutObjectRequest *)request;

/**
 *  从其他Contaner拷贝object到当前Container
 *
 *  @param request 拷贝object的相关参数
 *
 *  @return BFTask实例,成功的话，BFTask.result包含CSSPReplicateObjectOutput实例
 */
- (BFTask *) replicateObject:(CSSPReplicateObjectRequest *)request;


/**
 *  上传分块数据
 *
 *  @param request 分块数据配置，包括块号、UploadID等
 *
 *  @return BFTask实例,成功的话，BFTask.result包含CSSPUploadPartOutput实例
 */
- (BFTask *) uploadPart:(CSSPUploadPartRequest *) request;

@end
