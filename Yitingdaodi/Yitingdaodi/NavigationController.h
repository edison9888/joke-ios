//
//  NavigationController.h
//  TiantianCab
//
//  Created by Johnil on 13-5-16.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationBar.h"

@interface NavigationController : UINavigationController

@property (nonatomic, strong) NavigationBar *bar;

- (void)showBar;
- (void)hideBar;

@end
