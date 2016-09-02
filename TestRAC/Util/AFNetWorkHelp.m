//
//  AFNetWorkHelp.m
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "AFNetWorkHelp.h"

@implementation AFNetWorkHelp

DEFINE_SINGLETON_FOR_CLASS(AFNetWorkHelp);

- (instancetype)init
{
    self = [super init];
    if (self) {
        //默认为Wi-Fi状态
        self.wifiType = AFNetworkReachabilityStatusReachableViaWiFi;
    }
    return self;
}

+ (void)getWithUrlString:(NSString *)urlStr withParam:(NSDictionary *)param success:(void (^)(NSDictionary * responseDic))success failure:(void (^)(NSError *error))failure
{
    if ([AFNetWorkHelp sharedAFNetWorkHelp].wifiType < 0) {
        NSError *error = nil;
        failure(error);
        return;
    }
    
    AFHTTPSessionManager *manager = [self afmanager];
    
    [manager GET:urlStr parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@", error);
    }];
}


+ (void)postWithUrlString:(NSString *)urlStr withParam:(NSDictionary *)param success:(void (^)(NSDictionary * responseDic))success failure:(void (^)(NSError *error))failure
{
    if ([AFNetWorkHelp sharedAFNetWorkHelp].wifiType < 0) {
        NSError *error = nil;
        failure(error);
        return;
    }
    
    AFHTTPSessionManager *manager = [self afmanager];

    [manager POST:urlStr parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@", error);
     }];
}

+ (RACSignal *)signalForLoadingImage:(NSString *)imageUrl
{
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority: RACSchedulerPriorityBackground];
    
    return [[RACSignal createSignal:^RACDisposable *(id subscriber) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];
}

+ (void)getCurrentNet
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        [AFNetWorkHelp sharedAFNetWorkHelp].wifiType = status;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:            //未知网络
                break;
            case AFNetworkReachabilityStatusNotReachable:       //没有网络
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:   //手机自带网络
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:   //WIFI
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AFNetworkReachabilityStatus" object:[NSString stringWithFormat:@"%d", (int)status]];
    }];
    [manager startMonitoring];
}

+ (AFHTTPSessionManager*)afmanager
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.securityPolicy     = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json",nil];
    
    return manager;
}

@end


