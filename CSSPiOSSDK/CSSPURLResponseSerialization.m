//
//  CSSPResponseSerialization.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/7.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPURLResponseSerialization.h"

#import "CSSPLogging.h"
#import "CSSPSerialization.h"

NSString *const CSSPGeneralErrorDomain = @"com.amazonaws.CSSPGeneralErrorDomain";

#pragma mark - Service errors

static NSDictionary *errorCodeDictionary = nil;

@interface CSSPXMLResponseSerializer()

@property (nonatomic, strong) NSDictionary *serviceDefinitionJSON;
@property (nonatomic, strong) NSString *actionName;

@end

@implementation CSSPXMLResponseSerializer

+ (void)initialize {
    errorCodeDictionary = @{
                            @"RequestTimeTooSkewed" : @(CSSPGeneralErrorRequestTimeTooSkewed),
                            @"InvalidSignatureException" : @(CSSPGeneralErrorInvalidSignatureException),
                            @"RequestExpired" : @(CSSPGeneralErrorRequestExpired),
                            @"SignatureDoesNotMatch" : @(CSSPGeneralErrorSignatureDoesNotMatch),
                            @"AuthFailure" : @(CSSPGeneralErrorAuthFailure),
                            };
}

+ (instancetype)serializerWithResource:(NSString *)resource
                            actionName:(NSString *)actionName
                           outputClass:(Class)outputClass {
    CSSPXMLResponseSerializer *serializer = [self new];
    
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
    serializer.outputClass = outputClass;
    
    return serializer;
}


- (BOOL)validateResponse:(NSHTTPURLResponse *)response
             fromRequest:(NSURLRequest *)request
                    data:(id)data
                   error:(NSError *__autoreleasing *)error {
    //Validation already performed during XML Parsing in CSSPXMLParser Class.
    return YES;
}

