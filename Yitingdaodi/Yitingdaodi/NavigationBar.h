//
//  NavigationBar.h
//  TiantianCab
//
//  Created by Johnil on 13-5-16.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBar : UIView <UINavigationControllerDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leftBtn;

- (void)push;
- (void)pop;
- (void)fadeIn;
- (void)fadeOut;

@end