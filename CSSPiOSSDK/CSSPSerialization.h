//
//  CSSPSerialization.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/7.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSPNetworking.h"

//defined domain for errors from CSSPRuntime.
FOUNDATION_EXPORT NSString *const CSSPJSONBuilderErrorDomain;

/* NSError codes in CSSPErrorDomain. */
typedef NS_ENUM(NSInteger, CSSPJSONBuilderErrorType) {
    CSSPJSONBuilderUnknownError,
    CSSPJSONBuilderDefinitionFileIsEmpty,
    CSSPJSONBuilderUndefinedActionRule,
    CSSPJSONBuilderInternalError,
    CSSPJSONBuilderInvalidParameter,
};

//defined domain for errors from CSSPRuntime.
FOUNDATION_EXPORT NSString *const CSSPJSONParserErrorDomain;

/* NSError codes in CSSPErrorDomain. */
typedef NS_ENUM(NSInteger, CSSPJSONParserErrorType) {
    CSSPJSONParserUnknownError,
    CSSPJSONParserDefinitionFileIsEmpty,
    CSSPJSONParserUndefinedActionRule,
    CSSPJSONParserInternalError,
    CSSPJSONParserInvalidParameter,
};


// defined domain for errors from CSSPRuntime.
FOUNDATION_EXPORT NSString *const CSSPXMLBuilderErrorDomain;

/* NSError codes in CSSPErrorDomain. */
typedef NS_ENUM(NSInteger, CSSPXMLBuilderErrorType) {
    // CSSPJSON Validation related errors
    CSSPXMLBuilderUnknownError = 900, // Unknown Error found
    CSSPXMLBuilderDefinitionFileIsEmpty = 901,
    CSSPXMLBuilderUndefinedXMLNamespace = 902,
    CSSPXMLBuilderUndefinedActionRule = 903,
    CSSPXMLBuilderMissingRequiredXMLElements = 904,
    CSSPXMLBuilderInvalidXMLValue = 905,
    CSSPXMLBuilderUnCatchedRuleTypeInDifinitionFile = 906,
};

// defined domain for errors from CSSPRuntime.
FOUNDATION_EXPORT NSString *const CSSPXMLParserErrorDomain;

/* NSError codes in CSSPErrorDomain. */
typedef NS_ENUM(NSInteger, CSSPXMLParserErrorType) {
    // CSSPJSON Validation related errors
    CSSPXMLParserUnknownError, // Unknown Error found
    CSSPXMLParserNoTypeDefinitionInRule, // Unknown Type in JSON Definition (rules) file
    CSSPXMLParserUnHandledType, //Unhandled Type
    CSSPXMLParserUnExpectedType, //Unexpected type
    CSSPXMLParserDefinitionFileIsEmpty, //the rule is empty.
    CSSPXMLParserUnexpectedXMLElement,
    CSSPXMLParserXMLNameNotFoundInDefinition, //can not find the 'xmlname' key in definition file for unflattened xml list
    CSSPXMLParserMissingRequiredXMLElements,
    CSSPXMLParserInvalidXMLValue,
};


@interface CSSPJSONDictionary : NSDictionary

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary
                JSONDefinitionRule:(NSDictionary *)rule;
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;

@end

@interface CSSPJSONBuilder : NSObject

+ (NSData *)jsonDataForDictionary:(NSDictionary *)params
                       actionName:(NSString *)actionName
            serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                            error:(NSError *__autoreleasing *)error;

@end

@interface CSSPJSONParser : NSObject

+ (NSDictionary *)dictionaryForJsonData:(NSData *)data
                             actionName:(NSString *)actionName
                  serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                                  error:(NSError *__autoreleasing *)error;

@end

@interface CSSPXMLBuilder : NSObject

+ (NSData *)xmlDataForDictionary:(NSDictionary *)params
                      actionName:(NSString *)actionName
           serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                           error:(NSError *__autoreleasing *)error;

+ (NSString *)xmlStringForDictionary:(NSDictionary *)params
                          actionName:(NSString *)actionName
               serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                               error:(NSError *__autoreleasing *)error;

@end

