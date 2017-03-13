//
//  GXFMDatabaseTool.h
//  GXFMDataBaseDemo
//
//  Created by yingcan on 17/3/7.
//  Copyright © 2017年 guoxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface GXFMDatabaseHelper : NSObject
+ (FMDatabaseQueue *)getSharedDatabaseQueue;
@end

@interface GXFMDatabaseManager : NSObject

+ (GXFMDatabaseManager *)shareDBManager;
//保存或更新当前用户信息
- (void)savePersonDataWithDict:(NSDictionary *)dict userId:(NSString *)userId;
@end
