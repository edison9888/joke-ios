//
//  RecordViewController.m
//  Yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "RecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "EditView.h"
#import "FeedBackView.h"
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
    BOOL feedBack;
}

- (id)initWithFeedBack{
    self = [super init];
    if (self) {
        feedBack = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    naviBar.titleLabel.text = @"说一段";
    self.navigationController.navigationBarHidden = YES;
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
    [self.view addSubview:recordLabel];
    
    channelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
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

- (void)record:(UIButton *)btn{
    if (btn.selected) {
        [self stopRecord];
        btn.selected = NO;
    } else {
        btn.selected = YES;
        [self startRecord];
    }
}

- (void)stopRecord{
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
    
    if (feedBack) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"EditView"owner:self options:nil];
        FeedBackView *panel = [nib objectAtIndex:1];
        panel.y = 80;
        [panel.playBtn setBackgroundImage:[imageNamed(@"panel.png") resizableImageWithCapInsets:UIEdgeInsetsMake(15, 30, 15, 30)] forState:UIControlStateNormal];
        [panel.playBtn addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
        panel.time.text = [NSString stringWithFormat:@"%.1f''", [[NSDate date] timeIntervalSinceDate:startTime]];
        [self.view addSubview:panel];
    } else {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"EditView"owner:self options:nil];
        edit = [nib objectAtIndex:0];
        edit.center = self.view.center;
        edit.time.text = [NSString stringWithFormat:@"%.1f''", [[NSDate date] timeIntervalSinceDate:startTime]];
        startTime = nil;
        [self.view addSubview:edit];
        [edit.playBtn setBackgroundImage:[imageNamed(@"panel.png") resizableImageWithCapInsets:UIEdgeInsetsMake(15, 30, 15, 30)] forState:UIControlStateNormal];
        [edit.playBtn addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choicePhoto:)];
        [edit.warningImageView addGestureRecognizer:tap];
    }
}

- (IBAction)choicePhoto:(id)sender {
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
    NSURL *recordedFile = [NSURL URLWithString:path];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedFile error:nil];
    [audioPlayer play];
}

- (void)uploadVoice{
    NSLog(@"upload");
}

- (void)startRecord{
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
     [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
     [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
     nil];
    
    path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/%d.caf", arc4random()]];
    NSURL *recordedFile = [NSURL URLWithString:path];
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:settings error:nil];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    [recorder record];
    [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (void)tick:(NSTimer *)t{
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

- (void)viewWillDisappear:(BOOL)animated{
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    if (edit) {
        [edit removeFromSuperview];
    }
    if (sendBtn) {
        [sendBtn removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
