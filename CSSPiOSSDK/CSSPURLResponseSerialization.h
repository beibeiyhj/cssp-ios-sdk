//
//  CSSPResponseSerialization.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/7.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSPNetworking.h"

typedef NS_ENUM(NSInteger, CSSPGeneralErrorType) {
    CSSPGeneralErrorUnknown,
    CSSPGeneralErrorRequestTimeTooSkewed,
    CSSPGeneralErrorInvalidSignatureException,
    CSSPGeneralErrorSignatureDoesNotMatch,
    CSSPGeneralErrorRequestExpired,
    CSSPGeneralErrorAuthFailure
};

@interface CSSPJSONResponseSerializer : NSObject <CSSPHTTPURLResponseSerializer>

@property (nonatomic, assign) Class outputClass;

+ (instancetype)serializerWithResource:(NSString *)resource
                            actionName:(NSString *)actionName
                           outputClass:(Class)outputClass;

@end