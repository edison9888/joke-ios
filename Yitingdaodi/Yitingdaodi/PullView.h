//
//  PullView.h
//  Yitingdaodi
//
//  Created by Johnil on 13-6-26.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullView : UIView

- (void)setProgress:(float)progress;
- (void)startAnimation;
- (void)stopAnimation;

@end
