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
#import <QuartzCore/QuartzCore.h>
#import "MobClick.h"
#import "RequestHelper.h"
@implementation Cell {
    NSString *url;
    int scene;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop:) name:OtherCellPlayNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePlaying:) name:AudioNextNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePlaying:) name:AudioPreNotification object:nil];
        self.powerView.layer.anchorPoint = CGPointMake(.5, .5);
        self.powerView.boundsWidth = 0;
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
//        NSLog(@"load image:%@", url_);
        [self.coverImageView setImageWithURL:[NSURL URLWithString:url]];
    }
}

- (IBAction)likeAudio:(id)sender {
    if (self.likeBtn.tag==1) {
//        [AppUtil warning:@"我不喜欢!" withType:m_success];
        int like = self.likeLabel.text.intValue;
        like--;
        self.likeLabel.text = [NSString stringWithFormat:@"%d", like];
        self.likeBtn.selected = YES;
        self.likeBtn.tag = 0;
    } else {
        int like = self.likeLabel.text.intValue;
        like++;
        self.likeLabel.text = [NSString stringWithFormat:@"%d", like];
        [AppUtil warning:imageNamed(@"heart.png")];
        self.likeBtn.selected = NO;
        self.likeBtn.tag = 1;
    }
    [[RequestHelper defaultHelper] requestPOSTAPI:@"/api/likes" postData:@{@"myjoke_id": _id1, @"uid": [UIDevice udid], @"isLike":@(self.likeBtn.tag)} success:^(id result) {
        NSLog(@"success%@", result);
    } failed:nil];
}

- (IBAction)shareAudio:(id)sender {
//    [AppUtil warning:@"分享成功" withType:m_success];
    UIActionSheet *acion = [[UIActionSheet alloc] initWithTitle:@"分享给" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信好友", @"朋友圈", nil];
    acion.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [acion showInView:self.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=actionSheet.cancelButtonIndex) {
        switch (buttonIndex) {
            case 0:{//好友
                scene = WXSceneSession;
                break;
            }
            case 1:{//朋友圈
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
    [MobClick event:@"clickImgToPlay"];
    if ([List currentIndex] && [[AudioManager defaultManager] playing]) {
        [self pauseAudio:nil];
    } else {
        [self playAudio:nil];
    }
}

- (IBAction)pauseAudio:(id)sender {
    [[AudioManager defaultManager] pause];
//    [self removePlayingView];
}

- (void)playUI{
    self.playCount.text = [NSString stringWithFormat:@"%d", self.playCount.text.intValue+1];
    [[RequestHelper defaultHelper] requestPOSTAPI:@"/api/myjokes/play" postData:@{@"id": _id1, @"uid": [UIDevice udid]} success:^(id result) {
        NSLog(@"success%@", result);
    } failed:nil];
    if ([List hasCacheWithIndex:self.path]) {
        self.cacheProgress.width = self.coverImageView.width;
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cacheProgressUpdate:) name:AudioCacheProgressNotification object:nil];
    }
}

- (IBAction)playAudio:(id)sender {
    NSLog(@"currentTag:%d", self.tag);
    if ([List currentIndex]==self.path) {
        [[AudioManager defaultManager] resume];
    } else {
        [self playUI];
        [List playIndex:self.path];
    }
    [self addPlayingView];
}

- (void)audioProgress:(NSNotification *)notifi{
    float prog = [[notifi object] floatValue];
    if (prog==1) {
        [self removePlayingView];
    }
    self.progress.width = self.coverImageView.width*prog;
    float volume = [[NSString stringWithFormat:@"%.1f", [[notifi.userInfo valueForKey:@"power"] floatValue]] floatValue];
    volume = volume*10*0.076;
    NSLog(@"%f", volume);
    self.powerView.boundsWidth = self.voiceView.width*(volume);
    self.time.text = [NSString stringWithFormat:@"%.0f''", [[AudioManager defaultManager] leftTime]];
}

- (void)cacheProgressUpdate:(NSNotification *)notifi{
    NSDictionary *dict = notifi.userInfo;
    NSString *audioURL = [dict valueForKey:@"url"];
    if ([[List urlWithIndex:self.path] isEqualToString:audioURL]) {
        float prog = [[dict valueForKey:@"progress"] floatValue];
        self.cacheProgress.width = self.coverImageView.width*prog;
    }
    if (self.cacheProgress.width==self.coverImageView.width) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AudioCacheProgressNotification object:nil];
    }
}

- (void)addPlayingView{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioProgress:) name:AudioProgressNotification object:nil];
    if (self.voiceView.alpha) {
        return;
    }
    self.voiceView.alpha = 1;
    self.playBtn.alpha = 0;
    self.playLabel.alpha = 0;
    self.playCount.alpha = 0;
    self.pauseBtn.userInteractionEnabled = YES;
}

- (void)removePlayingView{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AudioProgressNotification object:nil];
    if (!self.voiceView.alpha) {
        return;
    }
    self.voiceView.alpha = 0;
    self.playBtn.alpha = 1;
    self.playLabel.alpha = 1;
    self.playCount.alpha = 1;
    self.pauseBtn.userInteractionEnabled = NO;
    self.progress.width = self.coverImageView.width*0;
    self.powerView.boundsWidth = 0;
}

- (void)sendAudio{
    UIGraphicsBeginImageContext(self.coverImageView.bounds.size);
    [self.coverImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"这笑话还真有点意思";
    message.description = @"笑话";
    [message setThumbImage:image1];
    
    WXMusicObject *ext = [WXMusicObject object];
    ext.musicUrl = [NSString stringWithFormat:@"yitingdaodi://%@", [List urlWithIndex:self.path]];
    ext.musicDataUrl = [List urlWithIndex:self.path];
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
