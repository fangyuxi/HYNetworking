//
//  HYNetworkServer.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/12.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYNetworkServer.h"

@implementation HYNetworkServer

@synthesize online = _online;
@synthesize verify = _verify;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        return self;
    }
    return nil;
}

- (NSString *)serverName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)host
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
