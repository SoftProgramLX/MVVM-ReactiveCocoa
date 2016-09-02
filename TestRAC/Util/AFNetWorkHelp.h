//
//  AFNetWorkHelp.h
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

@interface AFNetWorkHelp : NSObject

@property (nonatomic, assign) AFNetworkReachabilityStatus wifiType;

+ (instancetype)sharedAFNetWorkHelp;

+ (void)getWithUrlString:(NSString *)urlStr withParam:(NSDictionary *)param success:(void (^)(NSDictionary * responseDic))success failure:(void (^)(NSError *error))failure;
+ (void)postWithUrlString:(NSString *)urlStr withParam:(NSDictionary *)param success:(void (^)(NSDictionary * responseDic))success failure:(void (^)(NSError *error))failure;
+ (RACSignal *)signalForLoadingImage:(NSString *)imageUrl;

@end
