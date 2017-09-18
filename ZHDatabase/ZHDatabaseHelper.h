//
//  DatabaseQueueHelper.h
//  Test2
//
//  Created by mac on 15/8/10.
//  Copyright (c) 2015年 chinasns. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DB_VERSION_TABLE_NAME @"db_version"
#define DB_VERSION_TABLE_COLUME_KEY @"key"
#define DB_VERSION_TABLE_COLUME_VER @"version"


@class  FMDatabase;
@class FMResultSet;

@protocol ZHDatabaseHelperDelegate <NSObject>

- (void) onCreateDatabaseFile;

@end

@interface ZHDatabaseHelper : NSObject

@property (nonatomic,assign, readonly) BOOL isInited;

+ (ZHDatabaseHelper *) sharedInstance;
- (void) createDatabaseWithUID:(int)UID;
- (void) resetDatabaseWithUID:(int)UID;

- (void) inDatabase:(void(^)(FMDatabase *))block;
- (void) inTransaction:(void(^)(FMDatabase *db, BOOL *rollback)) block;

- (void) addDelegate:(id<ZHDatabaseHelperDelegate>)delegate;
@end
