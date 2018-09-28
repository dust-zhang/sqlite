//
//  UpLoadLog.h
//  test
//
//  Created by dust.zhang on 2018/9/7.
//  Copyright © 2018年 dust.zhang. All rights reserved.
//
// 此类功能：
//轮训上传本地日志，上传成功后删除本地日志记录


#import <Foundation/Foundation.h>
#import "BMKPDbManager.h"

@interface UpLoadLog : NSObject

//单例
+(instancetype)shareInstance;

//轮训查找数据，然后上传到服务器
-(void) upLoadLog:(float)interval;

//重新开始计时器
-(void) reStartTime;

@end
