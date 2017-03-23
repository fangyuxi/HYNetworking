//
//  HYNetworkDefaultServer.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/12.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYNetworkDefaultServer.h"

@implementation HYNetworkDefaultServer

- (NSString *)host
{
    if (self.isOnline)
    {
        if (self.isVerify)
        {
            return @"";
        }
        return @"https://app.58.com";
    }
    else
    {
        if (self.isVerify)
        {
            return @"";
        }
        return @"";
    }
    return @"";
}

- (NSString *)serverName
{
    return @"沙箱";
}

@end
