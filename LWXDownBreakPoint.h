//
//  LWXDownBreakPoint.h
//  MyDownLoadBreakPoint
//
//  Created by qianfeng007 on 15/8/7.
//  Copyright (c) 2015年 刘卫星. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LWXDownBreakPoint : NSObject<NSURLConnectionDataDelegate>
-(void)downLoadWithUrl:(NSString*)url;
-(void)stop;
-(float)getProgress;
-(NSString*)getFullPathWithUrl:(NSString*)url;
-(NSString*)getContent;
@end
