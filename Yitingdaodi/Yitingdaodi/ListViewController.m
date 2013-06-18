//
//  ListViewController.m
//  yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "ListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Cell.h"
#import "AudioManager.h"
#import "ConfigViewController.h"
#import "RecordViewController.h"
@interface ListViewController ()

@end

@implementation ListViewController {
    NSMutableArray *datas;
    NSMutableDictionary *cells;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    cells = [[NSMutableDictionary alloc] init];
    datas = [[NSMutableArray alloc] init];
    [datas addObject:@[
     @{@"date": @"2013-06-18"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/1.mp3", @"likes":@"123", @"plays":@"123123", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/2.mp3", @"likes":@"543", @"plays":@"123", @"time":@"133"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/3.mp3", @"likes":@"567", @"plays":@"23", @"time":@"23"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/4.mp3", @"likes":@"23452", @"plays":@"12763", @"time":@"153"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/5.mp3", @"likes":@"3451", @"plays":@"879", @"time":@"167"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/1.mp3", @"likes":@"12312", @"plays":@"45", @"time":@"126"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/2.mp3", @"likes":@"2", @"plays":@"4645", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/3.mp3", @"likes":@"31231", @"plays":@"5765", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/4.mp3", @"likes":@"12343", @"plays":@"345", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/5.mp3", @"likes":@"34512", @"plays":@"765", @"time":@"123"}
     ]];
    [datas addObject:@[
     @{@"date": @"2013-06-17"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/1.mp3", @"likes":@"123", @"plays":@"123123", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/2.mp3", @"likes":@"543", @"plays":@"123", @"time":@"133"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/3.mp3", @"likes":@"567", @"plays":@"23", @"time":@"23"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/4.mp3", @"likes":@"23452", @"plays":@"12763", @"time":@"153"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/5.mp3", @"likes":@"3451", @"plays":@"879", @"time":@"167"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/1.mp3", @"likes":@"12312", @"plays":@"45", @"time":@"126"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/2.mp3", @"likes":@"2", @"plays":@"4645", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/3.mp3", @"likes":@"31231", @"plays":@"5765", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/4.mp3", @"likes":@"12343", @"plays":@"345", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/5.mp3", @"likes":@"34512", @"plays":@"765", @"time":@"123"}
     ]];
    [datas addObject:@[
     @{@"date": @"2013-06-16"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/1.mp3", @"likes":@"123", @"plays":@"123123", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/2.mp3", @"likes":@"543", @"plays":@"123", @"time":@"133"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/3.mp3", @"likes":@"567", @"plays":@"23", @"time":@"23"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/4.mp3", @"likes":@"23452", @"plays":@"12763", @"time":@"153"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/5.mp3", @"likes":@"3451", @"plays":@"879", @"time":@"167"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/1.mp3", @"likes":@"12312", @"plays":@"45", @"time":@"126"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/2.mp3", @"likes":@"2", @"plays":@"4645", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/3.mp3", @"likes":@"31231", @"plays":@"5765", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/1.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/4.mp3", @"likes":@"12343", @"plays":@"345", @"time":@"123"},
     @{@"imgURL":@"http://tome-file.b0.upaiyun.com/2.JPG", @"mp3URL":@"http://tome-file.b0.upaiyun.com/5.mp3", @"likes":@"34512", @"plays":@"765", @"time":@"123"}
     ]];

    [self createAudioPlayList];

    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:imageNamed(@"navi_shadow.png") forBarMetrics:UIBarMetricsDefault];
    self.tableView.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor colorWithFullRed:227 green:227 blue:227 alpha:1];
    self.tableView.backgroundView = bgView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:imageNamed(@"voice.png") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(-5, 0, 50, 44);
    UIView *voiceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    [voiceView addSubview:btn];
    UIBarButtonItem *voice = [[UIBarButtonItem alloc] initWithCustomView:voiceView];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setBackgroundImage:imageNamed(@"config.png") forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(config:) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(5, 0, 50, 44);
    UIView *configView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    [configView addSubview:btn2];
    UIBarButtonItem *config = [[UIBarButtonItem alloc] initWithCustomView:configView];
    
    self.navigationItem.leftBarButtonItem = voice;
    self.navigationItem.rightBarButtonItem = config;
    self.navigationItem.title = @"一听到底";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor clearColor] forKey:UITextAttributeTextShadowColor];
}

- (void)createAudioPlayList{
    NSMutableArray *playList = [NSMutableArray array];
    for (NSArray *arr in datas) {
        for (NSDictionary *dict in arr) {
            if ([dict valueForKey:@"mp3URL"] != nil) {
                [playList addObject:[dict valueForKey:@"mp3URL"]];
            }
        }
    }
    [[AudioManager defaultManager] addAudioListToList:playList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [cells removeAllObjects];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [[datas objectAtIndex:section] count];
    return count==0?0:count-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *simpleTableIdentifier = [NSString stringWithFormat:@"ListCell%d%d", indexPath.section,indexPath.row];
    
    Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [cells valueForKey:simpleTableIdentifier];
        if (cell==nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Cell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            cell.tag = (indexPath.section+1)*indexPath.row;
            NSDictionary *info = [[datas objectAtIndex:indexPath.section] objectAtIndex:indexPath.row+1];
            [cell.likeBtn setTitle:[NSString stringWithFormat:@"  %@", [info valueForKey:@"likes"]] forState:UIControlStateNormal];
            cell.time.text = [NSString stringWithFormat:@"%@%@", [info valueForKey:@"time"], @"''"];
            cell.playCount.text = [info valueForKey:@"plays"];
            [cell setImageURL:[info valueForKey:@"imgURL"]];
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = nil;
            if (arc4random()%2==0) {
                cell.likeBtn.selected = YES;
                cell.likeBtn.tag = -1;
            }
            [cells setValue:cell forKey:simpleTableIdentifier];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [[datas objectAtIndex:indexPath.section] count]-1) {
        return 344;
    }
    return 354+10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    header.backgroundColor = [UIColor clearColor];
    UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speator.png"]];
    line.center = CGPointMake(320./2, 45./2);
    [header addSubview:line];
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectChangeY(header.frame, 0)];
    date.backgroundColor = [UIColor clearColor];
    date.center = line.center;
    date.text = [[[datas objectAtIndex:section] objectAtIndex:0] valueForKey:@"date"];
    date.textAlignment = NSTextAlignmentCenter;
    date.font = [UIFont systemFontOfSize:12];
    date.textColor = [UIColor colorWithFullRed:153 green:153 blue:153 alpha:1];
    date.shadowColor = [UIColor whiteColor];
    date.shadowOffset = CGSizeMake(0, 1);
    [header addSubview:date];
    return header;
}

- (void)config:(UIButton *)btn{
    ConfigViewController *config = [[ConfigViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:config animated:YES];
}

- (void)record:(UIButton *)btn{
    RecordViewController *record = [[RecordViewController alloc] init];
    [self.navigationController pushViewController:record animated:YES];
}
@end
