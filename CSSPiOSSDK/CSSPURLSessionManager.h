//
//  CSSPURLSessionManager.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/5.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSPNetworking.h"

@interface CSSPURLSessionManager : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) CSSPNetworkingConfiguration *configuration;

- (void)dataTaskWithRequest:(CSSPNetworkingRequest *)request
          completionHandler:(CSSPNetworkingCompletionHandlerBlock)completionHandler;

- (void)downloadTaskWithRequest:(CSSPNetworkingRequest *)request
              completionHandler:(CSSPNetworkingCompletionHandlerBlock)completionHandler;

- (void)uploadTaskWithRequest:(CSSPNetworkingRequest *)request
            completionHandler:(CSSPNetworkingCompletionHandlerBlock)completionHandler;

@end
