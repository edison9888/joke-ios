//
//  AppUtil.m
//  TiantianCab
//
//  Created by Johnil on 13-5-17.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "AppUtil.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+Additions.h"

@implementation AppUtil

+ (UIView *)messageViewFromView:(UIView *)centerView andMessage:(NSString *)message{
    UIWindow *window = ApplicationDelegate.window;
    if ([window viewWithTag:NSIntegerMax]!=nil) {
        UIView *temp = [window viewWithTag:NSIntegerMax];
        [temp removeFromSuperview];
    }
    int width = 130;
    if (centerView && centerView.width>width && centerView.width+100<[UIScreen screenWidth]) {
        width = centerView.width+100;
    }
    int height = 100;
    if (message.length>0) {
        if (centerView) {
            height += [message sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(width, 30000) lineBreakMode:NSLineBreakByCharWrapping].height;
        } else {
            height = [message sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(width, 30000) lineBreakMode:NSLineBreakByCharWrapping].height;
        }
    }
    if (height<50) {
        height = 50;
    }
    UIView *notifyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    notifyView.layer.cornerRadius = 5;
    notifyView.layer.masksToBounds = YES;
    notifyView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    notifyView.center = window.center;
    notifyView.alpha = 0;
    notifyView.tag = NSIntegerMax;
    [window addSubview:notifyView];
    
    if (centerView) {
        int temp = 0;
        if (message.length>0) {
            temp = centerView.frame.size.height/2;
        }
        centerView.center = CGPointMake(notifyView.frame.size.width/2, notifyView.frame.size.height/2-temp);
        [notifyView addSubview:centerView];
    }
    
    if (message.length>0) {
        int tempHeight = [message sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(width-20, 30000) lineBreakMode:NSLineBreakByCharWrapping].height;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-20, tempHeight)];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = NSIntegerMax;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        label.text = message;
        label.center = CGPointMake(notifyView.frame.size.width/2, notifyView.frame.size.height/2+(centerView==nil?0:tempHeight));
        [notifyView addSubview:label];
    }
    
    [notifyView fadeIn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:notifyView action:@selector(fadeOut)];
    [notifyView addGestureRecognizer:tap];
    return notifyView;
}

+ (void)warning:(NSString *)message withType:(MessageType)type{
    [AppUtil warning:message withType:type delay:1];
}

+ (void)warning:(NSString *)message withType:(MessageType)type delay:(int)delay{
    UIView *notifyView = nil;
    switch (type) {
        case m_error:{
            UIImageView *icon = [[UIImageView alloc] initWithImage:imageNamed(@"error.png")];
            icon.center = CGPointMake(notifyView.frame.size.width/2, notifyView.frame.size.height/4+5);//14图标高度
            notifyView = [self messageViewFromView:icon andMessage:message];
            break;
        }
        case m_success:{
            UIImageView *icon = [[UIImageView alloc] initWithImage:imageNamed(@"success.png")];
            icon.center = CGPointMake(notifyView.frame.size.width/2, notifyView.frame.size.height/4+5);//14图标高度
            notifyView = [self messageViewFromView:icon andMessage:message];
            break;
        }
        case m_none:{
            notifyView = [self messageViewFromView:nil andMessage:message];
            break;
        }
        default:
            break;
    }
    [notifyView performSelector:@selector(fadeOut) withObject:nil afterDelay:delay];
}

+ (void)warning:(UIImage *)image{
    UIImageView *icon = [[UIImageView alloc] initWithImage:image];

    UIView *notifyView = [self messageViewFromView:icon andMessage:@""];
    
    [notifyView performSelector:@selector(fadeOut) withObject:nil afterDelay:1];
}

+ (void)wating:(NSString *)message{
    UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self messageViewFromView:activity andMessage:message];
    [activity startAnimating];
}

@end
