# MVVM-ReactiveCocoa
ReactiveCocoa是由github开发维护的一个开源框架，简称RAC，它采用的是函数响应式编程（FRP）技术，区别于Objective-c面相对象的编程思想。所以刚接触这类编程思想的理解起来会有一点变扭。

在iOS中使用RAC后代码可读可维护，结构清晰，RAC提供的事件流通过 Signal 和 SignalProducer 类型来表示, 统一了Cocoa用于事件和异步处理的常用模式，包括
* 网络请求
* 遍历
* 代理
* block
* 通知
* KVO
* 控件的响应事件链

RAC语法如下：
```objective-c
@weakify(self);
[[[[[[[self requestAccessToTwitterSignal]
      then:^RACSignal *{
          @strongify(self)
          return self.searchText.rac_textSignal;
      }]
     filter:^BOOL(NSString *text) {
         @strongify(self)
         return [self isValidSearchText:text];
     }]
    throttle:0.5]
   flattenMap:^RACStream *(NSString *text) {
       @strongify(self)
       return [self signalForSearchWithText:text];
   }]
    deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(NSDictionary *jsonSearchResult) {
       NSArray *statuses = jsonSearchResult[@"statuses"];
       NSArray *tweets = [statuses linq_select:^id(id tweet) {
           return [RWTweet tweetWithStatus:tweet];
     }];
     [self.resultsViewController displayTweets:tweets];
 } error:^(NSError *error) {
     NSLog(@"An error occurred: %@", error);
 }];
```

这个例子就不用解释了，往下看会明白，其中所有的API都基于信号Signal的，常用API如下：
#####1.绑定
* bind:绑定

#####2.映射
* flattenMap:信号发出的值是信号，Block返回信号。
* Map:信号发出的值不是信号，Block返回对象。
他们用于把源信号内容映射成新的内容

#####3.组合
* concat:按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号。
* then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号。
* merge:把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
* zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
* combineLatest:将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
* reduce聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值

#####4.过滤
* filter:过滤信号，使用它可以获取满足条件的信号.
* ignore:忽略完某些值的信号.
* distinctUntilChanged:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
* take:从开始一共取N次的信号
* takeLast:取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号.
* takeUntil:(RACSignal *):获取信号直到某个信号执行完成
* skip:(NSUInteger):跳过几个信号,不接受。
* switchToLatest:用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。

#####5.秩序
* doNext: 执行Next之前，会先执行这个Block
* doCompleted: 执行sendCompleted之前，会先执行这个Block

#####6.线程
* deliverOn: 内容传递切换到制定线程中，副作用在原来线程中,把在创建信号时block中的代码称之为副作用。
* subscribeOn: 内容传递和副作用都会切换到制定线程中。

#####7.时间
* timeout：超时，可以让一个信号在一定的时间后，自动报错。 
* interval 定时：每隔一段时间发出信号
* delay 延迟发送next。

#####8.重复
* retry重试 ：只要失败，就会重新执行创建信号中的block,直到成功.
* replay重放：当一个信号被多次订阅,反复播放内容
* throttle节流:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。

下面基于RAC+MVVM写了一个demo，源码请点击[github地址](https://github.com/SoftProgramLX/MVVM-ReactiveCocoa)下载。效果图如下：<br>

![image1.png](http://upload-images.jianshu.io/upload_images/301102-d8bcf7f502cd16cf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

<br>

项目结构图如下：
![image.png](http://upload-images.jianshu.io/upload_images/301102-72fa56da8171245d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


###M：的代码
```objective-c
//UserModel.h
@interface UserModel : NSObject
@property (nonatomic, copy)   NSString *desc;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *avatar;
@property (nonatomic, copy)   NSString *alt;
+ (instancetype)userWithDict:(NSDictionary *)dic;
@end

//UserModel.m
@implementation UserModel
+ (instancetype)userWithDict:(NSDictionary *)dic
{
    //采用的笨方法选择需要的几个数据
    UserModel *book = [[UserModel alloc] init];
    book.name = dic[@"name"];
    book.desc = dic[@"desc"];
    book.avatar = dic[@"avatar"];
    book.alt = dic[@"alt"];
    return book;
}
@end
```
model里的代码很简单，仅有的一个方法就是字典转模型，没有用kvc与第三方转化。

###V：的代码（V包括View与ViewController）
```objective-c
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
```
首先实例话了一个VM对象_requesViewModel，然后创建UI，将代理方法都设置为vm对象，从而减少了C代码量。接着绑定selectCommand，这个命令实现跳转控制器。最后执行reuqesCommand，通过execute方法将冷信号转化成了热信号，通过deliverOn方法转移到主线程用于刷新UI，然后通过subscribeNext方法订阅了信号，传的block参数需要发送sendNext方法才会被激活。其中涉及到RACTuple类，它就是集合类，这里做了NSArray的事。


###VM：的代码
```objective-c

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
//省略部分代理方法
......
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RACTuple *turple = [RACTuple tupleWithObjects:self.models[indexPath.row], indexPath, nil];
    [self.selectCommand execute:turple];
}

@end
```

初始化本类的对象时就创建了_reuqesCommand信号，用于暴露给V去激活。在这个信号的block中做了两件事，第一是用信号requestSignal执行网络请求，套用了AFNetworking框架。第二是在return前将得到的网络数据转化为模型数组。

当获取到网络数据运行[subscriber sendNext:responseDic];后才会执行return [requestSignal map:^id(NSDictionary *value)后的block，这个方法是将订阅的信号转化为热信号。


<br>
源码请点击[github地址](https://github.com/SoftProgramLX/MVVM-ReactiveCocoa)下载。
---
QQ:2239344645    [我的github](https://github.com/SoftProgramLX?tab=repositories)<br>
