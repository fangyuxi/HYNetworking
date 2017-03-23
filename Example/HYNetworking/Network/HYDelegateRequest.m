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

- (NSString *)api
{
    return @"";
    
}

- (NSString *)identifier
{
    return @"delegate";
}

- (id)responseDataValidator
{
    return nil;
}

- (id)requestArgument
{
    return nil;
}

- (HYRequestCachePolicy)cachePolicy
{
    return HYRequestCachePolicyNeverUseCache;
}

- (NSTimeInterval)cacheMaxAge
{
    return 60 * 60;
}

@end
