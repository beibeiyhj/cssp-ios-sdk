//
//  CSSPSynchronizedMutableDictionary.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/3.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSPSynchronizedMutableDictionary : NSObject
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;

- (void)conditionallySetObject:(id)anObject forKey:(id <NSCopying>)aKey;

- (NSArray *)allKeys;
@end
