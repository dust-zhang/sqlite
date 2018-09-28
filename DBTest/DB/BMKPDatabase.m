//
//  BMKPDatabase.m
//  test
//
//  Created by dust.zhang on 2018/9/6.
//  Copyright © 2018年 dust.zhang. All rights reserved.
//

//此类的功能主要是创建数据库和表
//对数据库的操作在BMKPDbManager中实现

#import "BMKPDatabase.h"
#import <FMDB.h>
#import <sys/xattr.h>
// 数据库名字
#define BMKPDB_NAME  @"bmkp.db"
// 表
#define TABLE_NAME  @"CREATE TABLE IF NOT EXISTS table_bmkplog (id INTEGER PRIMARY KEY AUTOINCREMENT,logContent text)"


@implementation BMKPDatabase

/*
 初始化数据库和表
 return :  无返回值
 */
+ (void) initDb
{
    //创建数据库文件
    [self getDbPath];
    //创建数据库表
    [self createTable:TABLE_NAME];
}

/*
 获取数据库文件路径
 return :  返回数据库所在的路径
 */
+ (NSString *) getDbPath
{
    //获取Document文件夹下的数据库文件，没有则创建
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSLog(@"%@",docPath);
    return [docPath stringByAppendingPathComponent:BMKPDB_NAME];
}

/*
 审核不通过问题解决
 URL        :  数据库目录路径
 return     :  如果成功则返回true，失败返回false
 */
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if (NSURLIsExcludedFromBackupKey == nil)
    { // iOS <= 5.0.1
        const char* filePath = [[URL path] fileSystemRepresentation];
        const char* attrName = [[[NSBundle mainBundle]bundleIdentifier] cStringUsingEncoding:NSASCIIStringEncoding];
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
    else
    { // iOS >= 5.1
        NSError *error = nil;
        [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        return error == nil;
    }
}

/*
 创建table
 sql        :  创建数据库table的sql语句
 return     :  如果成功则返回true，失败返回false
 */
+(BOOL) createTable:(NSString *)sql
{
    //防止文件备份到icould
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[self getDbPath] ]];
    //获取数据库并打开
    FMDatabase *database  = [FMDatabase databaseWithPath:[self getDbPath]];
    if (![database open])
    {
        NSLog(@"Open database failed");
        return FALSE;
    }
    //创建栏目表
    if (![database executeUpdate:sql] )
    {
        [database close];
        return TRUE;
    }
    //关闭数据库
    [database close];
    return TRUE;
}

@end
