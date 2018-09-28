//
//  BMKPDbManager.h
//  test
//
//  Created by dust.zhang on 2018/9/6.
//  Copyright © 2018年 dust.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BMKPDbManager : NSObject

+(instancetype)shareInstance;

//插入数据
-(BOOL) insert:(NSString *)content;

//查找数据
-(NSMutableArray *) select:(NSString *)sql;

//删除数据
-(BOOL) deleteAllData : (NSNumber *)logId;


@end
