//
//  DetailController.m
//  TestRAC
//
//  Created by 李旭 on 16/9/2.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "DetailController.h"
#import "UserModel.h"

@interface DetailController () <UIWebViewDelegate>
{
    NSArray *dataArr;
}

@property (retain, nonatomic)UIWebView *webView;

@end

@implementation DetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UserModel *model = [(RACTuple *)self.sendObject first];
    self.title = model.name;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _webView.scalesPageToFit = YES;
    _webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    [self.view addSubview:_webView];

    NSURL *url = [NSURL URLWithString:model.alt];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end




