//
//  ViewController.m
//  MyDownLoadBreakPoint
//
//  Created by qianfeng007 on 15/8/7.
//  Copyright (c) 2015年 刘卫星. All rights reserved.
//

#import "ViewController.h"
#import "LWXDownBreakPoint.h"
#define Url @"http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.0.0.1419920162.dmg"
#import "NSString+Hashing.h"
@interface ViewController ()<UIActionSheetDelegate>
{
    LWXDownBreakPoint*_breakPoint;
    NSTimer*_timer;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton*button=[UIButton buttonWithType:UIButtonTypeSystem];
    button.frame=CGRectMake(50, 50, 50, 30);
    [button setTitle:@"start" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton*button2=[UIButton buttonWithType:UIButtonTypeSystem];
    button2.frame=CGRectMake(250, 50, 50, 30);
    [button2 setTitle:@"stop" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIProgressView*view=[[UIProgressView alloc]initWithFrame:CGRectMake(50, 100, 250, 10)];
    view.progressTintColor=[UIColor greenColor];
    view.progress=[(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:[Url MD5Hash]] floatValue];

    view.tag=10;
    [self.view addSubview:view];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, 200, 250, 200)];
    label.numberOfLines=0;
    label.textColor=[UIColor orangeColor];
    label.tag=11;
    [self.view addSubview:label];
}

-(void)start{
    //如果这个任务已经存在就返回
    if (_breakPoint) {
        return;
            }
    _breakPoint=[[LWXDownBreakPoint alloc]init];

    [_breakPoint downLoadWithUrl:Url];
    //_breakPoint
    _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(progress) userInfo:nil repeats:YES];
}
-(void)stop{
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    [_breakPoint stop];
}
-(void)progress{
    UIProgressView*view=(UIProgressView*)[self.view viewWithTag:10];
    view.progress=[_breakPoint getProgress];
    UILabel*label=(UILabel*)[self.view viewWithTag:11];
    label.text=[_breakPoint getContent];
    if (view.progress>=1.0) {
        [self stop];
        UIActionSheet*sheet=[[UIActionSheet alloc]initWithTitle:@"下载完毕" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定",@"重新下载",nil];
        [sheet showInView:self.view];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [[NSFileManager defaultManager] removeItemAtPath:[_breakPoint getFullPathWithUrl:Url] error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[Url MD5Hash]];
        UIProgressView*view=(UIProgressView*)[self.view viewWithTag:10];
        view.progress=0;
        _breakPoint=nil;
        [self start];
        return;
    }
    [self stop];
    _breakPoint=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
