//
//  HYResponseCache.h
//  MyFirst
//
//  Created by fangyuxi on 16/3/19.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const HYResponseCacheDataErrorNotification;

@class HYNetworkResponse;
@class HYBaseRequest;


@protocol HYNetworkCacheObjectProtocol <NSObject, NSCoding>

@required

@property (nonatomic, assign, readonly)NSTimeInterval maxAge;

- (BOOL)isExpire;

@end

@interface HYResponseCache : NSObject
{
    
}

@property (nonatomic, copy, readonly) NSString *path;

@property (nonatomic, assign) NSUInteger totalCostLimit;

@property (nonatomic, assign)NSUInteger countLimit;

@property (nonatomic, assign)NSTimeInterval maxAge;

#pragma mark init

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

#pragma mark storeObject

- (void)storeObject:(id<HYNetworkCacheObjectProtocol>)object
             forKey:(NSString *)key;

- (void)storeObject:(id<HYNetworkCacheObjectProtocol>)object
             forKey:(NSString *)key
          withBlock:(void(^)())block;


- (void)storeObject:(id<HYNetworkCacheObjectProtocol>)object
             forKey:(NSString *)key
             onDisk:(BOOL)onDisk;

- (void)storeObject:(id<HYNetworkCacheObjectProtocol>)object
             forKey:(NSString *)key
             onDisk:(BOOL)onDisk
               with:(void(^)())block;

#pragma mark getObject

- (id<HYNetworkCacheObjectProtocol>)objectForKey:(NSString *)key;

- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<HYNetworkCacheObjectProtocol> object))block;

#pragma mark removeObject

- (void)removeObjectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block;
- (void)removeAllObjects;
- (void)removeAllObjectsWithBlock:(void(^)(void))block;

@end












