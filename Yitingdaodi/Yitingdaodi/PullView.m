//
//  PullView.m
//  Yitingdaodi
//
//  Created by Johnil on 13-6-26.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "PullView.h"
#import "PullProgressView.h"

@implementation PullView {
    PullProgressView *progress;
    UIImageView *loading;
    UIImageView *bg;
}

- (id)init
{
    self = [super initWithFrame:CGRectMake([UIScreen screenWidth]/2-19, -49, 39, 48)];
    if (self) {
        bg = [[UIImageView alloc] initWithImage:imageNamed(@"pull_bg.png")];
        [self addSubview:bg];
        progress = [[PullProgressView alloc] init];
        [self addSubview:progress];
        loading = [[UIImageView alloc] initWithImage:imageNamed(@"pull_loading.png")];
        loading.frame = CGRectMake(1, 0, 37, 45);
        loading.alpha = 0;
        [self addSubview:loading];
    }
    return self;
}

- (void)setProgress:(float)progress1{
    if (progress1>=.85 && loading.alpha==0) {
        [UIView animateWithDuration:.3 animations:^{
            loading.alpha = 1;
            self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }];
    } else if (progress1<.85 && loading.alpha==1){
        [UIView animateWithDuration:.3 animations:^{
            loading.alpha = 0;
            self.transform = CGAffineTransformIdentity;
        }];
    }
    progress.progress = progress1;
}

- (void)breath{
    CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    transform.values = @[@(1.1), @(1.0)];
    transform.repeatCount = NSIntegerMax;
    transform.autoreverses = YES;
    transform.duration = .3;
    [self.layer addAnimation:transform forKey:@"breath"];
}

- (void)startAnimation{
    [UIView animateWithDuration:.3 animations:^{
        loading.alpha = 1;
    } completion:^(BOOL finished) {
        loading.tag = 0;
        [self breath];
    }];
}

- (void)stopAnimation{
    [UIView animateWithDuration:.3 animations:^{
        loading.alpha = 0;
        progress.progress = 0;
    }];
    [self.layer removeAllAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
