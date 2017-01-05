//
//  HYBaseRequestInternal.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/8.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYBaseRequestInternal.h"
#import "HYNetworkLogger.h"
#import <objc/runtime.h>
#import "AFHTTPSessionManager+Download.h"
#import "HYNetworkDefines.h"
#import "HYNetworkConfig.h"

static HYBaseRequestInternal *sharedInstance = nil;

@implementation HYBaseRequestInternal{

    // shared manager
    AFHTTPSessionManager *_manager;
    // shared configer
    HYNetworkConfig *_networkConfig;
}


#pragma mark init

+ (HYBaseRequestInternal *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    

    return sharedInstance;
}

- (instancetype)init
{
    if (!sharedInstance)
    {
        sharedInstance = [super init];
        
        _manager = [AFHTTPSessionManager manager];
        _networkConfig = [HYNetworkConfig sharedInstance];
        
    }
    return sharedInstance;
}

#pragma mark send cancel

- (void)sendBatchRequest:(HYBatchRequests *)requests
{
    dispatch_group_t completeGroup = dispatch_group_create();
    [requests.requests enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        [[HYBaseRequestInternal sharedInstance] sendRequest:obj withCompleteGroup:completeGroup];
        
    }];
    
    dispatch_group_notify(completeGroup, dispatch_get_main_queue(), ^{
       
        if (requests.delegate) {
            [requests.delegate batchAPIRequestsDidFinished:requests];
        }
    });
}

- (void)sendRequest:(HYBaseRequest *)request
{
    [self sendRequest:request withCompleteGroup:nil];
}

