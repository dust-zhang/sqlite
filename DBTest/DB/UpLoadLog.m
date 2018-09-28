//
//  UpLoadLog.m
//  test
//
//  Created by dust.zhang on 2018/9/7.
//  Copyright © 2018年 dust.zhang. All rights reserved.
//

#import "UpLoadLog.h"
#import "BMKPDbManager.h"
#import "LogModel.h"


@interface UpLoadLog()
@property (nonatomic, retain)   NSTimer             *time;
@end


@implementation UpLoadLog

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static UpLoadLog * instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/*轮询上传日志
 interval: 时间间隔（秒）
*/
-(void) upLoadLog:(float)interval
{
    self.time = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(selectDbLog) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.time forMode:NSRunLoopCommonModes];
    
}

//暂停计时器
-(void) suspendTime
{
    [self.time setFireDate:[NSDate distantFuture]];
}

//重新开始计时器
-(void) reStartTime
{
    [self.time setFireDate:[NSDate date]];
}

//停止计时器
-(void) stopTime
{
    self.time = nil;
    [self.time invalidate];
}

//上传日志
-(void) selectDbLog
{
    //先读取数据
    NSMutableArray *arrLog = [[NSMutableArray alloc ] initWithCapacity:0];
    arrLog =  [[BMKPDbManager shareInstance] select:@"select * from table_bmkplog"];
    //如果存在数据，则上传到服务器
    if (arrLog.count > 0)
    {
        //遍历日志数据上传
        for (LogModel *model in arrLog)
        {
            //*********************************************
            //调用上传接口,上传成功则删除当前一条数据
            //*********************************************
            
            
            //删除当前数据
            [self deleteCurrentLog:model];
        }
    }
    else
    {
        //*********************************************
        //如果不存在数据，则暂停计时器
        //*********************************************
        [self suspendTime];
    }
}

/* 上传成功后删除数据
 model:要删除的数据model
 */
-(void) deleteCurrentLog:(LogModel *)model
{
    if ( ![[BMKPDbManager shareInstance] deleteAllData:model.logId])
    {
        //如果删除失败，重新调用删除方法，直到删除成功
        [self deleteCurrentLog:model];
        NSLog(@"删除日志失败");
    }
}


@end
