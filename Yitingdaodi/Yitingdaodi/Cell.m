//
//  Cell.m
//  Yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "Cell.h"
#import "UIImageView+AFNetworking.h"
#import "AudioManager.h"
#import "PlayingView.h"
#import <QuartzCore/QuartzCore.h>
@implementation Cell {
    PlayingView *playView;
    NSString *url;
    int scene;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop:) name:OtherCellPlayNotification object:nil];
    }
    return self;
}

- (void)stop:(NSNotification *)notifi{
    if ([notifi.object intValue]==self.tag) {
        return;
    }
    [self removePlayingView];
}

- (void)setImageURL:(NSString *)url_{
    if (url!=url_||self.coverImageView.image==nil) {
        url = url_;
        [self.coverImageView setImageWithURL:[NSURL URLWithString:url]];
    }
    if (playView==nil&&[[AudioManager defaultManager] currentIndex]==self.tag) {
        [self addPlayingView];
    }
}

- (IBAction)likeAudio:(id)sender {
    if (self.likeBtn.tag==1) {
        [AppUtil warning:@"我不喜欢!" withType:m_success];
        self.likeBtn.selected = YES;
        self.likeBtn.tag = -1;
    } else {
        [AppUtil warning:@"我喜欢!" withType:m_success];
        self.likeBtn.selected = NO;
        self.likeBtn.tag = 1;
    }
}

- (IBAction)shareAudio:(id)sender {
//    [AppUtil warning:@"分享成功" withType:m_success];
    UIActionSheet *acion = [[UIActionSheet alloc] initWithTitle:@"分享给" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"微信好友", @"朋友圈", nil];
    acion.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [acion showInView:self.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=actionSheet.cancelButtonIndex) {
        switch (buttonIndex) {
            case 1:{//好友
                scene = WXSceneSession;
                break;
            }
            case 2:{//朋友圈
                scene = WXSceneTimeline;
                break;
            }
            default:
                return;
        }
        [self sendAudio];
    }
}

- (IBAction)controlAudio:(id)sender {
    if (playView==nil) {
        [self playAudio:nil];
    } else {
        [self pauseAudio:nil];
    }
}

- (IBAction)pauseAudio:(id)sender {
    [[AudioManager defaultManager] pause];
    [self removePlayingView];
}

- (IBAction)playAudio:(id)sender {
    NSLog(@"currentTag:%d", self.tag);
    if ([[AudioManager defaultManager] currentIndex]==self.tag) {
        [[AudioManager defaultManager] resume];
    } else {
        [[AudioManager defaultManager] playIndex:self.tag];
    }
    [self addPlayingView];
}

- (void)audioProgress:(NSNotification *)notifi{
    float prog = [[notifi object] floatValue];
    self.progress.width = self.coverImageView.width*prog;
}

- (void)addPlayingView{
    if (playView==nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioProgress:) name:AudioProgressNotification object:nil];
        playView = [[PlayingView alloc] initWithFrame:CGRectMake(163, 313, 65, 26)];
        [self addSubview:playView];
        self.playBtn.alpha = 0;
        self.playLabel.alpha = 0;
        self.playCount.alpha = 0;
        self.pauseBtn.userInteractionEnabled = YES;
    }
}

- (void)removePlayingView{
    if (playView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AudioProgressNotification object:nil];
        [playView stop];
        [playView removeFromSuperview];
        playView = nil;
        self.playBtn.alpha = 1;
        self.playLabel.alpha = 1;
        self.playCount.alpha = 1;
        self.pauseBtn.userInteractionEnabled = NO;
        [self audioProgress:0];
    }
}

- (void)sendAudio{
    UIGraphicsBeginImageContext(self.coverImageView.bounds.size);
    [self.coverImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"笑话";
    message.description = @"笑话";
    [message setThumbImage:image1];
    
    WXMusicObject *ext = [WXMusicObject object];
    ext.musicUrl = [[AudioManager defaultManager] urlWithIndex:self.tag];
    ext.musicDataUrl = [[AudioManager defaultManager] urlWithIndex:self.tag];
    message.mediaObject = ext;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

- (void)dealloc{
    NSLog(@"cell dealloc:%@", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
