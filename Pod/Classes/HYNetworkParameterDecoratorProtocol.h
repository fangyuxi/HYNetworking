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

@protocol HYNetworkParameterDecoratorProtocol <NSObject>

@required

// in
@property (nonatomic, copy)NSString *inUrl;
@property (nonatomic, strong)HYBaseRequest *request;

// out
@property (nonatomic, copy, readonly)NSString *outUrl;
@property (nonatomic, strong, readonly)NSDictionary *parameterDic;

- (NSString *)decorate;

@end

