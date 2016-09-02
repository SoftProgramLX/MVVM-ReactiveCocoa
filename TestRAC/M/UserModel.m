//
//  Book.m
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (instancetype)userWithDict:(NSDictionary *)dic
{
    UserModel *book = [[UserModel alloc] init];
    book.name = dic[@"name"];
    book.desc = dic[@"desc"];
    book.avatar = dic[@"avatar"];
    book.alt = dic[@"alt"];
    return book;
}

@end