- (NSMutableDictionary *)parseResponseHeader:(NSDictionary *)responseHeaders
                                       rules:(CSSPJSONDictionary *)rules
                              bodyDictionary:(NSMutableDictionary *)bodyDictionary
                                       error:(NSError *__autoreleasing *)error {
    //If no rule just return
    if (rules == (id)[NSNull null] ||  [rules count] == 0) {
        return bodyDictionary;
    }
    
    rules = rules[@"members"] ? rules[@"members"] : @{};
    
    [rules enumerateKeysAndObjectsUsingBlock:^(NSString *memberName, id memberRules, BOOL *stop) {
        if ([memberRules isKindOfClass:[NSDictionary class]] && [memberRules[@"location"] isEqualToString:@"header"]) {
            NSString *locationName = memberRules[@"locationName"]?memberRules[@"locationName"]:memberName;
            if (locationName && responseHeaders[locationName]) {
                NSString *rulesType = memberRules[@"type"];
                if ([rulesType isEqualToString:@"integer"]) {
                    bodyDictionary[memberName] = @([responseHeaders[locationName] integerValue]);
                } else if ([rulesType isEqualToString:@"long"]) {
                    bodyDictionary[memberName] = @([responseHeaders[locationName] longValue]);
                } else if ([rulesType isEqualToString:@"float"]) {
                    bodyDictionary[memberName] = @([responseHeaders[locationName] floatValue]);
                } else if ([rulesType isEqualToString:@"double"]) {
                    bodyDictionary[memberName] = @([responseHeaders[locationName] doubleValue]);
                }else if ([rulesType isEqualToString:@"string"]) {
                    bodyDictionary[memberName] = responseHeaders[locationName];
                } else if ([rulesType isEqualToString:@"timestamp"]) {
                    bodyDictionary[memberName] = responseHeaders[locationName];
                }
            }
        }
        
        //if the location may contain multiple headers if it is a map type
        if ([memberRules isKindOfClass:[NSDictionary class]] && [memberRules[@"location"] isEqualToString:@"headers"] && [memberRules[@"type"] isEqualToString:@"map"] ) {
            NSString *locationName = memberRules[@"locationName"]?memberRules[@"locationName"]:memberName;
            if (locationName) {
                NSPredicate *metaDatapredicate = [NSPredicate predicateWithFormat:@"SELF like %@",[locationName stringByAppendingString:@"*"]];
                NSArray *matchedArray = [[responseHeaders allKeys] filteredArrayUsingPredicate:metaDatapredicate];
                NSMutableDictionary *mapDic = [NSMutableDictionary new];
                for (NSString *fullHeaderName in matchedArray) {
                    NSString *extractedHeaderName = [fullHeaderName stringByReplacingOccurrencesOfString:locationName withString:@""];
                    if (extractedHeaderName) {
                        mapDic[extractedHeaderName] = responseHeaders[fullHeaderName];
                    }
                }
                if ([mapDic count] > 0 && memberName) {
                    bodyDictionary[memberName] = mapDic;
                }
            }
        }
    }];
    
    return bodyDictionary;
}

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                originalRequest:(NSURLRequest *)originalRequest
                 currentRequest:(NSURLRequest *)currentRequest
                           data:(id)data
                          error:(NSError *__autoreleasing *)error {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        CSSPLogDebug(@"Response header: [%@]", response.allHeaderFields);
    }
    
    if ([data isKindOfClass:[NSData class]]) {
        CSSPLogVerbose(@"Response body: [%@]", [[NSString alloc] initWithData:data
                                                                    encoding:NSUTF8StringEncoding]);
    }
    
    NSString *responseContentTypeStr = [[response allHeaderFields] objectForKey:@"Content-Type"];
    if (responseContentTypeStr) {
        if ([responseContentTypeStr rangeOfString:@"text/html"].location != NSNotFound) {
            //found html response rather than xml format. should be an error.
            if (error) {
                NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                
                *error = [NSError errorWithDomain:CSSPGeneralErrorDomain
                                             code:CSSPGeneralErrorUnknown
                                         userInfo:@{NSLocalizedDescriptionKey : message?message:[NSNull null]}];
                return nil;
            }
        }
    }
    
    if (![self validateResponse:response fromRequest:currentRequest data:data error:error]) {
        return nil;
    }
    NSDictionary *anActionRules = [[self.serviceDefinitionJSON objectForKey:@"operations"] objectForKey:self.actionName];
    NSDictionary *shapeRules = [self.serviceDefinitionJSON objectForKey:@"shapes"];
    CSSPJSONDictionary *outputRules = [[CSSPJSONDictionary alloc] initWithDictionary:[anActionRules objectForKey:@"output"] JSONDefinitionRule:shapeRules];
    
    
    NSMutableDictionary *resultDic = [NSMutableDictionary new];
    
    if (response.statusCode >= 200 && response.statusCode < 300 ) {
        // status is good, we can keep NSURL as data
    } else {
        //if status error indicates error, need to convert NSURL to NSData for error processing
        if ([data isKindOfClass:[NSURL class]]) {
            data = [NSData dataWithContentsOfFile:[(NSURL *)data path]];
        }
    }
    
    if ([resultDic count] == 0) {
        //if not blob type, try to parse as XML string
        resultDic = [[CSSPXMLParser sharedInstance] dictionaryForXMLData:data
                                                             actionName:self.actionName
                                                  serviceDefinitionRule:self.serviceDefinitionJSON
                                                                  error:error];
    }
    
    //parse response header
    resultDic = [self parseResponseHeader:[response allHeaderFields] rules:outputRules bodyDictionary:resultDic error:error];
    
    //Parse CSSPGeneralError
    NSDictionary *errorInfo = resultDic[@"Error"];
    if (errorInfo) {
        if (errorInfo[@"Code"] && errorCodeDictionary[errorInfo[@"Code"]]) {
            if (error && (*error == nil)) {
                *error = [NSError errorWithDomain:CSSPGeneralErrorDomain
                                             code:[errorCodeDictionary[errorInfo[@"Code"]] integerValue]
                                         userInfo:errorInfo
                          ];
            }
        }
    }
    return resultDic;
}

@end