- (void)sendRequest:(HYBaseRequest *)request
  withCompleteGroup:(nullable dispatch_group_t)completeGroup
{
    if (completeGroup) {
        dispatch_group_enter(completeGroup);
    }
    //请求方法
    HYRequestMethod method = [request requestMethod];
    
    NSAssert(method == HYRequestMethodGet ||
             method == HYRequestMethodPost
             //method == HYRequestMethodHead ||
             //method == HYRequestMethodPut ||
             //method == HYRequestMethodDelete ||
             //method == HYRequestMethodPatch
             ,@"Please Provide Legal Request Method");
    
    //请求url
    NSDictionary *filterParam = nil;
    NSMutableDictionary *finalParam = [NSMutableDictionary dictionary];
    
    NSString *url = [self p_buildFullUrlWithRequest:request param:&filterParam];
    
    //参数
    NSDictionary *argument = [request respondsToSelector:@selector(requestArgument)] ? [request requestArgument] : nil;
    
    if ([request requestMethod] == HYRequestMethodGet)
    {
         finalParam = [argument mutableCopy];
    }
    else
    {
        [finalParam addEntriesFromDictionary:filterParam];
        [finalParam addEntriesFromDictionary:argument];
    }
    
    //下载地址
    NSString *downloadPath = [request respondsToSelector:@selector(downloadPath)] ? [request downloadPath] : nil;
    
    //post body
    HYConstructingBlock constructingBlock = [request respondsToSelector:@selector(constructingBodyBlock)] ? [request constructingBodyBlock]: nil;
    
    //超时时间
    _manager.requestSerializer.timeoutInterval = [request respondsToSelector:@selector(requestTimeoutInterval)] ? [request requestTimeoutInterval] : KHYNetworkDefaultTimtout;
    
    //https 配置
    NSUInteger pinningMode                  = [HYNetworkConfig sharedInstance].securityPolicy.pinningMode;
    AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode:pinningMode];
    securityPolicy.allowInvalidCertificates = [HYNetworkConfig sharedInstance].securityPolicy.allowInvalidCertificates;
    securityPolicy.validatesDomainName      = [HYNetworkConfig sharedInstance].securityPolicy.validatesDomainName;
    _manager.securityPolicy = securityPolicy;
    
    //请求header
    NSDictionary *headerFieldValueDictionary = [request respondsToSelector:@selector(requestHeaderValueDictionary)] ? [request requestHeaderValueDictionary]: nil;
    if (headerFieldValueDictionary != nil)
    {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys)
        {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]])
            {
                
                [_manager.requestSerializer setValue:(NSString *)value
                                  forHTTPHeaderField:(NSString *)httpHeaderField];
            }
        }
    }
    
    request.allParam = finalParam;
    
    //缓存逻辑  !!需要重构
    if (method == HYRequestMethodGet) {
        
        NSString *key = [self keyForUrl:url param:finalParam];
        request.key = key;
        
        //不读缓存的策略，直接请求网络
        if (request.cachePolicy == HYRequestCachePolicyNeverUseCache ||
            request.cachePolicy == HYRequestCachePolicyDonotReadCache) {
            
            //发送请求
            [self p_sendRequestWithUrl:url
                                 param:finalParam
                                method:method
                               request:request
                          downloadPath:downloadPath
                     constructingBlock:constructingBlock
                         completeGroup:completeGroup];
        }
        else
        {
            if (key && key.length != 0) {
                HYResponseCache *cache = [HYNetworkConfig sharedInstance].cache;
                if (cache) {
                    
                    [cache objectForKey:key withBlock:^(HYDiskCache *cache,
                                                        NSString *key,
                                                        id object) {
                        
                        if (object) {
                            
                            [[HYNetworkLogger sharedInstance] logResponse:object withRequest:request];
                            
                            if (request.successHandler)
                            {
                                request.successHandler(request, object);
                            }
                            if ([request.delegate respondsToSelector:@selector(requestDidFinished:withResponse:)])
                            {
                                [request.delegate requestDidFinished:request withResponse:object];
                            }
                            
                            [request clearBlock];
                            
                            //读完缓存再请求网络
                            if (request.cachePolicy == HYRequestCachePolicyReadCacheAndRequest) {
                                
                                //发送请求
                                [self p_sendRequestWithUrl:url
                                                     param:finalParam
                                                    method:method
                                                   request:request
                                              downloadPath:downloadPath
                                         constructingBlock:constructingBlock
                                             completeGroup:completeGroup];
                            }
                            return;
                        }
                        else
                        {
                            //如果没有缓存，那么请求网络
                            if (request.cachePolicy == HYRequestCachePolicyReadCacheOrRequest) {
                                
                                //发送请求
                                [self p_sendRequestWithUrl:url
                                                     param:finalParam
                                                    method:method
                                                   request:request
                                              downloadPath:downloadPath
                                         constructingBlock:constructingBlock
                                             completeGroup:completeGroup];
                            }
                            return;
                        }
                    }];
                    
                }
            }
        }
    }
    else
    {
        //发送请求
        [self p_sendRequestWithUrl:url
                             param:finalParam
                            method:method
                           request:request
                      downloadPath:downloadPath
                 constructingBlock:constructingBlock
                     completeGroup:completeGroup];
    }
    
}

