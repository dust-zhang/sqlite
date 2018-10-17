//
//  LogModel.h
//  test
//
//  Created by dust.zhang on 2018/9/6.
//  Copyright © 2018年 dust.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogModel : NSObject
@property ( nonatomic, strong ) NSNumber *logId;
@property ( nonatomic, strong ) NSString *deviceKey;
@property ( nonatomic, strong ) NSString *drvId;
@property ( nonatomic, strong ) NSString *deviceTime;
@property ( nonatomic, strong ) NSString *walkerPhone;
//@property ( nonatomic, strong ) NSString *errorCount;
@property ( nonatomic, strong ) NSString *altitude;
@property ( nonatomic, strong ) NSString *direction;
@property ( nonatomic, strong ) NSString *time;
@property ( nonatomic, strong ) NSString *latitude;
@property ( nonatomic, strong ) NSString *longtitude;
@property ( nonatomic, strong ) NSString *orderId;
@property ( nonatomic, strong ) NSString *phoneTime;
@property ( nonatomic, strong ) NSString *speed;
@property ( nonatomic, strong ) NSString *locType;



@end
