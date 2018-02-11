//
//  BaseDao.m
//  zhang qinglou
//
//  Created by mac on 15/8/17.
//  Copyright (c) 2017年 chinasns. All rights reserved.
//

#import "ZHBaseDao.h"

@interface ZHBaseDao()<ZHDatabaseHelperDelegate>
{
    NSString *table_version_flag;
    int table_version;
}

@property (nonatomic,weak) ZHDatabaseHelper *dbQueue;

@end

@implementation ZHBaseDao

- (instancetype)initWithTableVersionFlag:(NSString *)verFlag version:(int) ver{
    self = [super init];
    if (self) {
        table_version_flag = verFlag;
        table_version = ver;
        
        self.dbQueue = [ZHDatabaseHelper sharedInstance];
        [self.dbQueue addDelegate:self];
        
        if (self.dbQueue.isInited) {
            [self createOrUpdateTables];
        }
    }
    return self;
}

- (void)onCreateDatabaseFile{
    //当切换数据库文件时，进行数据表的更新或创建
    NSLog(@"onCreateDatabaseFile");
    [self createOrUpdateTables];
}

- (void)createOrUpdateTables{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //if ([db open]) {
            //检查当前表的版本号
            int curVer = 0;
            NSString * sql = [NSString stringWithFormat: @"SELECT %@ FROM %@ WHERE %@='%@'", DB_VERSION_TABLE_COLUME_VER ,DB_VERSION_TABLE_NAME, DB_VERSION_TABLE_COLUME_KEY,table_version_flag];
            FMResultSet * rs = [db executeQuery:sql];
            if ([rs next]) {
                curVer = [rs intForColumn:DB_VERSION_TABLE_COLUME_VER];
            }
            [rs close];
            
            
            //创建数据表、更新数据表
            if(curVer == 0){
                //创建表
                [self onCreate:db];
                
                //插入版本号
                [self insertVersion:db];
                
            }else if (curVer < table_version){
                //更新表
                [self onUpdate:db oldVer:curVer];
                
                //更新版本号
                [self updateVersion:db];
            }
            
           // [db close];
        //}

    }];
}

#pragma mark - 初始化数据库
//- (int) onInitDatabase{
//    return 0;
//}

#pragma mark - 创建或更新表回调
- (void) onCreate:(FMDatabase *)db{}
- (void) onUpdate:(FMDatabase *)db oldVer:(int)oldver{}

#pragma mark - 数据表的版本
- (void) insertVersion:(FMDatabase *)db{
    NSString *sql= [NSString stringWithFormat: @"INSERT INTO '%@' ('%@','%@') VALUES (%i,'%@')",
                    DB_VERSION_TABLE_NAME,
                    DB_VERSION_TABLE_COLUME_VER,DB_VERSION_TABLE_COLUME_KEY,
                    table_version, table_version_flag];
    BOOL res = [db executeUpdate:sql];
    if (res) {
        NSLog(@"成功! 更新表%@，版本号:%i",table_version_flag, table_version);
    }else{
        NSLog(@"失败! 更新表%@，版本号:%i",table_version_flag, table_version);
    }
}
- (void) updateVersion:(FMDatabase *)db{
    NSString *sql= [NSString stringWithFormat: @"UPDATE %@ SET %@=%i WHERE %@='%@'",
                           DB_VERSION_TABLE_NAME,
                           DB_VERSION_TABLE_COLUME_VER,table_version,
                           DB_VERSION_TABLE_COLUME_KEY, table_version_flag];
    BOOL res = [db executeUpdate:sql];
    if (res) {
        NSLog(@"成功! 更新表%@，版本号:%i",table_version_flag, table_version);
    }else{
        NSLog(@"失败! 更新表%@，版本号:%i",table_version_flag, table_version);
    }
}

