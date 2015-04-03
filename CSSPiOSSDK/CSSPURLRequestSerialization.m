//
//  CSSPJSONSerialization.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/7.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPURLRequestSerialization.h"
#import "CSSPLogging.h"
#import "CSSPCategory.h"
#import <Bolts/Bolts.h>

NSString *const CSSPValidationErrorDomain = @"com.iflycssp.CSSPValidationErrorDomain";

typedef NS_ENUM(NSInteger, CSSPValidationErrorType) {
    // CSSPJSON Validation related errors
    CSSPValidationUnknownError, // Unknown Error found during JSON Validation
    CSSPValidationUnexpectedParameter, // Unexpected Parameters found in HTTP Body
    CSSPValidationUnhandledType,
    CSSPValidationMissingRequiredParameter,
    CSSPValidationOutOfRangeParameter,
    CSSPValidationInvalidStringParameter,
    CSSPValidationUnexpectedStringParameter,
    CSSPValidationInvalidParameterType,
    CSSPValidationInvalidBase64Data,
    CSSPValidationHeaderTargetInvalid,
    CSSPValidationHeaderAPIActionIsUndefined,
    CSSPValidationHeaderDefinitionFileIsNotFound,
    CSSPValidationHeaderDefinitionFileIsEmpty,
    CSSPValidationHeaderAPIActionIsInvalid,
    CSSPValidationURIIsInvalid
};

static NSDictionary *errorCodeDictionary = nil;

@interface CSSPXMLRequestSerializer()

@property (nonatomic, strong) NSDictionary *serviceDefinitionJSON;
@property (nonatomic, strong) NSString *actionName;

@end

@implementation CSSPXMLRequestSerializer

+ (instancetype)serializerWithResource:(NSString *)resource actionName:(NSString *)actionName {
    
    CSSPXMLRequestSerializer *serializer = [self new];
    NSError *error = nil;
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:resource ofType:@"json"];
    if (filePath == nil) {
        CSSPLogError(@"can not find %@.json file in the project",resource);
    } else {
        serializer.serviceDefinitionJSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath]
                                                                           options:kNilOptions
                                                                             error:&error];
    }
    if (error) {
        CSSPLogError(@"Error: [%@]", error);
    }
    
    serializer.actionName = actionName;
    
    return serializer;
}

