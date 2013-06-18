//
//  Cell.h
//  Yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface Cell : UITableViewCell <UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIButton *likeBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UILabel *playCount;
@property (strong, nonatomic) IBOutlet UILabel *playLabel;
@property (strong, nonatomic) IBOutlet UIButton *pauseBtn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UIView *progress;
- (IBAction)controlAudio:(id)sender;
- (IBAction)pauseAudio:(id)sender;
- (IBAction)playAudio:(id)sender;

- (void)setImageURL:(NSString *)url;
- (IBAction)likeAudio:(id)sender;
- (IBAction)shareAudio:(id)sender;

@end
