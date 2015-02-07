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

@interface CSSPJSONResponseSerializer()

@property (nonatomic, strong) NSDictionary *serviceDefinitionJSON;
@property (nonatomic, strong) NSString *actionName;

@end

@implementation CSSPJSONResponseSerializer

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
    CSSPJSONResponseSerializer *serializer = [self new];
    
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
            //found html response rather than json format. should be an error.
            if (error) {
                NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                
                *error = [NSError errorWithDomain:CSSPGeneralErrorDomain
                                             code:CSSPGeneralErrorUnknown
                                         userInfo:@{NSLocalizedDescriptionKey : message?message:[NSNull null]}];
                return nil;
            }
        }
    }
    
    if (!data) {
        return nil;
    }
    if (![self validateResponse:response
                    fromRequest:currentRequest
                           data:data
                          error:error]) {
        return nil;
    }
    
    id result = nil;
    
    if (data) {
        //parse JSON data
        result = [CSSPJSONParser dictionaryForJsonData:data actionName:self.actionName serviceDefinitionRule:self.serviceDefinitionJSON error:error];
        
        //Parse CSSPGeneralError
        if ([result isKindOfClass:[NSDictionary class]]) {
            if ([errorCodeDictionary objectForKey:[[[result objectForKey:@"__type"] componentsSeparatedByString:@"#"] lastObject]]) {
                if (error) {
                    *error = [NSError errorWithDomain:CSSPGeneralErrorDomain
                                                 code:[[errorCodeDictionary objectForKey:[[[result objectForKey:@"__type"] componentsSeparatedByString:@"#"] lastObject]] integerValue]
                                             userInfo:result];
                }
            }
        }
    }
    
    if (self.outputClass)
        result = [MTLJSONAdapter modelOfClass:self.outputClass
                           fromJSONDictionary:result
                                        error:error];
    
    return result;
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
             fromRequest:(NSURLRequest *)request
                    data:(id)data
                   error:(NSError *__autoreleasing *)error {
    return YES;
}

@end

