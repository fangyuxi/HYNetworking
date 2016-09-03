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
    return @"/api/list/jianzhi";
}

- (NSString *)name
{
    return @"delegate";
}

- (id)responseDataValidator
{
    return nil;
}

- (id)requestArgument
{
    return @{@"v":@"1",
             @"os":@"android",
             @"curVer":@"7.2.5",
             @"appId":@"1",
             @"action":@"getBigMetaInfo",
             @"format":@"json",
             @"localname":@"bj"};
}

- (HYRequestCachePolicy)cachePolicy
{
    return HYRequestCachePolicyReadCacheOrRequest;
}

- (NSTimeInterval)cacheMaxAge
{
    return 60 * 60;
}

@end
