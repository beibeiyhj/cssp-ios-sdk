//
//  CSSPModel.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/2.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "Mantle.h"

@interface CSSPModel : MTLModel <MTLJSONSerializing>

@end

@interface CSSPModelUtility : NSObject

+ (NSDictionary *)mapMTLDictionaryFromJSONArrayDictionary:(NSDictionary *)JSONArrayDictionary
                                         arrayElementType:(NSString *)arrayElementType
                                           withModelClass:(Class)modelClass;
+ (NSDictionary *)JSONArrayDictionaryFromMapMTLDictionary:(NSDictionary *)mapMTLDictionary
                                         arrayElementType:(NSString *)arrayElementType;

+ (NSArray *)mapMTLArrayFromJSONArray:(NSArray *)JSONArray
                       withModelClass:(Class)modelClass;
+ (NSArray *)JSONArrayFromMapMTLArray:(NSArray *)mapMTLArray;

+ (NSDictionary *)mapMTLDictionaryFromJSONDictionary:(NSDictionary *)JSONDictionary
                                      withModelClass:(Class)modelClass;
+ (NSDictionary *)JSONDictionaryFromMapMTLDictionary:(NSDictionary *)mapMTLDictionary;

@end