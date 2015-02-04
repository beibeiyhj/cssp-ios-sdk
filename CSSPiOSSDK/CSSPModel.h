//
//  CSSPModel.h
//  CSSPiOSSDK
//
//  Created by dannis on 15/2/4.
//  Copyright (c) 2015年 cssp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSPRequest : NSObject

@end


@interface CSSPDeleteObjectRequest : CSSPRequest

@property (nonatomic, strong) NSString *object;

@end

@interface CSSPGetContainerAclRequest : CSSPRequest

@property (nonatomic, strong) NSString *container;

@end