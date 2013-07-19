//
//  ListViewController.h
//  yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController <AudioManagerDelegate>

- (void)backUp;
- (NSIndexPath *)currentIndex;
- (void)playIndex:(NSIndexPath *)indexPath;
- (BOOL)hasCacheWithIndex:(NSIndexPath *)indexPath;
- (NSString *)urlWithIndex:(NSIndexPath *)indexPath;
- (void)cacheToLocal;

@end