#pragma mark - 异步插入数据
- (void) insertWithTableName:(NSString *)tableName contentValues:(NSDictionary *)dic result:(void(^)(BOOL))block{
    __block BOOL r = NO;
    
    [[ZHDatabaseHelper sharedInstance] inDatabase:^(FMDatabase * db) {
        NSEnumerator *enumerator = [dic keyEnumerator];
        id key;
        NSMutableString *keys = [NSMutableString string];
        NSMutableString *values = [NSMutableString string];
        while ((key = [enumerator nextObject])) {
            [keys appendFormat:@"%@,", key];
            [values appendFormat:@"'%@',", [dic objectForKey:key]];
        }
        
        //去掉逗号
        if (keys.length > 0) {
            [keys deleteCharactersInRange:NSMakeRange(keys.length-1, 1)];
        }
        if (values.length > 0) {
            [values deleteCharactersInRange:NSMakeRange(values.length-1, 1)];
        }
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO '%@' (%@) VALUES (%@)", tableName, keys, values];
        r = [db executeUpdate:sql];
    }];
    
    if (block) {
        block(r);
    }
}


#pragma mark - 异步更新数据
- (void) updateWithTableName:(NSString *)tableName contentValues:(NSDictionary *)dic where:(NSString*)where result:(void(^)(BOOL))block{
    __block BOOL r = NO;
    
    [[ZHDatabaseHelper sharedInstance] inDatabase:^(FMDatabase * db) {
        NSEnumerator *enumerator = [dic keyEnumerator];
        id key;
        NSMutableString *values = [NSMutableString string];
        while ((key = [enumerator nextObject])) {
            [values appendFormat:@"%@='%@',", key, [dic objectForKey:key]];
        }
        
        //去掉逗号
        if (values.length > 0) {
            [values deleteCharactersInRange:NSMakeRange(values.length-1, 1)];
        }
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE '%@' SET %@ ", tableName, values];
        if (where.length > 0) {
            [sql appendFormat:@" WHERE %@", where];
        }
        
        r = [db executeUpdate:sql];
    }];
    
    if (block) {
        block(r);
    }
}

#pragma mark - 异步删除数据
- (void) deleteWithTableName:(NSString *)tableName where:(NSString*)where result:(void(^)(BOOL))block{
    __block BOOL r = NO;
    
    [[ZHDatabaseHelper sharedInstance] inDatabase:^(FMDatabase * db) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM '%@' WHERE %@", tableName, where];
        r = [db executeUpdate:sql];
    }];
    
    if (block) {
        block(r);
    }
}

#pragma mark - 异步执行操作
- (void)executeInDatabaseWithBlock:(void(^)(FMDatabase * db))block{
    [[ZHDatabaseHelper sharedInstance] inDatabase:^(FMDatabase * db) {
        if (block) {
            block(db);
        }
    }];
}

#pragma mark - 异步事务操作
- (void)executeInTransactionWithBlock:(void(^)(FMDatabase * db, BOOL *rollback))block{
    [[ZHDatabaseHelper sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (block) {
            block(db,rollback);
        }
    }];
}

#pragma mark - 异步查询数据
- (void) queryWithTableName:(NSString *)tableName columes:(NSArray *)columes where:(NSString*)where order:(NSString *)orderBy block:(void(^)(FMResultSet *rs))block{
    
    [[ZHDatabaseHelper sharedInstance] inDatabase:^(FMDatabase * db) {
        
        NSString * columes_str = @"*";
        if (columes) {
            columes_str = [columes componentsJoinedByString:@","];
        }
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT %@ FROM '%@'", columes_str, tableName];
        
        if (where) {
            [sql appendFormat:@" WHERE %@", where];
        }
        
        if (orderBy) {
            [sql appendFormat:@" ORDER BY %@", orderBy];
        }
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if (block) {
            block(rs);
        }
        
        [rs close];
        
    }];
}

#pragma mark - 异步查询数据
- (void)queryWithSql:(NSString *)sql  block:(void(^)(FMResultSet *rs))block{
    [[ZHDatabaseHelper sharedInstance] inDatabase:^(FMDatabase * db) {
        FMResultSet *rs = [db executeQuery:sql];
        
        if (block) {
            block(rs);
        }
        
        [rs close];
    }];
}

//- (BOOL) vilidate{
//    if (cur_uid == [Config getUserId]) {
//        return YES;
//    }
//    return NO;
//}
@end
