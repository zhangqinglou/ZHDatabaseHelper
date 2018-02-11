//
//  PersonDao.m
//  databaseTest
//
//  Created by mac on 2017/9/14.
//  Copyright © 2017年 chinasns. All rights reserved.
//

#import "PersonDao.h"
#import "Person.h"

#define TABLE_VERSION_VALUE @"person_version"   //用户表的标记，每个表的标记不同
#define TABLE_VERSION 3 //当前表的版本，数据表结构变化时将数值增加，会调用onUpdate：：方法进行修改表结构

@implementation PersonDao

+ (PersonDao *) sharedInstance{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init{
    self = [super initWithTableVersionFlag:TABLE_VERSION_VALUE version:TABLE_VERSION];
    if (self) {
        
    }
    return self;
}

#pragma mark - 数据表的创建和更新
- (void)onCreate:(FMDatabase *)db{
    [db executeUpdate:[Person sqlCreateTable]];
}
- (void)onUpdate:(FMDatabase *)db oldVer:(int)oldver{
    switch (oldver) {
        case 1:
            //添加字段，工作
            [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ VARCHAR(50)", PERSON_TABLE_NAME, PERSON_COLUME_WORK]];
        case 2:
            //添加字段，性别
            [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", PERSON_TABLE_NAME, PERSON_COLUME_GENDER]];
    }
}


#pragma mark - 数据表的增删改查
- (void)insertPerson:(Person *)p block:(void(^)(BOOL))block{
    [super insertWithTableName:PERSON_TABLE_NAME contentValues:[p tableContentValues] result:block];
}

- (void)updatePersonAddress:(NSString *)address Id:(int)ID block:(void (^)(BOOL))block{
    if (ID<0) {
        return;
    }
    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:address,PERSON_COLUME_ADDRESS,nil];
    [self updateWithTableName:PERSON_TABLE_NAME contentValues:values where:[NSString stringWithFormat:@"%@=%i",PERSON_COLUME_ID,ID] result:block];
}

- (void)deletePersonWithId:(int)ID block:(void(^)(BOOL))block{
    if (ID<0) {
        return;
    }
    NSString *where = [NSString stringWithFormat:@"%@=%i",PERSON_COLUME_ID,ID];
    [self deleteWithTableName:PERSON_TABLE_NAME where:where result:block];
}

- (Person *)getPersonWithName:(NSString *)name{
    __block Person *p = nil;
    [self queryWithTableName:PERSON_TABLE_NAME columes:nil where:[NSString stringWithFormat:@"%@='%@'",PERSON_COLUME_NAME,name] order:nil block:^(FMResultSet *rs) {
        if ([rs next]) {
            p = [[Person alloc] initWithResultSet:rs];
        }
    }];
    return p;
}

- (NSArray *)listAllPerson{
    __block NSMutableArray *arr = [[NSMutableArray alloc] init];
    [super queryWithTableName:PERSON_TABLE_NAME columes:nil where:nil order:nil block:^(FMResultSet *rs) {
        while ([rs next]) {
            [arr addObject:[[Person alloc] initWithResultSet:(FMResultSet *)rs]];
        }
    }];
    
    return arr;
}


- (void) insertOrUpdatePerson:(Person *)p block:(void(^)(int))block{
    if (p == nil) {
        block(-1);
        return ;
    }
    
    [self executeInDatabaseWithBlock:^(FMDatabase *db) {
        [self insertOrUpdatePerson:p db:db];
        
    }];
    
//    if (block) {
//        block(p.ID);
//    }
}

- (void)insertOrUpdatePerson:(Person *)p db:(FMDatabase *)db{
    
    NSDictionary *dic = [p tableContentValues];
    NSEnumerator *enumerator = [dic keyEnumerator];
    
    if (p.ID > 0) {
        id key;
        //更新数据
        NSMutableString *values = [NSMutableString string];
        while ((key = [enumerator nextObject])) {
            [values appendFormat:@"%@='%@',", key, [dic objectForKey:key]];
        }
        
        //去掉逗号
        if (values.length > 0) {
            [values deleteCharactersInRange:NSMakeRange(values.length-1, 1)];
        }
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE '%@' SET %@ WHERE %@='%i'", PERSON_TABLE_NAME, values, PERSON_COLUME_ID, p.ID];
        [db executeUpdate:sql];
    }else{
        //插入数据
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
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO '%@' (%@) VALUES (%@)", PERSON_TABLE_NAME, keys, values];
        [db executeUpdate:sql];
    }
}

@end
