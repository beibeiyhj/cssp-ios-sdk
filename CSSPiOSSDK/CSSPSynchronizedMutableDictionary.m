//
//  CSSPSynchronizedMutableDictionary.m
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/5.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import "CSSPSynchronizedMutableDictionary.h"

@interface CSSPSynchronizedMutableDictionary()

@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@end

@implementation CSSPSynchronizedMutableDictionary

- (instancetype)init {
    if (self = [super init]) {
        _dictionary = [NSMutableDictionary new];
        _dispatchQueue = dispatch_queue_create("com.CSSP.CSSPSynchronizedMutableDictionary", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (id)objectForKey:(id)aKey {
    __block id returnObject = nil;
    
    dispatch_sync(self.dispatchQueue, ^{
        returnObject = [self.dictionary objectForKey:aKey];
    });
    
    return returnObject;
}

- (void)removeObjectForKey:(id)aKey {
    dispatch_sync(self.dispatchQueue, ^{
        [self.dictionary removeObjectForKey:aKey];
    });
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    dispatch_sync(self.dispatchQueue, ^{
        [self.dictionary setObject:anObject forKey:aKey];
    });
}

- (void)conditionallySetObject:(id)anObject forKey:(id <NSCopying>)aKey {
    dispatch_sync(self.dispatchQueue, ^{
        if (![self.dictionary objectForKey:aKey]) {
            [self.dictionary setObject:anObject forKey:aKey];
        }
    });
}

- (NSArray *)allKeys {
    __block NSArray *allKeys = nil;
    dispatch_sync(self.dispatchQueue, ^{
        allKeys = [self.dictionary allKeys];
    });
    return allKeys;
}


@end
