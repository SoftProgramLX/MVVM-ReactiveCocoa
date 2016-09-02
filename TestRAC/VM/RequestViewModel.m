//
//  RequestViewModel.m
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "RequestViewModel.h"
#import "UserModel.h"
#import "AFNetWorkHelp.h"
#import "LXTableViewCell.h"

@implementation RequestViewModel

- (instancetype)init
{
    if (self = [super init]) {
        [self initialBind];
    }
    return self;
}

- (void)initialBind
{
    _reuqesCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *requestSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"q"] = @"iOS";
            parameters[@"count"] = @"30";
            NSString *urlStr = @"https://api.douban.com/v2/user";
            
            [AFNetWorkHelp getWithUrlString:urlStr withParam:parameters success:^(NSDictionary *responseDic) {
                
                // 请求成功调用
                // 把数据用信号传递出去
                [subscriber sendNext:responseDic];
                [subscriber sendCompleted];
                LogBlue(@"%@", responseDic);

            } failure:^(NSError *error) {
                
            }];
            
            return nil;
        }];
        
        // 在返回数据信号时，把数据中的字典映射成模型信号，传递出去
        return [requestSignal map:^id(NSDictionary *value) {
            NSArray *dictArr = value[@"users"];
            
            // 字典转模型，遍历字典中的所有元素，全部映射成模型，并且生成数组
#if 1       
            //这是正常方法
            NSArray *modelArr = [dictArr dicToModel:^id(id user) {
                return [UserModel userWithDict:user];
            }];
#else
            //这是ARC提供的遍历方法，简单
            NSArray *modelArr = [[dictArr.rac_sequence map:^id(id value) {
                return [UserModel userWithDict:value];
            }] array];
#endif
            return modelArr;
        }];
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXTableViewCell *cell = [LXTableViewCell cellWithTableView:tableView];
    [cell configurationCell:self.models[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RACTuple *turple = [RACTuple tupleWithObjects:self.models[indexPath.row], indexPath, nil];
    [self.selectCommand execute:turple];
}

@end


