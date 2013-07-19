//
//  RecordViewController.m
//  Yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "RecordViewController.h"
#import "EditView.h"
#import "FeedBackView.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "RequestHelper.h"
#import "lame.h"
#import "MobClick.h"

@interface RecordViewController ()

@end

@implementation RecordViewController {
    UIButton *recordBtn;
    AVAudioRecorder *recorder;
    NSString *path;
    UILabel *recordLabel;
    UIView *channelView;
    UIView *channelRedView;
    UIButton *sendBtn;
    NSDate *startTime;
    AVAudioPlayer *audioPlayer;
    EditView *edit;
    FeedBackView *feedBackView;
    BOOL feedBack;
    AFHTTPClient *httpClient;
    NSTimer *ticker;
    float time;
}

- (id)initWithFeedBack{
    self = [super init];
    if (self) {
        feedBack = YES;
        [MobClick event:@"feedback"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithFullRed:227 green:227 blue:227 alpha:1];
    naviBar.titleLabel.text = @"说一段";
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = YES;
    [navi showBar];

    recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordBtn setImage:imageNamed(@"record.png") forState:UIControlStateNormal];
    [recordBtn setImage:imageNamed(@"recordA.png") forState:UIControlStateHighlighted];
    [recordBtn setImage:imageNamed(@"recordA.png") forState:UIControlStateSelected];
    [recordBtn addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    recordBtn.frame = CGRectMake(0, 0, 213, 213);
    recordBtn.center = self.view.center;
    [self.view addSubview:recordBtn];
    
    recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    recordLabel.textAlignment = NSTextAlignmentCenter;
    recordLabel.text = @"正在接收";
    recordLabel.center = CGPointMake(self.view.center.x, self.view.center.y-150);
    recordLabel.backgroundColor = [UIColor clearColor];
    recordLabel.hidden = YES;
    [self.view addSubview:recordLabel];
    
    channelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    channelView.hidden = YES;
    channelView.backgroundColor = [UIColor clearColor];
    channelView.center = CGPointMake(recordLabel.center.x, recordLabel.center.y+50);
    [self.view addSubview:channelView];
    
    channelRedView = [[UIView alloc] initWithFrame:channelView.frame];
    channelRedView.backgroundColor = [UIColor clearColor];
    channelRedView.center = CGPointMake(recordLabel.center.x, recordLabel.center.y+50);
    [self.view addSubview:channelRedView];
    channelRedView.clipsToBounds = YES;
    
    for (int i=0; i<20; i++) {
        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(3*i, 0, 3, 3)];
        circle.layer.cornerRadius = 3;
        circle.layer.masksToBounds = YES;
        circle.backgroundColor = [UIColor grayColor];
        [channelView addSubview:circle];
    }
    
    for (int i=0; i<20; i++) {
        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(3*i, 0, 3, 3)];
        circle.layer.cornerRadius = 3;
        circle.layer.masksToBounds = YES;
        circle.backgroundColor = [UIColor redColor];
        [channelRedView addSubview:circle];
    }
    channelRedView.width = 0;
}

- (void)pop{
    if (sendBtn==nil) {
        [navi popViewControllerAnimated:YES];
        [naviBar pop];
        return;
    }
    UIActionSheet *acion = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"重新录制", @"返回", nil];
    acion.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [acion showInView:self.view.window];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=actionSheet.cancelButtonIndex) {
        switch (buttonIndex) {
            case 0:{//重新录制
                [sendBtn removeFromSuperview];
                sendBtn = nil;
                [self.view removeAllSubviews];
                [self viewDidLoad];
                break;
            }
            case 1:{//返回设置
                [navi popViewControllerAnimated:YES];
                [naviBar pop];
                break;
            }
            default:
                return;
        }
    }
}

- (void)record:(UIButton *)btn{
    if (btn.selected) {
        [AppUtil wating:@"正在处理音频..."];
        [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(stopRecord) userInfo:nil repeats:NO];
        btn.selected = NO;
    } else {
        btn.selected = YES;
        [self startRecord];
    }
}

