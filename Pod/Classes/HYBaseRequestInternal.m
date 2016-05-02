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

static HYBaseRequestInternal *sharedInstance = nil;

@implementation HYBaseRequestInternal{

    AFHTTPSessionManager *_manager;

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

- (void)sendRequest:(HYBaseRequest *)request
{
    //require protocol method
    HYRequestMethod method = [request requestMethod];
    
    NSAssert(method == HYRequestMethodGet ||
             method == HYRequestMethodPost ||
             method == HYRequestMethodHead ||
             method == HYRequestMethodPut ||
             method == HYRequestMethodDelete ||
             method == HYRequestMethodPatch,@"Please Provide Legal Request Method");
    
    NSString *url = [self p_buildFullUrlWithRequest:request];
    
    //optional protcal method
    NSString *downloadPath = [request respondsToSelector:@selector(downloadPath)] ? [request downloadPath] : nil;
    id param = [request respondsToSelector:@selector(requestArgument)] ? [request requestArgument] : nil;
    HYConstructingBlock constructingBlock = [request respondsToSelector:@selector(constructingBodyBlock)] ? [request constructingBodyBlock]: nil;
    
    //timeout
    _manager.requestSerializer.timeoutInterval = [request respondsToSelector:@selector(requestTimeoutInterval)] ? [request requestTimeoutInterval] : KHYNetworkDefaultTimtout;
    
    //security
    NSUInteger pinningMode                  = [HYNetworkConfig sharedInstance].securityPolicy.pinningMode;
    AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode:pinningMode];
    securityPolicy.allowInvalidCertificates = [HYNetworkConfig sharedInstance].securityPolicy.allowInvalidCertificates;
    securityPolicy.validatesDomainName      = [HYNetworkConfig sharedInstance].securityPolicy.validatesDomainName;
    _manager.securityPolicy = securityPolicy;
    
    //header
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
            else
            {
                
            }
        }
    }
    
    [self p_sendRequestWithUrl:url
                         param:param
                        method:method
                       request:request
                  downloadPath:downloadPath
             constructingBlock:constructingBlock];
}

- (void)p_sendRequestWithUrl:(NSString *)url
                       param:(id)param
                      method:(HYRequestMethod)method
                     request:(HYBaseRequest *)request
                downloadPath:(NSString *)downloadPath
         constructingBlock:(HYConstructingBlock)constructingBlock
{
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task;
    void (^successBlock)(NSURLSessionDataTask *task, id responseObject)
    = ^(NSURLSessionDataTask * task, id responseObject)
    {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf p_handleSuccessWithResponse:responseObject andRequest:request];
    };
    
    void (^failureBlock)(NSURLSessionDataTask * task, NSError * error)
    = ^(NSURLSessionDataTask * task, NSError * error)
    {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf p_handleFailureWithError:error andRequest:request];
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
    
    /**
     一边发送请求一边打印NSURLRequest 实例的时候会产生内部崩溃 故systemRequest暂时不传了
     *  见 https://github.com/AFNetworking/AFNetworking/pull/843/commits/db305db733da040974c12f5fc6653db4388ac230
     */
    [[HYNetworkLogger sharedInstance] logRequest:request systemRequest:nil];
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

- (NSString *)p_buildFullUrlWithRequest:(HYBaseRequest *)request
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
        return url;
    }
    
    url = [request apiUrl];
    
    //url filters
    if (request.urlFilter)
    {
        url = [request.urlFilter filterUrl:url withRequest:request];
    }
    else
    {
        NSArray *filters = [_networkConfig urlFilters];
        for (id<HYNetworkUrlFilterProtocol>filter in filters)
        {
            url = [filter filterUrl:url withRequest:request];
        }
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
                [hyResponse setValue:[NSError errorWithDomain:KNetworkHYErrorDomain code:KNetworkResponseValidatetErrorCode userInfo:nil] forKey:@"error"];
                
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
    NSURLRequest *urlRequest = task.currentRequest;
    HYNetworkResponse *response = [[HYNetworkResponse alloc] initWithResponseRequestId:[request name]
                                                                         systemReqeust:systemRequest
                                                                             hyRequest:request
                                                                           requestURL:[urlRequest.URL absoluteString]
                                                                         responseData:data
                                                                       HTTPHeadFields:urlResponse.allHeaderFields
                                                                           statusCode:urlResponse.statusCode
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

@end
