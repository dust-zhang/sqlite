//
//  BMKPDatabase.h
//  test
//
//  Created by dust.zhang on 2018/9/6.
//  Copyright © 2018年 dust.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMKPDatabase : NSObject

//初始化数据库
+ (void) initDb;
//获取数据库路径
+ (NSString *) getDbPath;

@end