- (void)startRecord{
    [MobClick event:@"record"];
    channelView.hidden = NO;
    recordLabel.hidden = NO;
    startTime = [[NSDate alloc] init];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                              [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
//                              [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                              nil];
    
    path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/%d.caf", arc4random()]];
    NSURL *recordedFile = [NSURL URLWithString:path];
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:settings error:nil];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    [recorder record];
    ticker = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:ticker forMode:NSRunLoopCommonModes];
}

- (void)tick:(NSTimer *)t{
    time = [[NSDate date] timeIntervalSinceDate:startTime];
    if (time>=90) {
        [ticker invalidate];
        ticker = nil;
        [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(stopRecord) userInfo:nil repeats:NO];
        [AppUtil wating:@"正在处理音频..."];
    }
    if (recorder) {
        [recorder updateMeters];
        float level = [recorder peakPowerForChannel:1];
        double peakPowerForChannel = pow(10, (0.05 * level));
        channelRedView.width = channelView.width*peakPowerForChannel;
    } else {
        [t invalidate];
        t = nil;
    }
}

- (void)stopRecord{
    [ticker invalidate];
    ticker = nil;
    [recorder stop];
    recorder = nil;
        
    [self.view removeAllSubviews];
    
    sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setBackgroundImage:imageNamed(@"right_btn.png") forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:imageNamed(@"right_btn_pressed.png") forState:UIControlStateHighlighted];
    if (feedBack) {
        [sendBtn setTitle:@"提交" forState:UIControlStateNormal];
    } else {
        [sendBtn setTitle:@"发布" forState:UIControlStateNormal];
    }
    sendBtn.titleLabel.textColor = [UIColor whiteColor];
    sendBtn.frame = CGRectMake(320-70-10, 10, 70, 40);
    [sendBtn addTarget:self action:@selector(uploadVoice) forControlEvents:UIControlEventTouchUpInside];
    [naviBar addSubview:sendBtn];
    time = [[NSDate date] timeIntervalSinceDate:startTime];
    if (feedBack) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"EditView"owner:self options:nil];
        feedBackView = [nib objectAtIndex:1];
        feedBackView.y = 80;
        [feedBackView.playBtn setBackgroundImage:[imageNamed(@"panel.png") resizableImageWithCapInsets:UIEdgeInsetsMake(15, 30, 15, 30)] forState:UIControlStateNormal];
        [feedBackView.playBtn addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
        feedBackView.time.text = [NSString stringWithFormat:@"%.0f''", time];
        [self.view addSubview:feedBackView];
    } else {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"EditView"owner:self options:nil];
        edit = [nib objectAtIndex:0];
        edit.center = self.view.center;
        edit.time.text = [NSString stringWithFormat:@"%.0f''", time];
        startTime = nil;
        [self.view addSubview:edit];
        [edit.playBtn setBackgroundImage:[imageNamed(@"panel.png") resizableImageWithCapInsets:UIEdgeInsetsMake(15, 30, 15, 30)] forState:UIControlStateNormal];
        [edit.playBtn addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choicePhoto:)];
        [edit.warningImageView addGestureRecognizer:tap];
    }
    [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(audio_PCMtoMP3) userInfo:nil repeats:NO];
}

