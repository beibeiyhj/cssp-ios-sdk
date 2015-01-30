//
//  CSSPSignature.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/27.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#include "AFURLRequestSerialization.h"


@interface CSSPRequestSerialization: AFHTTPRequestSerializer

@property (nonatomic, copy) NSString *bucket;
@property (nonatomic, copy) NSString *region;
@property (readonly, nonatomic, copy) NSString *endpointURL;


- (void) setAccessKeyID:(NSString *)accessKey
             withSecret:(NSString *)secretKey;
- (NSURLRequest *) requestBySettingAuthorizationHeadersForRequest:(NSURLRequest *) request
                                                            error:(NSError * __autoreleasing *)error;
@end


