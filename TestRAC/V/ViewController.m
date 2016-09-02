//
//  ViewController.m
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "ViewController.h"
#import "RequestViewModel.h"
#import "DetailController.h"

@interface ViewController ()

@property (nonatomic, weak)   UITableView *tableView;
@property (nonatomic, strong) RequestViewModel *requesViewModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"RAC + MVVM";
    self.view.backgroundColor = [UIColor whiteColor];
    _requesViewModel = [[RequestViewModel alloc] init];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    tableView.dataSource = self.requesViewModel;
    tableView.delegate = self.requesViewModel;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    _requesViewModel.selectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *turple) {
        
        DetailController *detailVC = [[DetailController alloc] init];
        detailVC.sendObject = turple;
        [self.navigationController pushViewController:detailVC animated:YES];
        return [RACSignal empty];
    }];
    
    @weakify(self);
    [[[self.requesViewModel.reuqesCommand execute:nil]
     deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSArray *x) {
         @strongify(self);
         self.requesViewModel.models = x;
         [self.tableView reloadData];
    }];
}

@end




