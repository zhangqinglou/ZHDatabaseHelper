//
//  BaseDao.h
//  quameeting
//
//  Created by mac on 15/8/17.
//  Copyright (c) 2015年 chinasns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHDatabaseHelper.h"
#import "FMDatabase.h"

/** BaseDaoProtocol,代理回调方法
 */
@protocol ZHBaseDaoProtocol <NSObject>

@required
/** 创建数据表方法回调，在第一次创建表时调用。

 参数：db数据库对像，通过执行sql语句创建表。
 */
- (void) onCreate:(FMDatabase *)db;


/** 更新数据表方法回调，每次升级数据表版本时调用。
 
 参数：db数据库对像，通过执行sql语句更新表结构。
        oldver更新前数据表的版本号
 */
- (void) onUpdate:(FMDatabase *)db oldVer:(int)oldver;

@end


/** BaseDao 基本数据表操作类，继承该类可以对数据表进行创建、修改、数据的操作等。
 */
@interface ZHBaseDao : NSObject <ZHBaseDaoProtocol>

/** 初始化数据表,如果数据表未创建，则创建表。
 
 参数：versionFlag：表标记，每个表的唯一标记
    version: 最新版本号，对数据表升级时ver增加
 */
- (instancetype)initWithTableVersionFlag:(NSString *)verFlag version:(int) ver;

#pragma mark - 数据表异步操作
- (void) insertWithTableName:(NSString *)tableName contentValues:(NSDictionary *)dic result:(void(^)(BOOL))block;
- (void) updateWithTableName:(NSString *)tableName contentValues:(NSDictionary *)dic where:(NSString*)where result:(void(^)(BOOL))block;
- (void) deleteWithTableName:(NSString *)tableName where:(NSString*)where result:(void(^)(BOOL))block;
- (void) executeInDatabaseWithBlock:(void(^)(FMDatabase * db))block;
- (void) executeInTransactionWithBlock:(void(^)(FMDatabase * db, BOOL *rollback))block;
- (void) queryWithTableName:(NSString *)tableName columes:(NSArray *)columes where:(NSString*)where order:(NSString *)orderBy block:(void(^)(FMResultSet *rs))block;
- (void) queryWithSql:(NSString *)sql block:(void(^)(FMResultSet *rs))block;

//- (BOOL) vilidate;
@end
