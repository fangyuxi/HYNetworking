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

@interface HYViewController ()<HYRequestDelegate,HYBatchRequestsDelegate>
{
    
}

@property (nonatomic, strong) dispatch_group_t dispatchGroup;

@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    for (NSInteger index = 0; index < 1; ++index)
//    {
//        HYSimpleRequest *request = [[HYSimpleRequest alloc] init];
//        request.simpleRequestMethod = HYRequestMethodGet;
//        request.simpleApiUrl = @"/api/system?method=initApp";
//        request.simpleName = @"fangyuxi";
//        
//        [request startWithSuccessHandler:^(HYBaseRequest *request, HYNetworkResponse *response) {
//            
//            
//        } failuerHandler:^(HYBaseRequest *request, HYNetworkResponse *response) {
//            
//        }];
//        
//        [request start];
//    }
    
    HYDelegateRequest *request1 = [[HYDelegateRequest alloc] init];
    request1.delegate = self;
    [request1 start];
    
//    HYDelegateRequest *request2 = [[HYDelegateRequest alloc] init];
//    request2.delegate = self;
//    
//    HYDelegateRequest *request3 = [[HYDelegateRequest alloc] init];
//    request3.delegate = self;
//    
//    HYDelegateRequest *request4 = [[HYDelegateRequest alloc] init];
//    request4.delegate = self;
//    
//    HYDelegateRequest *request5 = [[HYDelegateRequest alloc] init];
//    request5.delegate = self;
//    
//    HYBatchRequests *batch = [HYBatchRequests new];
//    batch.delegate = self;
//    [batch addRequest:request1];
//    [batch addRequest:request2];
//    [batch addRequest:request3];
//    [batch addRequest:request4];
//    [batch addRequest:request5];
//    
//    [batch start];
    
    //self.dispatchGroup = dispatch_group_create();
//    for (NSInteger index = 0; index < 100; ++index)
//    {
//        
//        
//        //dispatch_group_enter(self.dispatchGroup);
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            HYDelegateRequest *request = [[HYDelegateRequest alloc] init];
//            request.delegate = self;
//            [request start];
//        });
//    }
    
//    dispatch_group_notify(self.dispatchGroup, dispatch_get_main_queue(), ^(){
//    
//        NSLog(@"Delegate Request All Finished");
//        
//    });
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
    //dispatch_group_leave(self.dispatchGroup);
}

- (void)request:(HYBaseRequest *)request
withErrorResponse:(HYNetworkResponse *)response
{
    //dispatch_group_leave(self.dispatchGroup);
}

@end





