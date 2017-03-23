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
#import "HYAppDelegate.h"
#import <objc/runtime.h>
@interface HYViewController ()<HYRequestDelegate,HYBatchRequestsDelegate>
{
    NSString *_name;
}

@property (nonatomic, strong) dispatch_group_t dispatchGroup;

@end

@implementation HYViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)batchAPIRequestsDidFinished:(HYBatchRequests *)batchApis
{
    
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