- (void)p_sendRequestWithUrl:(NSString *)url
                       param:(id)param
                      method:(HYRequestMethod)method
                     request:(HYBaseRequest *)request
                downloadPath:(NSString *)downloadPath
         constructingBlock:(HYConstructingBlock)constructingBlock
               completeGroup:(nullable dispatch_group_t)completeGroup
{
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task;
    void (^successBlock)(NSURLSessionDataTask *task, id responseObject)
    = ^(NSURLSessionDataTask * task, id responseObject)
    {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf p_handleSuccessWithResponse:responseObject andRequest:request];
        
        if (completeGroup) {
            dispatch_group_leave(completeGroup);
        }
    };
    
    void (^failureBlock)(NSURLSessionDataTask *task, NSError *error)
    = ^(NSURLSessionDataTask *task, NSError *error)
    {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf p_handleFailureWithError:error andRequest:request];
        
        if (completeGroup) {
            dispatch_group_leave(completeGroup);
        }
    };
    
    void (^progressBlock)(NSProgress *progress)
    = ^(NSProgress *progress)
    {
        if (progress.totalUnitCount <= 0)
        {
            return;
        }
        __strong typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf p_handleProgress:progress.totalUnitCount andRequest:request];
    };
    
    if (method == HYRequestMethodGet)
    {
        //是不是下载任务
        if (![HYBaseRequestInternal HYNetworkIsEmptyString:downloadPath])
        {
            task = [_manager GET:url
                      parameters:param
                        progress:progressBlock
                         success:successBlock
                         failure:failureBlock];
        }
        else
        {
            task = [_manager GET:url
                      parameters:param
                        progress:nil
                         success:successBlock
                         failure:failureBlock];
        }
    }
    else if (method == HYRequestMethodPost)
    {
        //有上传文件
        if (constructingBlock)
        {
            task = [_manager POST:url
                       parameters:param
        constructingBodyWithBlock:constructingBlock
                         progress:progressBlock
                          success:successBlock
                          failure:failureBlock];
        }
        else
        {
            task = [_manager POST:url
                       parameters:param
                         progress:progressBlock
                          success:successBlock
                          failure:failureBlock];
        }
        
    }
    else if (method == HYRequestMethodDelete)
    {
        task = [_manager DELETE:url
                     parameters:param
                        success:successBlock
                        failure:failureBlock];
    }
    else if (method == HYRequestMethodHead)
    {
        task = [_manager HEAD:url
                   parameters:param
                      success:^void(NSURLSessionDataTask *task){
            
            if (successBlock)
            {
                successBlock(task, nil);
            }
        } failure:failureBlock];
    }
    else if (method == HYRequestMethodPut)
    {
        task = [_manager PUT:url
                  parameters:param
                     success:successBlock
                     failure:failureBlock];
    }
    else if (method == HYRequestMethodPatch)
    {
        task = [_manager PATCH:url
                    parameters:param
                       success:successBlock
                       failure:failureBlock];
    }
    
    if (task)
    {
        request.URL = [task.currentRequest.URL absoluteString];
        request.task = task;
    }
    
    [[HYNetworkLogger sharedInstance] logRequest:request systemRequest:request.task.currentRequest];
}

- (void)cancelRequeset:(HYBaseRequest *)request
{
    [request.task cancel];
    
}

- (void)cancelAllRequest
{
    
}

- (BOOL)isLoadingRequest:(HYBaseRequest *)request
{
    NSURLSessionTask *task = request.task;
    if (task.state == NSURLSessionTaskStateRunning
        || task.state == NSURLSessionTaskStateSuspended)
    {
        return YES;
    }
    return NO;
}

#pragma mark build URL

- (NSString *)p_buildFullUrlWithRequest:(HYBaseRequest *)request param:(NSDictionary **)dic
{
    NSString *url = nil;
    if ([request respondsToSelector:@selector(fullUrl)] &&
        ![HYBaseRequestInternal HYNetworkIsEmptyString:[request fullUrl]])
    {
        url = [request fullUrl];
        return url;
    }
    else if ([[request apiUrl] hasPrefix:@"http"] ||
             [[request apiUrl] hasPrefix:@"https"])
    {
        url = [request apiUrl];
        NSLog(@"apiUrl 只需要返回API路径，不允许存在host，host应该从server对象读取");
        return @"";
    }
    
    url = [request apiUrl];
    
    //url filters
    if (request.urlDecorator)
    {
        request.urlDecorator.inUrl = url;
        request.urlDecorator.inRequest = request;
        request.urlDecorator.inParameterDic = nil;
        *dic = [request.urlDecorator outParameterDic];
        
        if (request.requestMethod == HYRequestMethodGet) {
            
            url = request.urlDecorator.outUrl;
        }
    }
    else
    {
        NSArray *filters = [_networkConfig urlDecorators];
        
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        NSDictionary *outParam = nil;
        for (id<HYNetworkParameterDecoratorProtocol>filter in filters)
        {
            filter.inUrl = url;
            filter.inRequest = request;
            filter.inParameterDic = outParam;
            
            outParam = [filter outParameterDic];
            [param addEntriesFromDictionary:[filter outParameterDic]];
            
            if (request.requestMethod == HYRequestMethodGet) {
                
                url = filter.outUrl;
            }
        }
        *dic = param;
    }
    
    NSString *baseUrl = nil;
    if (request.server)
    {
        baseUrl = [request.server baseUrl];
    }
    else
    {
        baseUrl = [_networkConfig.defaultSever baseUrl];
    }
    
    NSParameterAssert(url);
    NSParameterAssert(baseUrl);
    NSString *fullUrl = [NSString stringWithFormat:@"%@%@",baseUrl, url];
    return fullUrl;
}


