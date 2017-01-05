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
    return @"/api/list/jianzhi?&geotype=baidu&ct=filter&curVer=7.6.0&appId=1&filterParams=&isNeedAd=0&action=getListInfo%2CgetFilterInfo&location=1%2C1142%2C7551&format=json&os=ios&tabkey=allcity&localname=bj&page=1&v=1&isBigPage=1";
    
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
