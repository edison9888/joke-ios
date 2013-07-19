//
//  RecordViewController.h
//  Yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, AVAudioPlayerDelegate>

- (id)initWithFeedBack;

@end
