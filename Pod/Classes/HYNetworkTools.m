//
//  HYNetworkTools.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/8.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYNetworkTools.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HYNetworkTools

+ (BOOL)checkJson:(id)json
    withValidator:(id)validatorJson
       noMatchKey:(id)noMatchKey
{
    if ([json isKindOfClass:[NSDictionary class]] &&
        [validatorJson isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = json;
        NSDictionary *validator = validatorJson;
        BOOL result = YES;
        NSEnumerator *enumerator = [validator keyEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject]) != nil)
        {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]])
            {
                result = [self checkJson:value withValidator:format noMatchKey:noMatchKey];
                if (!result)
                {
                    break;
                }
            }
            else
            {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO)
                {
                    noMatchKey = [key copy];
                    result = NO;
                    break;
                }
            }
        }
        return result;
    }
    else if ([json isKindOfClass:[NSArray class]] && [validatorJson isKindOfClass:[NSArray class]])
    {
        NSArray *validatorArray = (NSArray *)validatorJson;
        if (validatorArray.count > 0)
        {
            NSArray *array = json;
            NSDictionary *validator = validatorJson[0];
            for (id item in array)
            {
                BOOL result = [self checkJson:item withValidator:validator noMatchKey:noMatchKey];
                if (!result)
                {
                    return NO;
                }
            }
        }
        return YES;
    }
    else if ([json isKindOfClass:validatorJson])
    {
        return YES;
    }
    else
    {
        return NO;
    }
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

+ (BOOL)HYNetworkIsEmptyString:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]])
    {
        return YES;
    }
    if (string == nil)
    {
        return YES;
    }
    if ([string length] == 0)
    {
        return YES;
    }
    return NO;
}

+ (NSString *)cacheKeyWithUrl:(NSString *)url
{
    const char *str = [url UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *key = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return key;
}

@end
