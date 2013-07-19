//
//  PullProgressView.m
//  Yitingdaodi
//
//  Created by Johnil on 13-6-26.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "PullProgressView.h"

static NSMutableArray *pointArr;

@implementation PullProgressView {
    UIImage *progressImage;
    
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(1, .3, 37, 45)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        pointArr = [[NSMutableArray alloc] init];
        float step = (32-25)/10.0;
        for (int i=0; i<11; i++) {// 10, 35, 35, 20
            [pointArr addObject:[NSString stringWithFormat:@"{%f, 10}", 25+step*i]];
        }
        step = (42-10)/35.0;
        for (int i=0; i<30; i++) {// 10, 35, 35, 20
            [pointArr addObject:[NSString stringWithFormat:@"{32, %f}", 10+step*i]];
        }
        step = (2-32)/35.0;
        for (int i=0; i<28; i++) {// 10, 35, 35, 20
            [pointArr addObject:[NSString stringWithFormat:@"{%f, 40}", 32+step*i]];
        }
        step = (23-42)/20.0;
        for (int i=0; i<21; i++) {// 10, 35, 35, 20
            [pointArr addObject:[NSString stringWithFormat:@"{4, %f}", 42+step*i]];
        }
        progressImage = [UIImage imageNamed:@"pull_progress.png"];
    }
    return self;
}

- (void)setProgress:(float)progress{
    _progress = progress;
    if (progress*100>pointArr.count-1) {
        progress = (pointArr.count-1)/100;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
	CGContextSetRGBStrokeColor(context, 0.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 13);
	CGContextSetLineCap(context, kCGLineCapRound);

    CGPoint startPoint = CGPointFromString([pointArr objectAtIndex:0]);
	CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    for (int i=0; i<self.progress*100; i++) {
        if (i>pointArr.count-1) {
            break;
        }
        NSString *point = [pointArr objectAtIndex:i];
        CGPoint p = CGPointFromString(point);
        CGContextAddLineToPoint(context, p.x, p.y);
    }
    CGContextStrokePath(context);
	CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextTranslateCTM(context, 0, self.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, 37, 45), progressImage.CGImage);
}

@end
