//
//  LWXDownBreakPoint.m
//  MyDownLoadBreakPoint
//
//  Created by qianfeng007 on 15/8/7.
//  Copyright (c) 2015年 刘卫星. All rights reserved.
//

#import "LWXDownBreakPoint.h"
#import "NSString+Hashing.h"

@implementation LWXDownBreakPoint
{
    NSURLConnection*_connection;
    unsigned long long _load;
    unsigned long long _preLoad;
    unsigned long long _total;
    NSFileHandle*_fileHandle;
    NSString*_str;
}
-(NSString*)getFullPathWithUrl:(NSString*)url{
    NSString*docunment=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString*filePath=[docunment stringByAppendingPathComponent:[NSString stringWithFormat:@"%@docunment",[url MD5Hash]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    NSLog(@"%@",filePath);
    return filePath;
}
-(void)downLoadWithUrl:(NSString *)url{
    NSDictionary*dict=[[NSFileManager defaultManager] attributesOfItemAtPath:[self getFullPathWithUrl:url] error:nil];
    unsigned long long fileSize=[dict fileSize];
    _load=fileSize;
    _str=[[NSString alloc]initWithString:url];
    NSMutableURLRequest*reuqest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [reuqest addValue:[NSString stringWithFormat:@"bytes=%llu-",fileSize] forHTTPHeaderField:@"Range"];
    _fileHandle=[NSFileHandle fileHandleForWritingAtPath:[self getFullPathWithUrl:url]];
    _connection=[[NSURLConnection alloc]initWithRequest:reuqest delegate:self];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _total=_load+response.expectedContentLength;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:data];
    [_fileHandle synchronizeFile];
    _preLoad=_load;
    _load+=data.length;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%f",_load*1.0/_total] forKey:[_str MD5Hash]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self stop];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self stop];
}

-(void)stop{
    if (_connection) {
        [_connection cancel];
        _connection=nil;
    }
    [_fileHandle closeFile];
}
-(float)getProgress{
    return _load*1.0/_total;
}
-(NSString *)getContent{
    return [NSString stringWithFormat:@"文件总大小为%.2fM,当前下载速度为%fKB,目前已下载%%%.2f",_total*1.0/1024/1024,(_load-_preLoad)*1.0/1024,[self getProgress]*100];
}
@end
