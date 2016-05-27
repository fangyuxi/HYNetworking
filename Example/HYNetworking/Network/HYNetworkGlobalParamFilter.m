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
                      @"platform":@"ios",
                      @"sign":@"A6B3AB44CBB0DC267E73ADD165F7AC9F8975BDD4"};
        return self;
    }
    return nil;
}

- (NSString *)filterUrl:(NSString *)url withRequest:(HYBaseRequest *)request
{
    return [HYTools urlStringWithOriginUrlString:url appendParameters:_paramDic];
}


- (NSDictionary *)paramDictionary
{
    return _paramDic;
}

@end
