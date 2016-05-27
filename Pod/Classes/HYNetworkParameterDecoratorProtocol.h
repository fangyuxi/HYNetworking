//
//  HYNetworkUrlFilterProtocol.h
//  MyFirst
//
//  Created by fangyuxi on 16/3/8.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//


@class HYNetworkResponse;
@class HYBaseRequest;

/** 参数filter **/
//decorator
//parameter
@protocol HYNetworkParameterDecoratorProtocol <NSObject>

@required
- (NSString *)filterUrl:(NSString *)url withRequest:(HYBaseRequest *)request;
- (NSDictionary *)paramDictionary;

@end

