//
//  HYNetworkGlobalParamFilter.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/12.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYNetworkGlobalParamFilter.h"

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
    return [HYNetworkGlobalParamFilter urlStringWithOriginUrlString:url appendParameters:_paramDic];
}

+ (NSString *)urlParametersStringFromParameters:(NSDictionary *)parameters
{
    NSMutableString *urlParametersString = [[NSMutableString alloc] initWithString:@""];
    if (parameters && parameters.count > 0)
    {
        for (NSString *key in parameters)
        {
            NSString *value = parameters[key];
            value = [NSString stringWithFormat:@"%@",value];
            [urlParametersString appendFormat:@"&%@=%@", key, value];
        }
    }
    return urlParametersString;
}

+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString
                          appendParameters:(NSDictionary *)parameters
{
    NSString *filteredUrl = originUrlString;
    NSString *paraUrlString = [self urlParametersStringFromParameters:parameters];
    if (paraUrlString && paraUrlString.length > 0)
    {
        if ([originUrlString rangeOfString:@"?"].location != NSNotFound)
        {
            filteredUrl = [filteredUrl stringByAppendingString:paraUrlString];
        }
        else
        {
            filteredUrl = [filteredUrl stringByAppendingFormat:@"?%@", [paraUrlString substringFromIndex:1]];
        }
        return filteredUrl;
    }
    else
    {
        return originUrlString;
    }
}


@end
