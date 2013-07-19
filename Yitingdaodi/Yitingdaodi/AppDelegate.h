//
//  AppDelegate.h
//  yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
@class ListViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NavigationController *navigationController;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) ListViewController *list;

- (void)enterApp;

@end
