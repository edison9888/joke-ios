//
//  AppDelegate.m
//  yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "AppDelegate.h"
#import "RequestHelper.h"
#import "ListViewController.h"
#import "WXApi.h"
#import "MobClick.h"

@implementation AppDelegate {
    UIImageView *welCome;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 1;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _list = [[ListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _navigationController = [[NavigationController alloc] initWithRootViewController:_list];
    _navigationController.navigationBarHidden = YES;
    self.window.backgroundColor = [UIColor blackColor];//[UIColor colorWithFullRed:227 green:227 blue:227 alpha:1];
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];
    
    NSString *load = [NSString stringWithFormat:@"Default%@.png", [UIDevice isRetina]?([UIDevice isiPhone5]?@"-568h@2x":@"@2x"):@""];
    welCome = [[UIImageView alloc] initWithImage:imageNamed(load)];
    [_navigationController.view addSubview:welCome];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activity startAnimating];
    activity.center = CGPointMake(welCome.frame.size.width/2, welCome.frame.size.height-80);
    [welCome addSubview:activity];

    [WXApi registerApp:@"wxb3b0db608a4925ee"];
    [MobClick startWithAppkey:@"51c02df056240b165f006d11"];
    return YES;
}

- (void)enterApp{
    if (welCome && welCome.alpha==1) {
        [UIView animateWithDuration:.5 animations:^{
            welCome.transform = CGAffineTransformMakeScale(1.15, 1.15);
            welCome.alpha = 0;
        } completion:^(BOOL finished) {
            [welCome removeFromSuperview];
        }];
    }
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [[AudioManager defaultManager] changeStat];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[AudioManager defaultManager] next];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[AudioManager defaultManager] pre];
                break;
            default:
                break;
        }
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *urlStr = [url absoluteString];
    if ([urlStr indexOf:@"yitingdaodi://"]!=-1) {
        return YES;
    }
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self application:application handleOpenURL:url];
}

- (void) onReq:(BaseReq*)req{
    
}

-(void) onResp:(BaseResp*)resp{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode==WXSuccess) {
            [AppUtil warning:@"分享成功" withType:m_success];
        } else if (resp.errCode!=WXSuccess && resp.errStr.length > 0) {
            [AppUtil warning:resp.errStr withType:m_error];
        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
    }
//    else if([resp isKindOfClass:[SendAuthResp class]])
//    {
//        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
//        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [_list backUp];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
