//
//  Person.m
//  databaseTest
//
//  Created by mac on 2017/9/14.
//  Copyright © 2017年 chinasns. All rights reserved.
//

#import "Person.h"

@implementation Person


+ (NSString *) sqlCreateTable{
    NSMutableString *mSql = [NSMutableString string];
    [mSql appendFormat:@"CREATE TABLE IF NOT EXISTS '%@' ", PERSON_TABLE_NAME];
    [mSql appendString:@" ( "];
    [mSql appendFormat:@" '%@' INTEGER PRIMARY KEY AUTOINCREMENT, ", PERSON_COLUME_ID];
    [mSql appendFormat:@" '%@' VARCHAR(100), ", PERSON_COLUME_NAME];
    [mSql appendFormat:@" '%@' VARCHAR(100), ", PERSON_COLUME_ICON];
    [mSql appendFormat:@" '%@' VARCHAR(100), ", PERSON_COLUME_ADDRESS];
    [mSql appendFormat:@" '%@' VARCHAR(50), ", PERSON_COLUME_WORK];//版本2时新增字段
    [mSql appendFormat:@" '%@' INTEGER ", PERSON_COLUME_GENDER];//版本3时新增字段
    [mSql appendString:@" ) "];
    
    return mSql;
}


- (NSDictionary *) tableContentValues{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (_name) {
        [dic setObject:_name forKey:PERSON_COLUME_NAME];
    }
    if (_icon) {
        [dic setObject:_icon forKey:PERSON_COLUME_ICON];
    }
    if (_address) {
        [dic setObject:_address forKey:PERSON_COLUME_ADDRESS];
    }

    [dic setObject:[NSNumber numberWithInt:_gender] forKey:PERSON_COLUME_GENDER];
    
    if (_work) {
        [dic setObject:_address forKey:PERSON_COLUME_ADDRESS];
    }
    return dic;
}

- (instancetype)initWithResultSet:(FMResultSet *)rs{
    self = [super init];
    if (self) {
        _ID = [rs intForColumn:PERSON_COLUME_ID];
        _name = [rs stringForColumn:PERSON_COLUME_NAME];
        _icon = [rs stringForColumn:PERSON_COLUME_ICON];
        _address = [rs stringForColumn:PERSON_COLUME_ADDRESS];
        _gender = [rs intForColumn:PERSON_COLUME_GENDER];
        _work = [rs stringForColumn:PERSON_COLUME_WORK];

    }
    return self;
}

@end
