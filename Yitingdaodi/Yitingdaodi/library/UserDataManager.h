//
//  UserDataManager.h
//  TiantianCab
//
//  Created by Johnil on 12-7-26.
//  Copyright (c) 2012年 Johnil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataManager : NSObject

+ (NSMutableDictionary *)defaultUserData;
+ (BOOL)synchronizeUserData;
+ (void)releaseUserData;
+ (BOOL)clearCacheData;

@end
