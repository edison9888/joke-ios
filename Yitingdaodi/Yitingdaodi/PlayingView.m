//
//  PlayingView.m
//  Yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "PlayingView.h"
#import "AudioManager.h"
@implementation PlayingView {
    NSTimer *ticker;
    NSMutableArray *redViewArr;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        int width = 2;
        int maxHeight = self.frame.size.height;
        int minHeight = 5;
        int heightStep = 2;
        redViewArr = [[NSMutableArray alloc] init];
        for (int i=0; i<12; i++) {
            CGRect frame = CGRectMake(i*5, 0, width, 0);
            if (i<6) {
                frame.size.height = minHeight+heightStep*i;
            } else {
                frame.size.height = maxHeight-heightStep*i;
            }
            UIView *line = [[UIView alloc] initWithFrame:frame];
            line.backgroundColor = [UIColor grayColor];
            line.center = CGPointMake(line.center.x, self.frame.size.height/2);
            [self addSubview:line];
            
            UIView *redLine = [[UIView alloc] initWithFrame:frame];
            redLine.alpha = 0;
            redLine.backgroundColor = [UIColor redColor];
            redLine.center = CGPointMake(line.center.x, self.frame.size.height/2);
            [self addSubview:redLine];
            [redViewArr addObject:redLine];
        }
        self.tag = 1;
        self.backgroundColor = [UIColor clearColor];
        [self play];
    }
    return self;
}

- (void)play{
    [self tick:nil];
    ticker = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:ticker forMode:NSRunLoopCommonModes];
}

- (void)stop{
    [ticker invalidate];
    ticker = nil;
}

- (void)tick:(NSTimer *)t{
    int i = 1;
    for (UIView *temp in redViewArr) {
        [UIView animateWithDuration:.1*i animations:^{
            temp.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.2 animations:^{
                temp.alpha = 0;
            }];
        }];
        i++;
    }
}

- (void)dealloc{
    [redViewArr removeAllObjects];
    redViewArr = nil;
}

@end
