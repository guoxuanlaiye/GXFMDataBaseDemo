//
//  GXFMDatabaseTool.m
//  GXFMDataBaseDemo
//
//  Created by yingcan on 17/3/7.
//  Copyright © 2017年 guoxuan. All rights reserved.
//

#import "GXFMDatabaseManager.h"

@implementation GXFMDatabaseHelper
#pragma mark - 创建一个唯一的FMDB队列
+ (FMDatabaseQueue *)getSharedDatabaseQueue {
    static FMDatabaseQueue * my_FMDatabaseQueue = nil;
    if (!my_FMDatabaseQueue) {
        NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"database.db"];
        my_FMDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return my_FMDatabaseQueue;
}
@end

@interface GXFMDatabaseManager ()
@property (nonatomic, strong) FMDatabaseQueue * queue;
@end

#pragma mark - 该变量为判断是否需要更新数据库表结构，DB表结构中字段发生改变时，该变量递增
static NSInteger dbVersionFlg = 1;

@implementation GXFMDatabaseManager
+ (GXFMDatabaseManager *)shareDBManager {
    
    static GXFMDatabaseManager * instanceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceManager = [[GXFMDatabaseManager alloc]init];
        
        [instanceManager initDBManager];
    });
    return instanceManager;
}
//初始化DBManager，判断数据库版本信息
- (void)initDBManager {
    
    if ([self isExistDB]) { //存在数据库，说明不是第一次安装
        NSLog(@"----- 不是第一次安装 -----");

        self.queue = [GXFMDatabaseHelper getSharedDatabaseQueue];
        //取出上一次存储的版本号
        NSString * currentVersion = [self getDBInfoValue];
        
        if (dbVersionFlg > currentVersion.integerValue) { //需要升级
            
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:[self getDBPath]];
            
            if (bRet) {
                NSError * err;
                //移除原来的 db文件
                [fileMgr removeItemAtPath:[self getDBPath] error:&err];
                if (err == nil) {
                    //重新创建 db文件
                    NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"database.db"];
                    self.queue = [FMDatabaseQueue databaseQueueWithPath:path];
                    //建表
                    [self createTable];
                    //存版本号
                    [self setDBInfoValueWithString:[NSString stringWithFormat:@"%ld",dbVersionFlg]];
                }
            }
        }
    } else { //不存在，是第一次安装
        
        NSLog(@"----- 第一次安装 -----");

        //队列初始化并创建数据库
        self.queue = [GXFMDatabaseHelper getSharedDatabaseQueue];
        //建表
        [self createTable];
        //存版本号
        [self setDBInfoValueWithString:[NSString stringWithFormat:@"%ld",dbVersionFlg]];
    }
}
//Private - 判断是否存在数据库
-(BOOL)isExistDB {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:[self getDBPath]];
}
//Private - 数据库路径
-(NSString *)getDBPath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"database.db"];
}
#pragma mark - 创建版本信息
- (void)setDBInfoValueWithString:(NSString *)string {
    
    NSLog(@"----- 存储版本号 -----");

    [self.queue inDatabase:^(FMDatabase *db) {
        NSString * sq = [NSString stringWithFormat:@"SELECT * FROM t_info WHERE version = '%@';",string];
        FMResultSet * s = [db executeQuery:sq];
        //没存在，插入
        if (![s next]) {
            
            [db executeUpdateWithFormat:@"INSERT INTO t_info(version) VALUES(%@);",string];
            
        } else {
            [db executeUpdateWithFormat:@"UPDATE t_info SET version = '%@';",string];
            
        }
        [s close];
    }];
}
#pragma mark - 读取DB中的版本信息
- (NSString *)getDBInfoValue {
    
    
    __block NSString * version = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        
        NSString * sql = @"SELECT * FROM t_info";
        FMResultSet * set = [db executeQuery:sql];
        
        while ([set next]) {
            version = [set objectForColumnName:@"version"];
        }
        [set close];
        
    }];
    return version;
}
#pragma mark - 创建DB表
- (void)createTable {
    
    NSLog(@"----- 创建表 -----");
    [self.queue inDatabase:^(FMDatabase *db) {
        //版本号表
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_info (version text);"];
        //个人信息表
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_person (userId text PRIMARY KEY,name text,avatar text,phone text);"];

    }];
}
#pragma mark - Public 保存或更新当前用户信息
- (void)savePersonDataWithDict:(NSDictionary *)dict userId:(NSString *)userId {

    [self.queue inDatabase:^(FMDatabase *db) {
       
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM t_person WHERE userId = '%@';",userId];
        FMResultSet * set = [db executeQuery:sql];
        if (![set next]) {
            //没存在，插入
            [db executeUpdateWithFormat:
             @"INSERT INTO t_person (userId,name,avatar,phone) VALUES (%@,%@,%@,%@);",
             dict[@"userId"],
             dict[@"name"],
             dict[@"avatar"],
             dict[@"phone"]];
        } else {
            //存在，刷新
            [db executeUpdateWithFormat:@"UPDATE t_person SET userId = '%@',name = '%@',avatar = '%@',phone = '%@' WHERE userId = '%@';",
             dict[@"userId"],
             dict[@"name"],
             dict[@"avatar"],
             dict[@"phone"],
             dict[@"userId"]];
        }
        [set close];
    }];
}
@end