- (IBAction)choicePhoto:(id)sender {
    [MobClick event:@"clickImgToPlay"];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage* image = [info objectForKey: @"UIImagePickerControllerEditedImage"];
    edit.coverImageView.image = image;
    [self imagePickerControllerDidCancel:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [edit.warningImageView removeFromSuperview];
    [self.view addSubview:edit];
    navi.navigationBarHidden = YES;
    naviBar.alpha = 1;
    [naviBar addSubview:sendBtn];
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

- (void)playRecord{
    if (audioPlayer && audioPlayer.playing) {
        [audioPlayer pause];
        [ticker invalidate];
        ticker = nil;
        if (feedBack) {
            feedBackView.voiceView.alpha = 0;
            [feedBackView.playBtn setImage:imageNamed(@"play_btn.png") forState:UIControlStateNormal];
        } else {
            edit.voiceView.alpha = 0;
            [edit.playBtn setImage:imageNamed(@"play_btn.png") forState:UIControlStateNormal];
        }
    } else {
        if (audioPlayer == nil) {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setActive:YES error:nil];
            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
            NSURL *recordedFile = [NSURL URLWithString:path];
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedFile error:nil];
            audioPlayer.delegate = self;
            audioPlayer.meteringEnabled = YES;
        }
        [audioPlayer play];
        ticker = [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(tickPower:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:ticker forMode:NSRunLoopCommonModes];
        if (feedBack) {
            feedBackView.voiceView.alpha = 1;
            [feedBackView.playBtn setImage:nil forState:UIControlStateNormal];
        } else {
            edit.voiceView.alpha = 1;
            [edit.playBtn setImage:nil forState:UIControlStateNormal];
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (ticker) {
        [ticker invalidate];
        ticker = nil;
    }
    if (feedBack) {
        feedBackView.voiceView.alpha = 0;
        [feedBackView.playBtn setImage:imageNamed(@"play_btn.png") forState:UIControlStateNormal];
        feedBackView.time.text = [NSString stringWithFormat:@"%.0f''", time];
    } else {
        edit.voiceView.alpha = 0;
        [edit.playBtn setImage:imageNamed(@"play_btn.png") forState:UIControlStateNormal];
        edit.time.text = [NSString stringWithFormat:@"%.0f''", time];
    }
    audioPlayer.delegate = nil;
    audioPlayer = nil;
}

- (void)tickPower:(NSTimer *)t{
    [audioPlayer updateMeters];
    float level = [audioPlayer peakPowerForChannel:0];
    double peakPowerForChannel = pow(10, (0.05 * level));
    if (feedBack) {
        feedBackView.time.text = [NSString stringWithFormat:@"%.0f''", audioPlayer.duration-audioPlayer.currentTime];
        feedBackView.redView.boundsWidth = feedBackView.voiceView.width*peakPowerForChannel;
    } else {
        edit.time.text = [NSString stringWithFormat:@"%.0f''", audioPlayer.duration-audioPlayer.currentTime];
        edit.redView.boundsWidth = edit.voiceView.width*peakPowerForChannel;
    }
}

- (void)uploadVoice{
    if (![RequestHelper checkNetWork]) {
        return;
    }
    NSLog(@"upload data with path:%@ and name:%@", path, [[path componentsSeparatedByString:@"/"] lastObject]);
    httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://42.96.164.29:8888"]];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                         path:@"/api/myjokes"
                                                                   parameters:@{@"myjoke": @{@"name": @"from iOS", @"description": @"123", @"uid": [UIDevice udid]}}
                                                    constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                        [formData appendPartWithFileData:[NSData dataWithContentsOfFile:path] name:@"audioFileData" fileName:[[path componentsSeparatedByString:@"/"] lastObject] mimeType:@"mp3"];
                                                        if (edit.coverImageView.image) {
                                                            [formData appendPartWithFileData:UIImageJPEGRepresentation(edit.coverImageView.image, 1) name:@"imageFileData" fileName:[NSString stringWithFormat:@"%d.jpg", arc4random()] mimeType:@"image/jpeg"];
                                                        }
                                                    }];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"progress:%f", (totalBytesWritten/1024.0)/(totalBytesExpectedToWrite/1024.0));
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"upload done", nil);
        if (feedBack) {
            [AppUtil warning:@"建议上传成功，我们会认真听取，谢谢" withType:m_success];
        } else {
            [MobClick event:@"send"];
            [AppUtil warning:@"录音已上传，请等待审核" withType:m_success];
            [navi popViewControllerAnimated:YES];
            [naviBar pop];
        }
        
//        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error debugDescription]);
        [AppUtil warning:@"上传失败" withType:m_error];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [[AudioManager defaultManager] pause];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[AudioManager defaultManager] resume];
    if (audioPlayer) {
        audioPlayer.delegate = nil;
        [audioPlayer stop];
        audioPlayer = nil;
    }
    if (ticker) {
        [ticker invalidate];
        ticker = nil;
    }
    if (edit) {
        [edit removeFromSuperview];
    }
    if (sendBtn) {
        [sendBtn removeFromSuperview];
    }
}

- (void)audio_PCMtoMP3
{
    NSString *cafFilePath = path;
    
    NSString *mp3FilePath = [path replace:@"caf" withString:@"mp3"];
    
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    [fileManager removeItemAtPath:mp3FilePath error:nil];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        NSLog(@"covert done %@", mp3FilePath);
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        path = mp3FilePath;
        [AppUtil warning:@"处理完成!" withType:m_success];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
