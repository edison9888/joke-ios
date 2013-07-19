//
//  AudioManager.h
//  Additions
//
//  Created by Johnil on 13-5-30.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#define AudioPlayNotification @"audioPaly"
#define AudioPauseNotification @"audioPause"
#define AudioNextNotification @"audioNext"
#define AudioPreNotification @"audioPre"
#define AudioProgressNotification @"audioProgress"
#define AudioCacheProgressNotification @"audioCacheProgress"
#define AudioCacheAllProgressNotification @"audioCacheAllProgress"

@interface AudioManager : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, weak) id delegate;
/**
 Description: 返回AudioManager的对象
 @return AudioManager唯一对象
 @author johnil
 */
+ (AudioManager *)defaultManager;

/**
 Description: 当前播放列表是否为空
 @return 当前播放列表需要一个URL开始播放
 @author johnil
 */
- (BOOL)needURL;

/**
 Description: 修改当前音乐状态,如果为播放则暂停,否则继续播放.
 @return 如果开始播放,则返回YES,否则返回NO
 @author johnil
 */
- (BOOL)changeStat;

/**
 Description: 在线播放URL
 @param 音乐URL
 @author johnil
 */
- (void)playWithURL:(NSString *)url;

/**
 Description: 继续播放音乐
 @author johnil
 */
- (void)resume;

/**
 Description: 暂停音乐
 @author johnil
 */
- (void)pause;

/**
 Description: 播放下一首音乐,如果没有下一首则会从第一首开始播放
 @author johnil
 */
- (void)next;

/**
 Description: 播放上一首音乐,如果没有上一首则会从最后一首开始播放
 @author johnil
 */
- (void)pre;

/**
 Description: 当前音乐的时间总长
 @return 时间总长
 @author johnil
 */
- (float)duration;

/**
 Description: 当前音乐播放时间
 @return 播放时间
 @author johnil
 */
- (float)currentPlaybackTime;

- (float)leftTime;

/**
 Description: 是否在播放
 @return 是否
 @author johnil
 */
- (BOOL)playing;

/**
 Description: 当前播放进度
 @return 进度 0 到 1
 @author johnil
 */
- (float)progress;

@end

@protocol AudioManagerDelegate <NSObject>

- (void)playNext;
- (void)playPre;

@end

