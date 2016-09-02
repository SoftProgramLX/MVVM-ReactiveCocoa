//
//  Book.h
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, copy)   NSString *desc;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *avatar;
@property (nonatomic, copy)   NSString *alt;

+ (instancetype)userWithDict:(NSDictionary *)dic;

@end
