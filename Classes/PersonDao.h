//
//  PersonDao.h
//  databaseTest
//
//  Created by mac on 2017/9/14.
//  Copyright © 2017年 chinasns. All rights reserved.
//

#import "ZHBaseDao.h"

@class Person;
@interface PersonDao : ZHBaseDao

+ (PersonDao *) sharedInstance;

- (void)insertPerson:(Person *)p block:(void(^)(BOOL))block;
- (void)updatePersonAddress:(NSString *)address Id:(int)ID block:(void (^)(BOOL))block;
- (void)deletePersonWithId:(int)ID block:(void(^)(BOOL))block;

- (Person *)getPersonWithName:(NSString *)name;
- (NSArray *)listAllPerson;

- (void) insertOrUpdatePerson:(Person *)p block:(void(^)(int))block;
@end