/* need to overwrite this method to do serialization for self.parameter */
- (BFTask *)serializeRequest:(NSMutableURLRequest *)request
                     headers:(NSDictionary *)headers
                  parameters:(NSDictionary *)parameters {
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSDictionary *anActionRules = [[self.serviceDefinitionJSON objectForKey:@"operations"] objectForKey:self.actionName];
    
    NSDictionary *actionHTTPRule = [anActionRules objectForKey:@"http"];
    //Construct HTTPMethod
    NSString *ruleHTTPMethod = [actionHTTPRule objectForKey:@"method"];
    if ([ruleHTTPMethod length] > 0) {
        request.HTTPMethod = ruleHTTPMethod;
    }
    
    //Construct URI and Headers and HTTPBodyStream
    NSString *ruleURIStr = [actionHTTPRule objectForKey:@"requestUri"];
    NSDictionary *shapeRules = [self.serviceDefinitionJSON objectForKey:@"shapes"];
    CSSPJSONDictionary *inputRules = [[CSSPJSONDictionary alloc] initWithDictionary:[anActionRules objectForKey:@"input"] JSONDefinitionRule:shapeRules];
    
    NSError *error = nil;
    [CSSPXMLRequestSerializer constructURIandHeadersAndBody:request
                                                     rules:inputRules
                                                parameters:parameters
                                                 uriSchema:ruleURIStr
                                                     error:&error];
    
    if (!error) {
        //construct HTTPBody only if HTTPBodyStream is nil
        if (!request.HTTPBodyStream) {
            request.HTTPBody = [CSSPXMLBuilder xmlDataForDictionary:parameters
                                                        actionName:self.actionName
                                             serviceDefinitionRule:self.serviceDefinitionJSON
                                                             error:&error];
        }
        CSSPLogVerbose(@"Request body: [%@]", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
        
        //contruct addtional headers
        if (!error) {
            if (headers) {
                //generate HTTP header here
                for (NSString *key in headers.allKeys) {
                    [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
                }
            }
        }
    }
  
    if (error) {
        return [BFTask taskWithError:error];
    } else {
        return [BFTask taskWithResult:nil];
    }
}

- (BFTask *)validateRequest:(NSURLRequest *)request {
    return [BFTask taskWithResult:nil];
}

+ (BOOL)constructURIandHeadersAndBody:(NSMutableURLRequest *)request
                                rules:(CSSPJSONDictionary *)rules parameters:(NSDictionary *)params
                            uriSchema:(NSString *)uriSchema
                                error:(NSError *__autoreleasing *)error {
    //If no rule just return
    if (rules == (id)[NSNull null] ||  [rules count] == 0) {
        return YES;
    }
    
    NSMutableDictionary *queryStringDictionary = [NSMutableDictionary new];
    
    rules = rules[@"members"] ? rules[@"members"] : @{};
    
    __block NSString *rawURI = uriSchema;
    [rules enumerateKeysAndObjectsUsingBlock:^(NSString *memberName, id memberRules, BOOL *stop) {
        
        NSString *xmlElementName = memberRules[@"locationName"]?memberRules[@"locationName"]:memberName;
        id value = nil;
        if (memberRules[@"locationName"]) {
            value = params[memberRules[@"locationName"]];
        }
        if (!value) {
            value = params[memberName];
        }
        
        if (value && value != [NSNull null] && [memberRules isKindOfClass:[NSDictionary class]]) {
            
            NSString *rulesType = memberRules[@"type"];
            NSString *valueStr = nil;
            
            if ([rulesType isEqualToString:@"integer"] || [rulesType isEqualToString:@"long"] || [rulesType isEqualToString:@"float"] || [rulesType isEqualToString:@"double"]) {
                valueStr = [value stringValue];
                
            } else if ([rulesType isEqualToString:@"boolean"]) {
                valueStr = [value boolValue]?@"true":@"false";
            } else if ([rulesType isEqualToString:@"string"]) {
                valueStr = value;
            } else if ([rulesType isEqualToString:@"timestamp"]) {
                valueStr = value; //timestamp will be treated as string here.
            } else {
                valueStr = @"";
            }
            
            //If it is headers type, add to headers
            if ([memberRules[@"location"] isEqualToString:@"header"]) {
                
                [request addValue:valueStr forHTTPHeaderField:memberRules[@"locationName"]];
            }
            
            //if it is a map type with headers tag, add to headers
            if ([value isKindOfClass:[NSDictionary class]] && [rulesType isEqualToString:@"map"] && [memberRules[@"location"] isEqualToString:@"headers"] ) {
                for (NSString *key in value) {
                    NSString *keyName = [memberRules[@"locationName"] stringByAppendingString:key];
                    [request addValue:value[key] forHTTPHeaderField:keyName];
                }
            }
            
            //If it is uri type, construct uri
            if ([memberRules[@"location"] isEqualToString:@"uri"]) {
                NSString *keyToFind = [NSString stringWithFormat:@"{%@}", xmlElementName];
                NSString *greedyKeyToFind = [NSString stringWithFormat:@"{%@+}", xmlElementName];
                
                if ([rawURI rangeOfString:keyToFind].location != NSNotFound) {
                    rawURI = [rawURI stringByReplacingOccurrencesOfString:keyToFind
                                                               withString:[valueStr cssp_stringWithURLEncoding]];
                    
                } else if ([rawURI rangeOfString:greedyKeyToFind].location != NSNotFound) {
                    rawURI = [rawURI stringByReplacingOccurrencesOfString:greedyKeyToFind
                                                               withString:[valueStr cssp_stringWithURLEncodingPath]];
                }
                
                
            }
            
            //if it is queryString type, construct queryString
            if ([memberRules[@"location"] isEqualToString:@"querystring"]) {
                [queryStringDictionary setObject:valueStr forKey:memberRules[@"locationName"]];
            }
            
            //If it is "Body" Type and streaming Type, contructBody
            if ([xmlElementName isEqualToString:@"Body"] && [memberRules[@"streaming"] boolValue]) {
                if ([value isKindOfClass:[NSURL class]]) {
                    if ([value checkResourceIsReachableAndReturnError:error]) {
                        request.HTTPBodyStream = [NSInputStream inputStreamWithURL:value];
                    }
                    
                } else {
                    request.HTTPBodyStream = [NSInputStream inputStreamWithData:value];
                    
                }
                
            }
        }
    }];
    
    [queryStringDictionary setObject:@"xml" forKey:@"format"];
    
    if (*error) {
        return NO;
    }
    
    BOOL uriSchemaContainsQuestionMark = NO;
    NSRange hasQuestionMark = [uriSchema rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]];
    if (hasQuestionMark.location != NSNotFound) {
        uriSchemaContainsQuestionMark = YES;
    }
    
    if ([queryStringDictionary count]) {
        NSArray *myKeys = [queryStringDictionary allKeys];
        NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSString *queryString = @"";
        for (NSString *key in sortedKeys) {
            if ([queryString length] == 0 && uriSchemaContainsQuestionMark == NO) {
                queryString = [NSString stringWithFormat:@"?%@=%@",[key cssp_stringWithURLEncoding],[queryStringDictionary[key] cssp_stringWithURLEncoding]];
            } else {
                NSString *appendString = [NSString stringWithFormat:@"&%@=%@",[key cssp_stringWithURLEncoding],[queryStringDictionary[key] cssp_stringWithURLEncoding]];
                queryString = [queryString stringByAppendingString:appendString];
            }
        }
        rawURI = [rawURI stringByAppendingString:queryString];
    }
    
    //removed unused query key
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{.*?\\}" options:NSRegularExpressionCaseInsensitive error:nil];
    rawURI = [regex stringByReplacingMatchesInString:rawURI options:0 range:NSMakeRange(0, [rawURI length]) withTemplate:@""];
    
    //validate URL
    NSRange r = [rawURI rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    if (r.location != NSNotFound) {
        if (error) {
            *error = [NSError errorWithDomain:CSSPValidationErrorDomain code:CSSPValidationURIIsInvalid userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"the constructed request queryString is invalid:%@",rawURI] forKey:NSLocalizedDescriptionKey]];
        }
        request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/", request.URL]];
        
        return NO;
    } else {
        // fix query string
        // @"?location" -> @"?location="
        
        NSRange hasQuestionMark = [rawURI rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]];
        NSRange hasEqualMark = [rawURI rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
        if ( (hasQuestionMark.location != NSNotFound) && (hasEqualMark.location == NSNotFound) ) {
            rawURI = [rawURI stringByAppendingString:@"="];
        }
        
        NSString *finalURL = [NSString stringWithFormat:@"%@%@", request.URL,rawURI];
        request.URL = [NSURL URLWithString:finalURL];
        if (!request.URL) {
            if (error) {
                *error = [NSError errorWithDomain:CSSPValidationErrorDomain code:CSSPValidationURIIsInvalid userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"unable the assigned URL to request, URL may be invalid:%@",finalURL] forKey:NSLocalizedDescriptionKey]];
            }
            return NO;
        }
        
        return YES;
    }
}

@end
