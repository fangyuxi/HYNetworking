//
//  HYNetworkGlobalParamFilter.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/12.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYNetworkGlobalParamFilter.h"
#import "HYTools.h"

@implementation HYNetworkGlobalParamFilter{

    NSDictionary *_paramDic;

}

@synthesize outUrl = _outUrl;
@synthesize inUrl = _inUrl;
@synthesize inRequest = _inRequest;
@synthesize outParameterDic = _outParameterDic;
@synthesize inParameterDic = _inParameterDic;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _paramDic = @{@"v":@"1.0",
                      @"categoryListVersion":@"1",
                      @"currentVersion":@"10245",
                      @"appKey":@"76532",
                      @"loginTocken":@"7c7aa549e86a3ac29573a442fb0d7b13",
                      @"appVersion":@"10245",
                      @"platform":@"ios"};
        return self;
    }
    return nil;
}

- (NSString *)businessId{
    return @"core";
}

- (NSString *)outUrl
{
    return [HYTools urlStringWithOriginUrlString:self.inUrl appendParameters:[self outParameterDic]];
}

- (void)setInParameterDic:(NSDictionary *)inParameterDic
{
    _inParameterDic = inParameterDic;
}

- (NSDictionary *)inParameterDic
{
    return _inParameterDic;
}

- (NSDictionary *)outParameterDic
{
    return _paramDic;
}

@end





