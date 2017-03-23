//
//  HYAppDelegate.m
//  HYNetworking
//
//  Created by fangyuxi on 03/23/2016.
//  Copyright (c) 2016 fangyuxi. All rights reserved.
//

#import "HYAppDelegate.h"
#import "HYViewController.h"

#import "HYNetworkDefaultServer.h"
#import "HYNetworkGlobalParamFilter.h"
#import "HYNetworkSignatureUrlFilter.h"
#import "HYNetworkSomethingParamFilter.h"
#import "HYResponseCache.h"

@implementation HYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self p_configNetwork];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    HYViewController *root = [[HYViewController alloc] init];
    self.window.rootViewController = root;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)p_configNetwork
{
    HYNetworkConfig *config = [HYNetworkConfig sharedInstance];
    config.defaultSever = [[HYNetworkDefaultServer alloc] init];
    config.logHeader = NO;
    config.defaultSever.online = YES;
    config.defaultSever.verify = NO;
    config.securityPolicy = [HYNetworkSecurityPolicy defaultSecurityPolicy];
    config.cache = [[HYResponseCache alloc] initWithName:@"fangyuxi"];
    
    [HYNetworkConfig sharedInstance].securityPolicy.pinningMode = HYSSLPinningModeCertificate;
    [HYNetworkConfig sharedInstance].securityPolicy.allowInvalidCertificates = YES;
    [HYNetworkConfig sharedInstance].securityPolicy.validatesDomainName = NO;
    
    //[config addUrlFilter:[[HYNetworkGlobalParamFilter alloc] init]];
//    [config addUrlFilter:[[HYNetworkSomethingParamFilter alloc] init]];
//    [config addUrlFilter:[[HYNetworkSignatureUrlFilter alloc] init]];
    
}

- (void)setString:(NSString *)string
{
    _string = string;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
