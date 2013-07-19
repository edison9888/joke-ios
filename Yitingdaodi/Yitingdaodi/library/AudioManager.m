//
//  AudioManager.m
//  Additions
//
//  Created by Johnil on 13-5-30.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "AudioManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "AppUtil.h"
static AudioManager *sSharedInstance;

@implementation AudioManager {
    AVAudioPlayer *player;
    NSTimer *ticker;
    NSString *tempURL;
    NSMutableData *currentData;
    float tempProgress;
}

+ (AudioManager *)defaultManager{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[AudioManager alloc] init];
    });
    return sSharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    return self;
}

- (void)startTick{
    [self stopTick];
    ticker = [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:ticker forMode:NSRunLoopCommonModes];
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayNotification object:nil];
}

- (void)stopTick{
    if (ticker) {
        [ticker invalidate];
        ticker = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioPauseNotification object:nil];
    }
}

- (float)progress{
    float currentTime = player.currentTime;
    float total = player.duration;
    return currentTime/total;
}

- (void)tick{
    [player updateMeters];
    float level = [player peakPowerForChannel:0];
    double peakPowerForChannel = pow(10, (0.05 * level));
//    NSLog(@"%f, %f", level, peakPowerForChannel);
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioProgressNotification object:[NSNumber numberWithFloat:[self progress]] userInfo:@{@"power": @(peakPowerForChannel)}];
}

- (NSString *)pathWithURL:(NSString *)url{
    return [[url componentsSeparatedByString:@"/"] lastObject];
}

- (void)playWithURL:(NSString *)url{
    if (url.length<=0) {
        return;
    }
    [self stopTick];
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioProgressNotification object:[NSNumber numberWithFloat:0]];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //stop player
    if (player) {
        player.delegate = nil;
        [player stop];
        player = nil;
    }
    if (currentData) {
        currentData = nil;
    }
    tempProgress = -1;
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[self pathWithURL:url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"play local with path:%@", path);
        if (player==nil) {
            NSData *audio = [NSData dataWithContentsOfFile:path];
            player = [[AVAudioPlayer alloc] initWithData:audio error:nil];
            player.delegate = self;
            player.meteringEnabled = YES;
            [player play];
            [self startTick];
        }
    } else {
        //download
        NSLog(@"play url:%@", url);
        NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self pathWithURL:url]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation1.outputStream = [NSOutputStream outputStreamToFileAtPath:cachePath append:NO];
        [operation1 setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead, NSData *receiveData) {
            float progress = (totalBytesRead*1.0)/(totalBytesExpectedToRead*1.0);
                tempProgress = progress;
                //            NSLog(@"url%@ progress:%f", url, progress);
                [[NSNotificationCenter defaultCenter] postNotificationName:AudioCacheProgressNotification object:nil userInfo:@{@"url": url, @"progress":@(progress)}];
                if (currentData==nil) {
                    currentData = [[NSMutableData alloc] init];
                }
                [currentData appendData:receiveData];
                if (player==nil && progress>.15) {
                    player = [[AVAudioPlayer alloc] initWithData:currentData error:nil];
                    player.delegate = self;
                    player.meteringEnabled = YES;
                    [player play];
                    [self startTick];
                }
        }];
        [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"download complet", nil);
            [[NSFileManager defaultManager] moveItemAtPath:cachePath toPath:path error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"download failed", nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:AudioCacheProgressNotification object:@(0)];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }];
        [operation1 start];
    }
    tempURL = [url copy];
}

- (BOOL)needURL{
    return !tempURL;
}

#pragma mark - Audio delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioProgressNotification object:[NSNumber numberWithFloat:1]];
    tempURL = nil;
    [self stopTick];
    if ([[[UserDataManager defaultUserData] valueForKey:@"autoPlay"] boolValue]) {
        [self next];
    }
}

- (BOOL)changeStat{
    if (player.playing) {
        [player pause];
        [self stopTick];
        return NO;
    } else {
        [player play];
        [self startTick];
        return YES;
    }
}

- (void)resume{
    if (player && !player.playing) {
        [player play];
        [self startTick];
    }
}

- (void)pause{
    if (player && player.playing) {
        [player pause];
        [self stopTick];
    }
}

- (void)next{
    [_delegate playNext];
//    [[NSNotificationCenter defaultCenter] postNotificationName:AudioNextNotification object:nil];
}

- (void)pre{
    [_delegate playPre];
//    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPreNotification object:nil];
}

- (float)duration{
    return player.duration;
}

- (float)currentPlaybackTime{
    return player.currentTime;
}

- (float)leftTime{
    return player.duration-player.currentTime;
}

- (BOOL)playing{
    return player.playing;
}

@end
