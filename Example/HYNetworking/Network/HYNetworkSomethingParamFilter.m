//
//  HYNetworkSomethingParamFilter.m
//  HYNetworking
//
//  Created by fangyuxi on 16/5/30.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYNetworkSomethingParamFilter.h"
#import "HYTools.h"

@implementation HYNetworkSomethingParamFilter{
    
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
        _paramDic = @{@"s":@"a",
                      @"s2":@"1"};
        return self;
    }
    return nil;
}

- (NSString *)businessId{
    return @"jainzhi";
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
