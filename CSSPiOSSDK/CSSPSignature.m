//
//  CSSPSignature.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/6.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPSignature.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "CSSPCredentialsProvider.h"
#import "CSSPCategory.h"
#import "CSSPLogging.h"
#import "Bolts.h"

@implementation CSSPSignatureSignerUtility

+(NSData *)sha256HMacWithData:(NSData *)data withKey:(NSData *)key{
    CCHmacContext context;
    
    CCHmacInit(&context, kCCHmacAlgSHA256, [key bytes], [key length]);
    CCHmacUpdate(&context, [data bytes], [data length]);
    
    unsigned char digestRaw[CC_SHA256_DIGEST_LENGTH];
    NSInteger digestLength = CC_SHA256_DIGEST_LENGTH;
    
    CCHmacFinal(&context, digestRaw);
    
    return [NSData dataWithBytes:digestRaw length:digestLength];
}

+(NSString *)hashString:(NSString *)stringToHash{
    return [[NSString alloc] initWithData:[self hash:[stringToHash dataUsingEncoding:NSUTF8StringEncoding]]
                                 encoding:NSASCIIStringEncoding];
}

+(NSData *)hash:(NSData *)dataToHash{
    if ([dataToHash length] > UINT32_MAX) {
        return nil;
    }
    
    const void *cStr = [dataToHash bytes];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(cStr, (uint32_t)[dataToHash length], result);
    
    return [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];

}

+(NSString *)hexEncode:(NSString *)string{
    NSUInteger len = [string length];
    unichar *chars = malloc(len * sizeof(unichar));
    
    [string getCharacters:chars];
    
    NSMutableString *hexString = [NSMutableString new];
    for (NSUInteger i = 0; i < len; i++) {
        if ((int)chars[i] < 16) {
            [hexString appendString:@"0"];
        }
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }
    free(chars);
    
    return hexString;
}

+(NSString *)HMACSign:(NSData *)data withKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm{
    CCHmacContext context;
    const char    *keyCString = [key cStringUsingEncoding:NSASCIIStringEncoding];
    
    CCHmacInit(&context, algorithm, keyCString, strlen(keyCString));
    CCHmacUpdate(&context, [data bytes], [data length]);
    
    // Both SHA1 and SHA256 will fit in here
    unsigned char digestRaw[CC_SHA256_DIGEST_LENGTH];
    
    NSInteger           digestLength;
    
    switch (algorithm) {
        case kCCHmacAlgSHA1:
            digestLength = CC_SHA1_DIGEST_LENGTH;
            break;
            
        case kCCHmacAlgSHA256:
            digestLength = CC_SHA256_DIGEST_LENGTH;
            break;
            
        default:
            digestLength = -1;
            break;
    }
    
    CCHmacFinal(&context, digestRaw);
    
    NSData *digestData = [NSData dataWithBytes:digestRaw length:digestLength];
    
    return [digestData base64EncodedStringWithOptions:kNilOptions];
}

@end


#pragma mask - CSSPSignatureSigner

@interface CSSPSignatureSigner()

@property (nonatomic, strong) id<CSSPCredentialsProvider> credentialsProvider;

@end

@implementation CSSPSignatureSigner

+(instancetype) signerWithCredentialsProvider:(id<CSSPCredentialsProvider>)credentialsProvider{
    CSSPSignatureSigner *signer = [[CSSPSignatureSigner alloc] initWithCredentialsProvider:credentialsProvider];
    return signer;
}

-(instancetype)initWithCredentialsProvider:(id<CSSPCredentialsProvider>)credentialsProvider{
    if (self = [super init]){
        _credentialsProvider = credentialsProvider;
    }
    
    return self;
}

-(BFTask *)interceptRequest:(NSMutableURLRequest *)request {
    return [[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
        [request setValue:nil forHTTPHeaderField:@"Authorization"];
        
        NSString *autorization = [self signRequest:request];
        
        if (autorization) {
            [request setValue:autorization forHTTPHeaderField:@"Authorization"];
        }
        return nil;
    }];
}

-(NSString *)signRequest :(NSMutableURLRequest *)request{
    NSString *gmtDate = [[NSDate date]cssp_stringValue:CSSPDateRFC822DateFormat1];
    NSMutableDictionary	*mutableHeaderFields = [NSMutableDictionary dictionary];
    [[request allHTTPHeaderFields]enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        key = [key lowercaseString];
        if ([key hasPrefix:@"x-object-meta"]){
            if ([mutableHeaderFields objectForKey:key]){
                obj = [[mutableHeaderFields objectForKey:key] stringByAppendingFormat:@",%@", obj];
            }
            [mutableHeaderFields setObject:obj forKey:key];
        }
    }];
    
    NSMutableString *mutableCanonicalizedHeaderString = [NSMutableString string];
    for (NSString *key in [[mutableHeaderFields allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        id obj = [mutableHeaderFields objectForKey: key];
        [mutableCanonicalizedHeaderString appendFormat:@"%@:%@\n", key,obj];
    }
    
    NSString *canonicalizedResource = request.URL.path;
    NSString *method = [request HTTPMethod];
    NSString *contentMD5 = [request valueForHTTPHeaderField:@"Content-MD5"];
    NSString *contentType = [request valueForHTTPHeaderField:@"Content-Type"];
    
    NSMutableString *mutableString = [NSMutableString string];
    [mutableString appendFormat:@"%@\n", method ? method : @""];
    [mutableString appendFormat:@"%@\n", contentMD5 ? contentMD5 : @""];
    [mutableString appendFormat:@"%@\n", contentType ? contentType : @""];
    [mutableString appendFormat:@"%@\n", gmtDate ? gmtDate : @""];
    [mutableString appendFormat:@"%@", mutableCanonicalizedHeaderString];
    [mutableString appendFormat:@"%@", canonicalizedResource];
    

    NSString *signature = [NSString stringWithFormat:@"CSSP %@:%@",
                           self.credentialsProvider.accessKey,
                           [CSSPSignatureSignerUtility HMACSign:[mutableString dataUsingEncoding:NSUTF8StringEncoding]
                                                       withKey:self.credentialsProvider.secretKey
                                                usingAlgorithm:kCCHmacAlgSHA1]];
    
    [request setValue:[NSString stringWithFormat:@"CSSP %@:%@", self.credentialsProvider.accessKey, signature] forHTTPHeaderField:@"Authorization"];
    
    [request setValue:gmtDate ? gmtDate : @"" forHTTPHeaderField:@"Date"];
    
    return signature;
}
@end
