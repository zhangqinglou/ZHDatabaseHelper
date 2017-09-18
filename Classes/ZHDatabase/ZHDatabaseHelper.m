//
//  DatabaseQueueHelper.m
//  Test2
//
//  Created by mac on 15/8/10.
//  Copyright (c) 2015年 chinasns. All rights reserved.
//

#import "ZHDatabaseHelper.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

@interface ZHDatabaseHelper()

@property (nonatomic,strong) FMDatabaseQueue * mQueue;
@property (nonatomic,strong) FMDatabase *mDb;
@property (nonatomic,strong) NSString *databaseFile ;

@property (nonatomic,strong) NSMutableArray *arr;

@property (nonatomic,assign) int currentUID;
@end

@implementation ZHDatabaseHelper

+ (ZHDatabaseHelper *) sharedInstance{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _isInited = NO;
        _arr = [NSMutableArray array];
        int uid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"db_uid"] intValue];
        if (uid > 0) {
            [self createDatabaseWithUID:uid];
        }
    }
    return self;
}

- (void) addDelegate:(id<ZHDatabaseHelperDelegate>)delegate{
    NSValue *value = [NSValue valueWithNonretainedObject:delegate];
    [self.arr addObject:value];
}

- (void) createDatabaseWithUID:(int)UID{
    @synchronized (self) {
        if (self.isInited && self.currentUID == UID) {
            NSLog(@"DatabaseHelper is inited");
            return;
        }
        
        //获取UID,如果UID为0，则不创建。
        if(UID <= 0){
            self.mQueue = nil;
            [NSException raise:@"Create database UID value error!" format:@"UID Must be greater than 0"];
            return;
        }
        self.currentUID = UID;
        
        //初始化数据库
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.databaseFile = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"database_%i.db",UID]];
        self.mQueue = [FMDatabaseQueue databaseQueueWithPath:self.databaseFile];
        _isInited = YES;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.currentUID] forKey:@"db_uid"];
        
        //创建版本号表
        [self inDatabase:^(FMDatabase *db) {
            NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' INTEGER, '%@' TEXT)",DB_VERSION_TABLE_NAME,@"_id",DB_VERSION_TABLE_COLUME_KEY,DB_VERSION_TABLE_COLUME_VER,@"desc"];
            BOOL res = [db executeUpdate:sqlCreateTable];
            if (!res) {
                NSLog(@"error when creating db_version table");
            } else {
                NSLog(@"success to creating db_version table");
            }
        }];
        
        for (int i=0; i<_arr.count; i++) {
            NSValue *value = [_arr objectAtIndex:i];
            id<ZHDatabaseHelperDelegate> delegate = [value nonretainedObjectValue];
            if (delegate && [delegate respondsToSelector:@selector(onCreateDatabaseFile)]) {
                [delegate onCreateDatabaseFile];
            }
        }
    }
}

//重新设置数据库
- (void) resetDatabaseWithUID:(int)UID{
    if (self.currentUID == UID && self.isInited) {
        return;
    }
    _isInited = NO;
    [self createDatabaseWithUID:UID];
}


#pragma mark - 异步操作数据表，添加、更新、删除
- (void) inDatabase:(void(^)(FMDatabase *))block{
    if (!_isInited) {
        [NSException raise:@"DatabaseHelper is not init!" format:@"You must first call createDatabaseWithUID:"];
        return;
    }
    
    [self.mQueue inDatabase:^(FMDatabase *db) {
        block(db);
    }];
    
}

- (void) inTransaction:(void(^)(FMDatabase *db, BOOL *rollback)) block{
    if (!_isInited) {
        [NSException raise:@"DatabaseHelper is not init!" format:@"You must first call createDatabaseWithUID:"];
        return;
    }
    
    [self.mQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        block(db, rollback);
    }];
}

- (void)dealloc{
    _isInited = NO;
    [self.mDb close];
    [self.mQueue close];
    [self.arr removeAllObjects];
    self.arr = nil;
}

@end