#pragma mark handle request

- (void)p_handleSuccessWithResponse:(id)responseObject
                         andRequest:(HYBaseRequest *)request
{
    NSURLSessionTask *task = request.task;
    HYResponseStatus status = HYResponseStatusSuccessWithoutValidator;
    HYNetworkResponse *hyResponse = [self p_createResponseWithTask:task
                                                           request:request
                                                     systemReqeust:task.currentRequest
                                                            status:status
                                                      responseData:responseObject
                                                             error:nil];
    //过滤一下业务方定制的错误
    NSError *error = nil;
    if (request.responseFilter)
    {
        error = [request.responseFilter filterResponse:responseObject withRequest:request];
    }
    else
    {
        for (id<HYNetworkResponseFilterProtocol> filter in _networkConfig.responseFilters)
        {
            error = [filter filterResponse:responseObject withRequest:request];
        }
    }
    
    if (error)
    {
        [hyResponse setValue:error forKey:@"error"];
        [self p_toggleFailerRequestDelegateAndBlockWithRequest:request andResponse:hyResponse];
        return;
    }
    
    if (request.validator)
    {
        if ([request.validator responseDataValidator])
        {
            if([HYBaseRequestInternal checkResponsData:responseObject
                           withValidator:[request.validator responseDataValidator]])
            {
                status = HYResponseStatusSuccess;
                [hyResponse setValue:@(status) forKey:@"status"];
            }
            else
            {
                status = HYResponseStatusValidatorFailed;
                [hyResponse setValue:@(status) forKey:@"status"];
                [hyResponse setValue:[NSError errorWithDomain:KNetworkHYErrorDomain
                                                         code:KNetworkResponseValidatetErrorCode
                                                     userInfo:nil]
                              forKey:@"error"];
                
                [self p_toggleFailerRequestDelegateAndBlockWithRequest:request andResponse:hyResponse];
                return;
            }
        }
    }
    
    [self p_toggleSuccessRequestDelegateAndBlockWithRequest:request
                                                andResponse:hyResponse];
}

- (void)p_handleFailureWithError:(NSError *)error
                    andRequest:(HYBaseRequest *)request
{
    NSURLSessionTask *task = request.task;
    HYResponseStatus status = HYResponseStatusFailed;
    HYNetworkResponse *hyResponse = [self p_createResponseWithTask:task
                                                           request:request
                                                     systemReqeust:task.currentRequest
                                                            status:status
                                                      responseData:nil
                                                             error:error];
    
    [self p_toggleFailerRequestDelegateAndBlockWithRequest:request
                                               andResponse:hyResponse];
}

- (void)p_handleProgress:(int64_t)progress
              andRequest:(HYBaseRequest *)request
{
    if ([request.delegate respondsToSelector:@selector(request:loadingProgress:)])
    {
        [request.delegate request:request loadingProgress:0];
    }
}

#pragma mark create response

- (HYNetworkResponse *)p_createResponseWithTask:(NSURLSessionTask *)task
                                        request:(HYBaseRequest *)request
                                  systemReqeust:(NSURLRequest *)systemRequest
                                         status:(HYResponseStatus)status
                                   responseData:(id)data
                                          error:(NSError *)error;
{
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)task.response;
    HYNetworkResponse *response = [[HYNetworkResponse alloc] initWithResponse:urlResponse
                                                                    hyRequest:request
                                                                 responseData:data
                                                                       status:status
                                                                        error:error];
    return response;
}

#pragma mark toggle request delegate & block

