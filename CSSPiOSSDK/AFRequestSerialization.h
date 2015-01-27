//
//  AFRequestSerialization.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/1/27.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "AFURLRequestSerialization.h"

@interface AFRequestSerialization : AFHTTPRequestSerializer

/**
 The CSSP bucket for the client, `nil` by default
**/
@property (nonatomic, copy) NSString *bucket;

/**
 The CSSP region for the client, `AFCSSPHFRegion` by default. Must not `nil`
**/
@property (nonatomic, copy) NSString *region;

/**
 Weather to connect by HTTPS, 'NO' by default
**/

@property (nonatomic, assign) BOOL useSSL;

/**
 *  Sets the access key ID and secret, used to generate authorization headers.
 *
 *  @param accessKey The Access Key ID
 *  @param secret    The Access Key Secret
 */
- (void) setAccessKeyID: (NSString *) accessKey
                 secret: (NSString *) secret;

/**
 *  Returns a request with the necessary authorization HTTP header fields from the specified request using the provided credentials.
 *
 *  @param request The request
 *  @param error   The error that occured while constructing the request
 *
 *  @return The request with necessary `Authorization` and `Date` HTTP header fields.
 */
- (NSURLRequest *)requestBySettingAuthorizationHeadersForRequest:(NSURLRequest *)request
                                                           error:(NSError * __autoreleasing *)error;

@end
