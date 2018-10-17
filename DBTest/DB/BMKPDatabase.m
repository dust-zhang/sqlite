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
#import "FMDB.h"
#import "LogModel.h"
#import <sys/xattr.h>
#import <objc/runtime.h>

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
    return [docPath stringByAppendingPathComponent:DB_NAME];
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
+(BOOL) createTable:(NSString *)tableName
{
     NSString * strSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (logId INTEGER PRIMARY KEY AUTOINCREMENT)", tableName];
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
    if ([database executeUpdate:strSql] )
    {
        NSMutableArray * arrProList = [self getModelProperty];
        // 动态插入列
        for (int i = 0; i<arrProList.count; i++)
        {
            NSString * colName = arrProList[i];
            if (![database columnExists:colName inTableWithName:tableName])
            {
                //logId 自增字段，已经创建，不需要重复创建
                if (![colName isEqualToString: @"logId"])
                {
                    NSString * alerColStr = [NSString stringWithFormat:@"AlTER TABLE %@ ADD %@ TEXT", tableName, colName];
                    BOOL isSuccess = [database executeUpdate:alerColStr];
                    if (isSuccess)
                    {
                        NSLog(@"插入新key成功 = %@", colName);
                    }
                    else
                    {
                        NSLog(@"插入新key失败 = %@", colName);
                    }
                }
            }
        }
        
        [database commit];
        [database close];
        return TRUE;
    }
    //关闭数据库
    [database close];
    return TRUE;
}

/*
 获取模型的属性,通过runtime, 并返回属性列表
 model : 要插入的model
 return  :返回model字段数组
 */
+(NSMutableArray *)getModelProperty {
    LogModel *model = [[LogModel alloc ] init];
    u_int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    NSMutableArray * arrM = @[].mutableCopy;
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *str = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        [arrM addObject:str];
    }
    return arrM;
}

@end
