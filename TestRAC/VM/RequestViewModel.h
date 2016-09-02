//
//  RequestViewModel.h
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//


@interface RequestViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>

// 请求命令
@property (nonatomic, strong) RACCommand *reuqesCommand;
@property (nonatomic, strong) RACCommand *selectCommand;
//模型数组
@property (nonatomic, strong) NSArray *models;

@end
