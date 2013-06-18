//
//  NavigationController.m
//  TiantianCab
//
//  Created by Johnil on 13-5-16.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "NavigationController.h"
@interface NavigationController ()

@end

@implementation NavigationController {
    
}

- (id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        _bar = [[NavigationBar alloc] init];
        _bar.alpha = 0;
        [self.view addSubview:_bar];
        self.delegate = _bar;
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popViewControllerAnimated:)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipe];
    }
    return self;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    NSLog(@"pop");
    [_bar pop];
    return [super popViewControllerAnimated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController:viewController animated:animated];
    [_bar push];
}

- (void)showBar{
    [UIView animateWithDuration:.25 animations:^{
//        _bar.center = CGPointMake(_bar.center.x, 20+_bar.frame.size.height/2);
        _bar.alpha = 1;
    }];
}

- (void)hideBar{
    [UIView animateWithDuration:.25 animations:^{
//        _bar.center = CGPointMake(_bar.center.x, -_bar.frame.size.height/2);
        _bar.alpha = 0;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
