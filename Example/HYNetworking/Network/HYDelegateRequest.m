//
//  HYDelegateRequest.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/12.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYDelegateRequest.h"

@implementation HYDelegateRequest

- (HYRequestMethod)requestMethod
{
    return HYRequestMethodGet;
}

- (NSString *)apiUrl
{
    return @"/api/system?method=initApp";
}

- (NSString *)name
{
    return @"delegate";
}

- (id)responseDataValidator
{
    return @{@"result":
                 @{@"data":
                     @{@"appParamVersionVO":
                            @{@"cateVersion":[NSNumber class]}}}};
}

- (id)requestArgument
{
    return @{@"test":@"fangyuxi"};
}

@end
