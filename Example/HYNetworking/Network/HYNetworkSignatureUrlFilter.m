//
//  HYNetworkSignatureUrlFilter.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/13.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYNetworkSignatureUrlFilter.h"

@implementation HYNetworkSignatureUrlFilter{

    NSDictionary *_signDic;

}

- (NSString *)filterUrl:(NSString *)url withRequest:(HYBaseRequest *)request
{
    return [HYNetworkSignatureUrlFilter urlStringWithOriginUrlString:url appendParameters:_signDic];
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
