//
//  CSSPModel.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/2.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPModel.h"

@implementation CSSPModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return nil;
}

- (NSDictionary *)dictionaryValue {
    NSDictionary *dictionaryValue = [super dictionaryValue];
    NSMutableDictionary *mutableDictionaryValue = [dictionaryValue mutableCopy];
    
    [dictionaryValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([self valueForKey:key] == nil) {
            [mutableDictionaryValue removeObjectForKey:key];
        }
    }];
    
    return mutableDictionaryValue;
}
@end

@implementation CSSPModelUtility
+ (NSDictionary *)mapMTLDictionaryFromJSONArrayDictionary:(NSDictionary *)JSONArrayDictionary arrayElementType:(NSString *)arrayElementType withModelClass:(Class) modelClass {
    
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
    for (NSString *key in [JSONArrayDictionary allKeys]) {
        if ([arrayElementType isEqualToString:@"map"]) {
            [mutableDictionary setObject:[CSSPModelUtility mapMTLArrayFromJSONArray:JSONArrayDictionary[key] withModelClass:modelClass] forKey:key];
        } else if  ([arrayElementType isEqualToString:@"structure"]) {
            NSValueTransformer *valueFransformer =  [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[modelClass class]];
            [mutableDictionary setObject:[valueFransformer transformedValue:JSONArrayDictionary[key]] forKey:key];
        }
    }
    return mutableDictionary;
}

+ (NSDictionary *)JSONArrayDictionaryFromMapMTLDictionary:(NSDictionary *)mapMTLDictionary arrayElementType:(NSString *)arrayElementType{
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
    for (NSString *key in [mapMTLDictionary allKeys]) {
        if ([arrayElementType isEqualToString:@"map"]) {
            [mutableDictionary setObject:[CSSPModelUtility JSONArrayFromMapMTLArray:mapMTLDictionary[key]] forKey:key];
        } else if ([arrayElementType isEqualToString:@"structure"]) {
            NSValueTransformer *valueFransformer = [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CSSPModel class]];
            [mutableDictionary setObject:[valueFransformer reverseTransformedValue:mapMTLDictionary[key]] forKey:key];
        }
    }
    return mutableDictionary;
}

//Forward transformation For Array of Map Type
+ (NSArray *)mapMTLArrayFromJSONArray:(NSArray *)JSONArray withModelClass:(Class)modelClass {
    NSMutableArray *mutableArray = [NSMutableArray new];
    for (NSDictionary *aDic in JSONArray) {
        NSDictionary *tmpDic = [CSSPModelUtility mapMTLDictionaryFromJSONDictionary:aDic withModelClass:[modelClass class]];
        [mutableArray addObject:tmpDic];
    };
    return mutableArray;
}

//Reverse transform for Array of Map Type
+ (NSArray *)JSONArrayFromMapMTLArray:(NSArray *)mapMTLArray {
    NSMutableArray *mutableArray = [NSMutableArray new];
    for (NSDictionary *aDic in mapMTLArray) {
        NSDictionary *tmpDic = [CSSPModelUtility JSONDictionaryFromMapMTLDictionary:aDic];
        [mutableArray addObject:tmpDic];
    };
    return mutableArray;
}

//Forward transformation for JSONDefinition Map Type
+ (NSDictionary *)mapMTLDictionaryFromJSONDictionary:(NSDictionary *)JSONDictionary withModelClass:(Class)modelClass {
    
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
    for (NSString *key in [JSONDictionary allKeys]) {
        [mutableDictionary setObject:[MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:JSONDictionary[key] error:nil] forKey:key];
    }
    return mutableDictionary;
}

//Reverse transfrom for JSONDefinition Map Type
+ (NSDictionary *)JSONDictionaryFromMapMTLDictionary:(NSDictionary *)mapMTLDictionary {
    
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
    for (NSString *key in [mapMTLDictionary allKeys]) {
        [mutableDictionary setObject:[MTLJSONAdapter JSONDictionaryFromModel:[mapMTLDictionary objectForKey:key]]
                              forKey:key];
    }
    return mutableDictionary;
}

@end
