//
//  HYNetworkDefaultServer.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/12.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYNetworkDefaultServer.h"

@implementation HYNetworkDefaultServer

@synthesize online = _online;

- (NSString *)host
{
    if (self.isOnline)
    {
        return @"https://app.58.com";
    }
    else
    {
        return @"";
    }
    return @"";
}

- (NSString *)serverName
{
    return @"沙箱";
}

@end
