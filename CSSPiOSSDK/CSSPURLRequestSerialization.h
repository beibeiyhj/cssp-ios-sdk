//
//  CSSPJSONSerialization.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/7.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSPNetworking.h"
#import "CSSPSerialization.h"

@interface CSSPXMLRequestSerializer : NSObject <CSSPURLRequestSerializer>

+ (instancetype)serializerWithResource:(NSString *)resource
                            actionName:(NSString *)actionName;

+ (BOOL)constructURIandHeadersAndBody:(NSMutableURLRequest *)request
                                rules:(CSSPJSONDictionary *)rules parameters:(NSDictionary *)params
                            uriSchema:(NSString *)uriSchema
                                error:(NSError *__autoreleasing *)error;
@end


