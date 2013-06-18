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

+ (void)warning:(NSString *)message withType:(MessageType)type{
    [AppUtil warning:message withType:type delay:1];
}

+ (void)warning:(NSString *)message withType:(MessageType)type delay:(int)delay{
    UIWindow *window = ApplicationDelegate.window;
    if ([window viewWithTag:NSIntegerMax]!=nil) {
        UIView *temp = [window viewWithTag:NSIntegerMax];
        [temp removeFromSuperview];
    }
    int height = [message sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(150, 30000) lineBreakMode:NSLineBreakByCharWrapping].height;
    UIView *notifyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 14+height+50)];
    notifyView.layer.cornerRadius = 5;
    notifyView.layer.masksToBounds = YES;
    notifyView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    notifyView.center = window.center;
    notifyView.alpha = 0;
    notifyView.tag = NSIntegerMax;
    [window addSubview:notifyView];
    
    switch (type) {
        case m_error:{
            UIImageView *icon = [[UIImageView alloc] initWithImage:imageNamed(@"error.png")];
            icon.center = CGPointMake(notifyView.frame.size.width/2, notifyView.frame.size.height/4+5);//14图标高度
            [notifyView addSubview:icon];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 4;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor whiteColor];
            label.text = message;
            label.center = CGPointMake(notifyView.frame.size.width/2, notifyView.frame.size.height/4*3-5);
            [notifyView addSubview:label];
            break;
        }
        case m_success:{
            UIImageView *icon = [[UIImageView alloc] initWithImage:imageNamed(@"success.png")];
            icon.center = CGPointMake(notifyView.frame.size.width/2, notifyView.frame.size.height/4+5);//14图标高度
            [notifyView addSubview:icon];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 4;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor whiteColor];
            label.text = message;
            label.center = CGPointMake(notifyView.frame.size.width/2, notifyView.frame.size.height/4*3-5);
            [notifyView addSubview:label];
            break;
        }
        case m_none:{
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = NSIntegerMax;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor whiteColor];
            label.text = message;
            label.center = CGPointMake(notifyView.frame.size.width/2, notifyView.frame.size.height/2);
            [notifyView addSubview:label];
            break;
        }
        default:
            break;
    }
    
    [notifyView fadeIn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:notifyView action:@selector(fadeOut)];
    [notifyView addGestureRecognizer:tap];
    
    [notifyView performSelector:@selector(fadeOut) withObject:nil afterDelay:delay];
}

@end
