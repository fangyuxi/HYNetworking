//
//  HYResponseCache.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/19.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYResponseCache.h"
#import "HYNetworking.h"

NSString *const HYResponseCacheDataErrorNotification = @"HYResponseCacheDataErrorNotification";

@implementation HYResponseCache{

    NSCache *_memoryCache;
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
}

#pragma mark lock

- (void)lock
{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unlock
{
    dispatch_semaphore_signal(_lock);
}

#pragma mark init

- (instancetype)init
{
    return [self initWithPath:nil];
}

- (instancetype)initWithPath:(NSString *)path
{
    if (path.length == 0 || ![self p_createDirectoryWithPath:_path])
    {
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        _path = [path copy];
        _lock = dispatch_semaphore_create(1);
        _queue = dispatch_queue_create([@"com.58.HYResponseCacheQueue" UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _memoryCache = [[NSCache alloc] init];
        _maxAge = KHYResponseCacheMaxAge;
        
        return self;
    }
    return nil;
}

#pragma mark setter

- (void)setTotalCostLimit:(NSUInteger)totalCostLimit
{
    _totalCostLimit = totalCostLimit;
    _memoryCache.totalCostLimit = totalCostLimit;
}

- (void)setCountLimit:(NSUInteger)countLimit
{
    _countLimit = countLimit;
    _memoryCache.countLimit = countLimit;
}

#pragma mark store

- (void)storeObject:(id<HYNetworkCacheObjectProtocol>)object
             forKey:(NSString *)key
          withBlock:(void(^)())block
{
    if (!block) {return;}
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
       __strong typeof(weakSelf) self = weakSelf;
        [self storeObject:object forKey:key];
        block();
    });
}

- (void)storeObject:(id<HYNetworkCacheObjectProtocol>)object
             forKey:(NSString *)key
{
    [self storeObject:object forKey:key onDisk:YES];
}



- (void)storeObject:(id<HYNetworkCacheObjectProtocol>)object forKey:(NSString *)key onDisk:(BOOL)onDisk
{
    if (!object || !key || ![key isKindOfClass:[NSString class]] || key.length == 0)
    {
        return;
    }
    
    //memoryCache already thread-safe
    [_memoryCache setObject:object forKey:key];
    
    if (onDisk)
    {
        [self lock];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        if (data)
        {
            if([self p_fileWriteWithName:key data:data])
            {
                [self unlock];
            }
            else
            {
                [self unlock];
                
                //错误通知
            }
            
        }
        else
        {
            [self unlock];
            //错误通知
        }
    }
}

- (void)storeObject:(id<HYNetworkCacheObjectProtocol>)object
             forKey:(NSString *)key
             onDisk:(BOOL)onDisk
               with:(void(^)())block
{
    if (!block) {return;}
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self storeObject:object forKey:key onDisk:onDisk];
        block();
    });
}

#pragma mark get object

- (id<HYNetworkCacheObjectProtocol>)objectForKey:(NSString *)key;
{
    if (!key) {return nil;}

    //query object from memcache
    id<HYNetworkCacheObjectProtocol> object = [_memoryCache objectForKey:key];
    if (object){return object;}
    else
    {
        [self lock];
        NSData *data = [self p_fileReadWithName:key];
        if (data)
        {
            id<HYNetworkCacheObjectProtocol> object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (object) {return object;}
        }
        [self unlock];
    }
    return nil;
}

- (void)objectForKey:(NSString *)key
           withBlock:(void(^)(NSString *key, id<HYNetworkCacheObjectProtocol> object))block
{
    if (!block) {return;}
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        __strong typeof(weakSelf) self = weakSelf;
        id<HYNetworkCacheObjectProtocol> object = [self objectForKey:key];
        block(key, object);
    });
}

#pragma mark removeObject

- (void)removeObjectForKey:(NSString *)key
{
    
}

- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block
{
    
}

- (void)removeAllObjects
{
    
}

- (void)removeAllObjectsWithBlock:(void(^)(void))block
{
    
}

#pragma mark file

- (BOOL)p_fileWriteWithName:(NSString *)filename data:(NSData *)data
{
    NSString *path = [self.path stringByAppendingPathComponent:filename];
    return [data writeToFile:path atomically:NO];
}

- (NSData *)p_fileReadWithName:(NSString *)filename
{
    NSString *path = [self.path stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

- (BOOL)p_fileDeleteWithName:(NSString *)filename
{
    NSString *path = [self.path stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (BOOL)p_createDirectoryWithPath:(NSString *)path
{
    BOOL suc = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:NULL];
    return suc;
}


@end
