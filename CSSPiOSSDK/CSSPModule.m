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

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"container" : @"Container",
             @"object" : @"Object",
             @"uploadId" : @"UploadId",
             };

}

@end