//
//  NavigationBar.m
//  TiantianCab
//
//  Created by Johnil on 13-5-16.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "NavigationBar.h"
#import <QuartzCore/QuartzCore.h>

@implementation NavigationBar {
}

- (id)init{
    self = [super initWithFrame:CGRectMake(0, 20, 320, 59)];
    if (self) {
        UIImageView *bg = [[UIImageView alloc] initWithImage:imageNamed(@"navi_bg.png")];
        bg.alpha = .9;
        [self addSubview:bg];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 59)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.font = [UIFont systemFontOfSize:20];
        [self addSubview:_titleLabel];
        _titleLabel.text = @"title";
        
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(65, 0, 50, 59);
        [_leftBtn setImage:imageNamed(@"back_btn.png") forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
        _leftBtn.alpha = 0;
        [self addSubview:_leftBtn];
    }
    return self;
}

- (void)fadeIn{
    __block CGRect frame = _titleLabel.frame;
    frame.origin.x = 50;
    _titleLabel.frame = frame;
    
    frame = _leftBtn.frame;
    frame.origin.x = 15;
    [UIView animateWithDuration:.3 animations:^{
        _leftBtn.alpha = 1;
        _leftBtn.frame = frame;
        frame = _titleLabel.frame;
        frame.origin.x = 0;
        _titleLabel.frame = frame;
    }];
}

- (void)fadeOut{
    __block CGRect frame = _leftBtn.frame;
    frame.origin.x = 65;
    [UIView animateWithDuration:.3 animations:^{
        _leftBtn.alpha = 0;
        _leftBtn.frame = frame;
        frame = _titleLabel.frame;
        frame.origin.x = 50;
        _titleLabel.frame = frame;
    }];
}

- (void)popView{
    [navi popViewControllerAnimated:YES];
    [self pop];
}

- (void)push{
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = _leftBtn.frame;
        frame.origin.x = -35;
        _leftBtn.frame = frame;
        frame = _titleLabel.frame;
        frame.origin.x = -50;
        _titleLabel.frame = frame;
        
        _titleLabel.alpha = .3;
        _leftBtn.alpha = .3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^{
            CGRect frame = _leftBtn.frame;
            frame.origin.x = 15;
            _leftBtn.frame = frame;
            frame = _titleLabel.frame;
            frame.origin.x = 0;
            _titleLabel.frame = frame;
            
            _titleLabel.alpha = 1;
            _leftBtn.alpha = 1;
        }];
    }];
}

- (void)pop{
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = _leftBtn.frame;
        frame.origin.x = 65;
        _leftBtn.frame = frame;
        frame = _titleLabel.frame;
        frame.origin.x = 50;
        _titleLabel.frame = frame;
        
        _titleLabel.alpha = .3;
        _leftBtn.alpha = .3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^{
            CGRect frame = _leftBtn.frame;
            frame.origin.x = 15;
            _leftBtn.frame = frame;
            frame = _titleLabel.frame;
            frame.origin.x = 0;
            _titleLabel.frame = frame;
            
            _titleLabel.alpha = 1;
            _leftBtn.alpha = 1;
        }];
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    if ([navigationController.viewControllers indexOfObject:viewController]==1 && ![viewController isKindOfClass:NSClassFromString(@"MainViewController")]) {
//        if (naviBar.leftBtn.alpha==0) {
//            [naviBar fadeIn];
//        }
//    }
    if ([viewController isKindOfClass:NSClassFromString(@"ListViewController")]) {
        [navi hideBar];
        if (naviBar.leftBtn.alpha==1) {
            [naviBar fadeOut];
        }
        [navi setNavigationBarHidden:NO animated:YES];
    }
}

@end
