//
//  HYViewController.m
//  HYNetworking
//
//  Created by fangyuxi on 03/23/2016.
//  Copyright (c) 2016 fangyuxi. All rights reserved.
//

#import "HYViewController.h"
#import "HYNetworking.h"
#import "HYDelegateRequest.h"

@interface HYViewController ()<HYRequestDelegate>

@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    for (NSInteger index = 0; index < 10; ++index)
    {
        HYSimpleRequest *request = [[HYSimpleRequest alloc] init];
        request.simpleRequestMethod = HYRequestMethodGet;
        request.simpleApiUrl = @"/api/system?method=initApp";
        request.simpleIdentifier = @"fangyuxi";
        
        [request startWithSuccessHandler:^(HYBaseRequest *request, HYNetworkResponse *response) {
            
            
        } failerHandler:^(HYBaseRequest *request, HYNetworkResponse *response) {
            
        } progressHandler:^(HYBaseRequest *request, int64_t progress) {
            
        }];
        
        [request start];
        
        //dispatch_group_enter(batch_api_group);
    }
    
    
    for (NSInteger index = 0; index < 10; ++index)
    {
        HYDelegateRequest *request = [[HYDelegateRequest alloc] init];
        request.delegate = self;
        [request start];
        
        //dispatch_group_enter(batch_api_group);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)requestDidFinished:(HYBaseRequest *)request
              withResponse:(HYNetworkResponse *)response
{
    
}

- (void)request:(HYBaseRequest *)request
withErrorResponse:(HYNetworkResponse *)response
{
    
}

@end





