//
//  UserDataManager.m
//  TiantianCab
//
//  Created by Johnil on 12-7-26.
//  Copyright (c) 2012年 Johnil. All rights reserved.
//

#import "UserDataManager.h"
#import "NSData+Additions.h"
#define DATA_KEY @"TiantianCabUserDefaultData"
#define DATA_FILE_PATH [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/userData.piiic"]
#define DATA_PLIST_PATH [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/userData.plist"]
#define DATA_FILE_AESKEY @"tiantiandachekey"
static NSMutableDictionary *_userData;
static UserDataManager *_manager;

@implementation UserDataManager

- (BOOL)saveData:(NSDictionary *)dict{
    NSLog(@"save user data");
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:DATA_KEY];
    [archiver finishEncoding];
    [archiver release];
    
    BOOL temp = [[data AES256EncryptWithKey:DATA_FILE_AESKEY] writeToFile:DATA_FILE_PATH atomically:YES];
    [data release];
    return temp;
}

- (NSMutableDictionary *)loadData{
    NSLog(@"Load user data %@", DATA_FILE_PATH);
    if ([[NSFileManager defaultManager] fileExistsAtPath:DATA_FILE_PATH]) {
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:DATA_FILE_PATH];
        data = [data AES256DecryptWithKey:DATA_FILE_AESKEY];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSDictionary *myDictionary = [unarchiver decodeObjectForKey:DATA_KEY];
        [unarchiver finishDecoding];
        [unarchiver release];
        return [[NSMutableDictionary alloc] initWithDictionary:myDictionary];
    } else {
        NSLog(@"user data file not exists");
        return nil;
    }
}

+ (NSMutableDictionary *)defaultUserData{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        if (_manager == nil) {
            _manager = [[UserDataManager alloc] init];
            _userData = [_manager loadData];
            if (_userData == nil) {
                _userData = [[NSMutableDictionary alloc] init];
            }
        }
    });
    return _userData;
}

+ (BOOL)synchronizeUserData{
    if (_manager == nil || _userData == nil) {
        NSLog(@"没有需要同步的数据");
        return NO;
    }
#ifdef DEBUG
        NSLog(@"DEBUG模式,将plist存入document用于查看.");
        [_userData writeToFile:DATA_PLIST_PATH atomically:YES];
#endif
    return [_manager saveData:_userData];
}

+ (void)releaseUserData{
    [_userData removeAllObjects];
    [_userData release];
    _userData = nil;
    
    [_manager release];
    _manager = nil;
}

+ (BOOL)clearCacheData{
    if ([[NSFileManager defaultManager] fileExistsAtPath:DATA_PLIST_PATH]) {
        NSLog(@"清除plist缓存.");
        return [[NSFileManager defaultManager] removeItemAtPath:DATA_PLIST_PATH error:nil];
    }
    return YES;
}

- (void)dealloc{
    NSLog(@"%@ dealloc", self);
    [super dealloc];
}

@end
