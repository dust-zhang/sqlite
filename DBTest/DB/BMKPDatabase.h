//
//  BMKPDatabase.h
//  test
//
//  Created by dust.zhang on 2018/9/6.
//  Copyright © 2018年 dust.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
// 数据库名字
#define DB_NAME  @"bmkp_location.db"
// 表
#define TABLE_NAME @"tableTrackLog"

@interface BMKPDatabase : NSObject

//初始化数据库
+ (void) initDb;
//获取数据库路径
+ (NSString *) getDbPath;

@end
