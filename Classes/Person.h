//
//  Person.h
//  databaseTest
//
//  Created by mac on 2017/9/14.
//  Copyright © 2017年 chinasns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

#define PERSON_TABLE_NAME @"person_info"

#define PERSON_COLUME_ID @"_id"
#define PERSON_COLUME_NAME @"name"
#define PERSON_COLUME_ICON @"icon"
#define PERSON_COLUME_ADDRESS @"address"

//版本2时新增字段
#define PERSON_COLUME_WORK @"work"
//版本3时新增字段
#define PERSON_COLUME_GENDER @"gender"

@interface Person : NSObject

@property (nonatomic, assign) int ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *work;   //版本2时新增字段
@property (nonatomic, assign) int gender; //版本3时新增字段

+ (NSString *) sqlCreateTable;
- (NSDictionary *) tableContentValues;
- (instancetype)initWithResultSet:(FMResultSet *)rs;

@end
