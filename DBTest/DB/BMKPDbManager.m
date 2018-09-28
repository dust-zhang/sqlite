//
//  BMKPDbManager.m
//  test
//
//  Created by dust.zhang on 2018/9/6.
//  Copyright © 2018年 dust.zhang. All rights reserved.
//

/*对数据库的操作都在该类中实现
 基本语法
 1.插入数据 insert into table values('test')
 2.删除数据 delete from table
 3.修改数据 update table 字段='test' where 字段 = ‘test’
 4.查找数据 select * from table
  4.1 查找指定条件的内容 select * from table where 字段='条件'
*/


#import "BMKPDbManager.h"
#import "BMKPDatabase.h"
#import <FMDB.h>
#import <sys/xattr.h>
#import "LogModel.h"

@interface BMKPDbManager()
@property (nonatomic, retain)   NSLock *lock;
@property (nonatomic, retain)   dispatch_queue_t queue;
@end

@implementation BMKPDbManager

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static BMKPDbManager * instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void) initQueue
{
    if (!self.queue)
    {
        self.queue = dispatch_queue_create("com.bmkp.BMKP_log.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    if (!self.lock)
    {
        self.lock = [[NSLock alloc ] init];
    }
}
/*
 将数据插入到数据库
 content : 要插入的字段数据
 return  :  如果成功则返回true，失败返回false
 */
-(BOOL) insert:(NSString *)content
{
    [self initQueue];
    
    FMDatabase *database  = [FMDatabase databaseWithPath:[BMKPDatabase getDbPath]];
    if (![database open])
    {
        NSLog(@"Open database failed");
        return FALSE;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        [weakSelf.lock lock];
        [database executeUpdate:@"insert into table_bmkplog values (null,?)",content];
        [database close];
        [weakSelf.lock unlock];
    });
    
    return TRUE;
}

/*
 删除数据
 logId  :  日志id
 return :  如果成功则返回true，失败返回false
 */
-(BOOL) deleteAllData : (NSNumber *)logId
{
    [self initQueue];
    NSString * sql = [NSString stringWithFormat:@"delete from table_bmkplog where id ='%@' ",logId ];
    FMDatabase *database  = [FMDatabase databaseWithPath:[BMKPDatabase getDbPath]];
    if (![database open])
    {
        NSLog(@"Open database failed");
        return FALSE;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        [weakSelf.lock lock];
        [database executeUpdate:sql ];
        [database close];
        [weakSelf.lock unlock];
    });
    
    return TRUE;
}

/*
 更新数据库数据（（（（（暂时日志不需要修改数据））））））
 sql    :  查找数据的sql命令
 return :  如果成功则返回true，失败返回false
 */
-(BOOL) update:(NSString *)sql
{
    [self initQueue];
    //获取数据库并打开
    FMDatabase *database  = [FMDatabase databaseWithPath:[BMKPDatabase getDbPath]];
    if (![database open])
    {
        NSLog(@"Open database failed");
        return FALSE;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        [weakSelf.lock lock];
        [database executeUpdate:sql ];
        [database close];
        [weakSelf.lock unlock];
    });
    
    return TRUE;
}

/*
 从数据库中查找数据
 sql    :  查找数据的sql命令
 return :  如果存在数据则返回数据list，没有数据返回空list
 */
-(NSMutableArray *) select:(NSString *)sql
{
    [self initQueue];
    
    FMDatabase *database  = [FMDatabase databaseWithPath:[BMKPDatabase getDbPath]];
    if (![database open])
    {
        NSLog(@"Open database failed");
    }
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    FMResultSet* set = [database executeQuery:sql];
    //同步取出数据，然后在返回结果
    dispatch_sync(self.queue, ^{
        [weakSelf.lock lock];
        while ([set next])
        {
            LogModel * model= [[LogModel alloc ] init ];
            model.Content = [set stringForColumn:@"logContent"];
            model.logId = [NSNumber numberWithInt:[[set stringForColumn:@"id"] intValue]];
            [array addObject:model];
        }
        [database close];
        [weakSelf.lock unlock];
    });
    return array;
    
}


@end
