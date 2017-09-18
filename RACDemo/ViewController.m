//
//  ViewController.m
//  RACDemo
//
//  Created by 施文松 on 2017/9/13.
//  Copyright © 2017年 施文松. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *loginButton;


@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *password;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"登录" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    self.loginButton = button;
    
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"点击了按钮 == %@", x);
    }];
    
    [self.view addSubview:button];
    WS(ws);
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
       make.center.equalTo(ws.view);
    }];
    
    RAC(self, userName) = self.accountTextField.rac_textSignal;
    RAC(self, password) = self.passwordTextField.rac_textSignal;
    
    RACSignal *userNameSignal = RACObserve(self, userName);
    RACSignal *passwordSignal = RACObserve(self, password);
    [userNameSignal subscribeNext:^(id x) {
        NSLog(@"userName == %@", x);
    }];
    
    [passwordSignal subscribeNext:^(id x) {
        NSLog(@"password == %@", x);
    }];
    
    [[RACSignal combineLatest:@[userNameSignal, passwordSignal] reduce:^(NSString *userName, NSString *password){
        return @(userName.length > 0 && password.length > 0);
    }] subscribeNext:^(id x) {
        NSLog(@"结果是 == %@", x);
    }];
    
    @weakify(self);
    [RACObserve(self, userName) subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"userName == %@", x);
    }];
    
    [RACObserve(self, password) subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"password == %@", x);
    }];
    
    
    
    
    
    RACSignal *comSignal = [RACSignal combineLatest:@[userNameSignal, passwordSignal] reduce:^(NSString *userName, NSString *password){
        return @(userName.length > 0 && password.length > 0);
    }];
    
    RAC(self.loginButton, backgroundColor) = [comSignal map:^id(NSNumber *value) {
        return value.boolValue ? [UIColor yellowColor] : [UIColor clearColor];
    }];
    
    RAC(self.loginButton, enabled) = comSignal;
    
    
//    [[comSignal timeout:15 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSError *error) {
//        NSLog(@"等了你15秒，你还没有结果，已经超时了.");
//    }];
//
//    /// 延迟20秒执行
//    [[comSignal delay:20] subscribeNext:^(id x) {
//        NSLog(@"我在路上耽搁了20秒时间");
//    }];
    
    
    //// 定时任务是从3秒后开始的，开始的时候不会执行，
//    RACSignal *signal1 = [RACSignal interval:3 onScheduler:[RACScheduler mainThreadScheduler]];
//    NSLog(@"开始计算时间");
//    [signal1 subscribeNext:^(id x) {
//       // 定时任务每3秒执行一次
//        NSLog(@"3秒过去了");
//    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"导演最近拍了一部《战狼2》");
        [subscriber sendNext:@"《战狼2》"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            /// 清理数据
        }];
    }];
    
    RACSignal *replaySignal = [signal2 replay];
    [replaySignal subscribeNext:^(id x) {
        NSLog(@"小明看了%@", x);
    }];
    
    
    [replaySignal subscribeNext:^(id x) {
        NSLog(@"小红也看了%@", x);
    }];
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *inputString) {
        NSLog(@"%@我投降了", inputString);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    [command execute:@"今天"];
    
    
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"RAC新号串 ------ 打开冰箱门");
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"RAC信号串------把大象放进冰箱");
            [subscriber sendCompleted];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"RAC信号串------关上冰箱门");
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeCompleted:^{
        NSLog(@"RAC新号串结束了");
    }];
//    :^(id x) {
//        NSLog(@"RAC新号串结束了");
//    }];
//
    
    
    RACSignal *signal22 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(10)];
        [subscriber sendNext:@(8)];
        [subscriber sendNext:@(19)];
        [subscriber sendNext:@(40)];
        [subscriber sendNext:@(60)];
        [subscriber sendNext:@(14)];
        return nil;
    }];
    
    [[signal22 filter:^BOOL(NSNumber *value) {
        return value.integerValue > 12;
    }] subscribeNext:^(id x) {
        NSLog(@"过滤后的数据是 == %@", x);
    }];
    
    
    RACSignal *signal33 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"石头"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [[signal33 map:^id(NSString *value) {
        if ([value isEqualToString:@"石头"]) {
            return @"金子";
        }
         return value;
    }] subscribeNext:^(id x) {
        NSLog(@"遍历修改后的数据是 == %@", x);
    }];
    
    RACSignal *signal44 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"纸质污染"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal55 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"石油污染"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [[RACSignal merge:@[signal44 , signal55]] subscribeNext:^(id x) {
        NSLog(@"处理%@", x);
    }];
    
    
    RACSignal *signal66 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"我恋爱了"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal77 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"我结婚了"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [[signal66 concat:signal77] subscribeNext:^(id x) {
        NSLog(@"当前的数据是 == %@", x);
    }];
    
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"currentNotification" object:nil] subscribeNext:^(NSNotification *x) {
        NSLog(@"接受到了通知 === %@", x);
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"currentNotification" object:nil userInfo:@{@"name" : @"施文松", @"age" : @"25"}];
    
    
//    RACSignal *signal00 = [self rac_signalForSelector:@selector(touchesBegan:withEvent:)];
//    [signal00 subscribeNext:^(RACTuple *tuple) {
//        NSLog(@"第一个参数是 == %@，第二个参数是 == %@",tuple.first, tuple.second);
//    }];
    
    [[self rac_signalForSelector:@selector(touchesBegan:withEvent:)] subscribeNext:^(id x) {
        NSLog(@"点击了视图");
    }];
    
    
//    [[self rac_signalForSelector:@selector(touchesBegan:withEvent:)] subscribeNext:^(id x) {
////        NSLog(@"第一个参数是 == %@，第二个参数是 == %@",);
//        NSLog(@"点击了View");
//    }];
    
    
    
    

    
    
    
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
        
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