- (void)p_toggleSuccessRequestDelegateAndBlockWithRequest:(HYBaseRequest *)request
                                        andResponse:(HYNetworkResponse *)responseObject
{
    
    for (id<HYNetworkResponseFilterProtocol>filter in _networkConfig.responseFilters)
    {
        NSError *error = [filter filterResponse:responseObject withRequest:request];
        if (error)
        {
            [responseObject setValue:error forKey:@"error"];
            [self p_toggleFailerRequestDelegateAndBlockWithRequest:request andResponse:responseObject];
            return;
        }
    }
    
    [[HYNetworkLogger sharedInstance] logResponse:responseObject withRequest:request];
    
    
    if (request.requestMethod == HYRequestMethodGet &&
        request.cachePolicy != HYRequestCachePolicyNeverUseCache) {
        
        HYResponseCache *cache = [HYNetworkConfig sharedInstance].cache;
        if (cache) {
            
            NSString *key = request.key;
            [cache setObject:responseObject
                      forKey:key
                      maxAge:request.cacheMaxAge
                   withBlock:^(HYDiskCache *cache,
                               NSString *key,
                               id object) {
               
            }];
        }
    }
    
    if (request.successHandler)
    {
        request.successHandler(request, responseObject);
    }
    if ([request.delegate respondsToSelector:@selector(requestDidFinished:withResponse:)])
    {
        [request.delegate requestDidFinished:request withResponse:responseObject];
    }
    [request clearBlock];
}

- (void)p_toggleFailerRequestDelegateAndBlockWithRequest:(HYBaseRequest *)request
                                                 andResponse:(HYNetworkResponse *)responseObject
{
    [[HYNetworkLogger sharedInstance] logResponse:responseObject withRequest:request];
    
    if (request.failerHandler)
    {
        request.failerHandler(request, responseObject);
    }
    if ([request.delegate respondsToSelector:@selector(request:withErrorResponse:)])
    {
        [request.delegate request:request withErrorResponse:responseObject];
    }
    [request clearBlock];
}

#pragma mark tools 

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

+ (BOOL)checkResponsData:(id)data
           withValidator:(id)validatorJson
{
    if ([data isKindOfClass:[NSDictionary class]] &&
        [validatorJson isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = data;
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
                result = [self checkResponsData:value withValidator:format];
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
                    result = NO;
                    break;
                }
            }
        }
        return result;
    }
    else if ([data isKindOfClass:[NSArray class]] && [validatorJson isKindOfClass:[NSArray class]])
    {
        NSArray *validatorArray = (NSArray *)validatorJson;
        if (validatorArray.count > 0)
        {
            NSArray *array = data;
            NSDictionary *validator = validatorJson[0];
            for (id item in array)
            {
                BOOL result = [self checkResponsData:item withValidator:validator];
                if (!result)
                {
                    return NO;
                }
            }
        }
        return YES;
    }
    else if ([data isKindOfClass:validatorJson])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSString *)keyForUrl:(NSString *)key
                  param:(NSDictionary *)param
{
    NSURL *url = [NSURL URLWithString:key];
    NSString *query = url.query;
    if (query)
    {
        NSArray *parametersArray = [query componentsSeparatedByString:@"&"];
        NSMutableDictionary *urlParameters = [self dicConvertByArray:parametersArray];
        [urlParameters addEntriesFromDictionary:param];
        return [NSString stringWithFormat:@"%@%@", url.path, [self sortedStringInDic:urlParameters]];
    }
    else
    {
        if (param && [param.allKeys count] != 0) {
            return [NSString stringWithFormat:@"%@%@", url.path, [self sortedStringInDic:param]];

        }
    }
    return key;
}

- (NSMutableDictionary *)dicConvertByArray:(NSArray *)array
{
    if (!array)
    {
        return  nil;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *temArray = [( NSString *)obj componentsSeparatedByString:@"="];
        if (temArray.count == 2) {
            [dic setObject:temArray[1] forKey:temArray[0]];
        }
    }];
    return dic;
}

- (NSString *)sortedStringInDic:(NSDictionary *)dic
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [array addObject:[NSString stringWithFormat:@"%@%@",key,obj]];
    }];
    NSArray * sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSLiteralSearch];
    }];
    NSMutableString * resultStr = [[NSMutableString alloc] init];
    [sortedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resultStr appendString:obj];
    }];
    
    return resultStr;
}


@end
