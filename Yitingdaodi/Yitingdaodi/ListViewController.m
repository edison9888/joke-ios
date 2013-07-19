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
#import "RequestHelper.h"
#import "PullView.h"
#import "MobClick.h"
#import "AFHTTPRequestOperation.h"
#define SERVER_URL @"http://42.96.164.29:8888/"
typedef enum {
    navi_scrollto_up = 0,
    navi_scrollto_down,
    navi_none
} NaviScrollTo;

@interface ListViewController ()

@end

@implementation ListViewController {
    NSMutableArray *dateArr;
    NSMutableDictionary *dataDict;
    NSMutableDictionary *cells;
    PullView *progressView;
    float tempOffsetY;
    BOOL loading;
    int minus;
    BOOL end;
    NaviScrollTo scrollTo;
    NSIndexPath *currentIndexPath;
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
    [AudioManager defaultManager].delegate = self;
    scrollTo = navi_none;
    minus = 1;
    cells = [[NSMutableDictionary alloc] init];
    dateArr = [[NSMutableArray alloc] init];
    dataDict = [[NSMutableDictionary alloc] init];
    self.tableView.tableFooterView.hidden = YES;

    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:imageNamed(@"navi_shadow.png") forBarMetrics:UIBarMetricsDefault];
    self.tableView.backgroundColor = [UIColor colorWithFullRed:227 green:227 blue:227 alpha:1];
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor colorWithFullRed:227 green:227 blue:227 alpha:1];
    self.tableView.backgroundView = bgView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:imageNamed(@"voice.png") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(5, 0, 50, 44);
    UIView *voiceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    [voiceView addSubview:btn];
    UIBarButtonItem *voice = [[UIBarButtonItem alloc] initWithCustomView:voiceView];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setBackgroundImage:imageNamed(@"config.png") forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(config:) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(-5, 0, 50, 44);
    UIView *configView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    [configView addSubview:btn2];
    UIBarButtonItem *config = [[UIBarButtonItem alloc] initWithCustomView:configView];
    
    self.navigationItem.rightBarButtonItem = voice;
    self.navigationItem.leftBarButtonItem = config;
    self.navigationItem.title = @"一听到底";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor clearColor] forKey:UITextAttributeTextShadowColor];
    
    progressView = [[PullView alloc] init];
    [self.tableView addSubview:progressView];
    
    
    self.view.clipsToBounds = YES;
    
    if ([UIDevice isNetworkReachable]) {
        [self loadUpdate];
    } else {
        NSArray *datas = [[NSUserDefaults standardUserDefaults] valueForKey:@"datas"];
        if (datas && datas.count>0) {
            [self loadDatatoLocalData:datas];
            [self.tableView reloadData];
            [ApplicationDelegate performSelector:@selector(enterApp) withObject:nil afterDelay:.2];
        } else {
            [AppUtil warning:@"请检查网络连接!" withType:m_error];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y<0) {
        [progressView setProgress:scrollView.contentOffset.y/-70.0];
    } else {
        if(scrollView.contentOffset.y+scrollView.height<scrollView.contentSize.height) {
            if (tempOffsetY < scrollView.contentOffset.y && self.navigationController.navigationBar.y>-64) {
                scrollTo = navi_scrollto_up;
                float change = scrollView.contentOffset.y-tempOffsetY;
                float toY = self.navigationController.navigationBar.y - change;
                if (toY < -44) {
                    scrollTo = navi_none;
                    toY = -44;
                }
                self.navigationController.navigationBar.y = toY;
                toY = self.navigationController.visibleViewController.view.y-change;
                if (toY < -64) {
                    scrollTo = navi_none;
                    toY = -64;
                }
                self.navigationController.visibleViewController.view.y = toY;
                float toHeight = self.navigationController.visibleViewController.view.height+change;
                if (toHeight>[UIScreen screenHeight]) {
                    toHeight = [UIScreen screenHeight];
                }
                self.navigationController.visibleViewController.view.height = toHeight;
            } else if (tempOffsetY > scrollView.contentOffset.y && self.navigationController.navigationBar.y<20) {
                scrollTo = navi_scrollto_down;
                float change = tempOffsetY-scrollView.contentOffset.y;
                float toY = self.navigationController.navigationBar.y + change;
                if (toY > 20) {
                    scrollTo = navi_none;
                    toY = 20;
                }
                self.navigationController.navigationBar.y = toY;
                toY = self.navigationController.visibleViewController.view.y+change;
                if (toY > 0) {
                    scrollTo = navi_none;
                    toY = 0;
                }
                self.navigationController.visibleViewController.view.y = toY;
                float toHeight = self.navigationController.visibleViewController.view.height-change;
                if (toHeight<[UIScreen screenHeight]-64) {
                    toHeight = [UIScreen screenHeight]-64;
                }
                self.navigationController.visibleViewController.view.height = toHeight;
            } else {
                scrollTo = navi_none;
            }
            tempOffsetY = scrollView.contentOffset.y;
        }
        if (scrollView.contentOffset.y+scrollView.height>scrollView.contentSize.height/2 && !loading && !end && [UIDevice isNetworkReachable]) {
            NSLog(@"load more", nil);
            loading = YES;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, scrollView.contentSize.height-10, 320, 40)];
            label.tag = NSIntegerMax;
            label.backgroundColor = [UIColor clearColor];
            label.text = @"加载中";
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithFullRed:153 green:153 blue:153 alpha:1];
            label.shadowColor = [UIColor whiteColor];
            label.shadowOffset = CGSizeMake(0, 1);
            [self.tableView addSubview:label];
            scrollView.contentSize = CGSizeMake(0, scrollView.contentSize.height+40);
            [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(loadMore) userInfo:nil repeats:NO] forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (navi_scrollto_down == scrollTo) {
        [UIView animateWithDuration:.3 animations:^{
            self.navigationController.navigationBar.y = 20;
            self.navigationController.visibleViewController.view.y = 0;
        } completion:^(BOOL finished) {
            self.navigationController.visibleViewController.view.height = [UIScreen screenHeight]-44;
        }];
    } else if (navi_scrollto_up == scrollTo) {
        self.navigationController.visibleViewController.view.height = [UIScreen screenHeight];
        [UIView animateWithDuration:.3 animations:^{
            self.navigationController.navigationBar.y = -44;
            self.navigationController.visibleViewController.view.y = -64;
        }];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y<=-60 && [UIDevice isNetworkReachable]) {
        [MobClick event:@"pullRefresh"];
        NSLog(@"test", nil);
        [scrollView setContentOffset:CGPointMake(0, -60) animated:YES];
        [progressView startAnimation];
        [self performSelector:@selector(loadUpdate) withObject:nil afterDelay:.2];
    }
}

- (void)loadDatatoLocalData:(NSArray *)data{
    for (NSDictionary *dict in data) {
        NSString *dateStr = [[dict valueForKey:@"updated_at"] substringToIndex:10];//yyyyMMdd
        dateStr = [dateStr replace:@"-" withString:@""];
        NSMutableArray *datas = [NSMutableArray arrayWithArray:[dataDict valueForKey:dateStr]];
        [datas addObject:dict];
        [dataDict setValue:datas forKey:dateStr];
        if ([dateArr indexOfObject:dateStr]==NSIntegerMax) {
            [dateArr addObject:dateStr];
        }
    }
//    [dateArr sortUsingSelector:@selector(compare:)];
}

- (NSArray *)compaerArr:(NSArray *)arr{
    NSMutableArray *result = [NSMutableArray arrayWithArray:arr];
    for (NSDictionary *dict in arr) {
        NSString *dateStr = [[dict valueForKey:@"updated_at"] substringToIndex:10];//yyyyMMdd
        dateStr = [dateStr replace:@"-" withString:@""];
        NSMutableArray *datas = [NSMutableArray arrayWithArray:[dataDict valueForKey:dateStr]];
        NSString *str = [[dict valueForKey:@"id"] stringValue];
        for (NSDictionary *temp in datas) {
            if ([[[temp valueForKey:@"id"] stringValue] isEqualToString:str]) {
                [result removeObject:dict];
                break;
            }
        }
    }
    return result;
}

- (void)loadUpdate{
    loading = YES;
    
    NSDictionary *dict;
    BOOL needEnter = NO;;
    if (dateArr && dateArr.count>0) {
        NSString *dateStr = [dateArr objectAtIndex:0];//yyyyMMdd
        dict = @{@"date": dateStr, @"uid": [UIDevice udid], @"dir": @"0"};
    } else {
        needEnter = YES;
        dict = @{@"page": @"0", @"uid": [UIDevice udid]};
    }
    
    [[RequestHelper defaultHelper] requestGETAPI:@"api/myjokes" postData:dict success:^(id result) {
        NSArray *resultArr = @[[result valueForKey:@"myjokes"]];
        if (resultArr.count > 0 && [[resultArr objectAtIndex:0] count]>0) {
            resultArr = [self compaerArr:[resultArr objectAtIndex:0]];
            if (resultArr.count <= 0) {
                [AppUtil warning:@"已经是最新了噢!" withType:m_none];
            } else {
                [AppUtil warning:[NSString stringWithFormat:@"%d条新笑话", resultArr.count] withType:m_none];
                [self loadDatatoLocalData:resultArr];
            }
            [progressView stopAnimation];
            [self.tableView reloadData];
            [UIView animateWithDuration:.5 animations:^{
                self.tableView.contentOffset = CGPointZero;
            }];
        } else {
            [AppUtil warning:@"已经是最新了噢!" withType:m_none];
            [progressView stopAnimation];
            [UIView animateWithDuration:.5 animations:^{
                self.tableView.contentOffset = CGPointZero;
            }];
        }
        if (needEnter) {
            [ApplicationDelegate enterApp];
        }
        [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadDone) userInfo:nil repeats:NO] forMode:NSRunLoopCommonModes];
    } failed:^(id result, NSError *error) {
        [[self.tableView viewWithTag:NSIntegerMax] removeFromSuperview];
        [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadDone) userInfo:nil repeats:NO] forMode:NSRunLoopCommonModes];
    }];
}

- (void)loadMore{
    NSString *dateStr = [dateArr lastObject];//yyyyMMdd
    NSDateFormatter *sdf = [[NSDateFormatter alloc] init];
    [sdf setDateFormat:@"yyyyMMdd"];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -1;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSString *date = [sdf stringFromDate:[theCalendar dateByAddingComponents:dayComponent toDate:[sdf dateFromString:dateStr] options:0]];
    sdf = nil;
    dayComponent = nil;
    theCalendar = nil;
    
    [[RequestHelper defaultHelper] requestGETAPI:@"api/myjokes" postData:@{@"date": date, @"uid": [UIDevice udid], @"dir": @"1"} success:^(id result) {
        NSArray *resultArr = @[[result valueForKey:@"myjokes"]];
        if (resultArr.count > 0 && [[resultArr objectAtIndex:0] count]>0) {
            resultArr = [resultArr objectAtIndex:0];
            int count = dateArr.count;
            [self loadDatatoLocalData:resultArr];
            [progressView stopAnimation];
            [self.tableView beginUpdates];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(count, dateArr.count-count)] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadDone) userInfo:nil repeats:NO] forMode:NSRunLoopCommonModes];
        }
        [[self.tableView viewWithTag:NSIntegerMax] removeFromSuperview];
    } failed:^(id result, NSError *error) {
        [[self.tableView viewWithTag:NSIntegerMax] removeFromSuperview];
        [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadDone) userInfo:nil repeats:NO] forMode:NSRunLoopCommonModes];
    }];

}

- (void)loadDone{
    loading = NO;
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
    return dateArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dataDict valueForKey:[dateArr objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *simpleTableIdentifier = [NSString stringWithFormat:@"ListCell&%d&%d", indexPath.section,indexPath.row];
    
    Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [cells valueForKey:simpleTableIdentifier];
        if (cell==nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Cell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            NSString *key = [dateArr objectAtIndex:indexPath.section];
            NSDictionary *info = [[dataDict valueForKey:key] objectAtIndex:indexPath.row];
            cell.path = indexPath;
            cell.id1 = [info valueForKey:@"id"];
            cell.likeLabel.text = [[info valueForKey:@"num_likes"] stringValue];
            cell.time.text = [NSString stringWithFormat:@"%@%@", [info valueForKey:@"length"], @"''"];
            cell.playCount.text = [[info valueForKey:@"num_plays"] stringValue];
            [cell setImageURL:[NSString stringWithFormat:@"%@%@", SERVER_URL, [info valueForKey:@"full_picture_url"]]];
            if ([[info valueForKey:@"is_like"] boolValue]) {
                cell.likeBtn.selected = NO;
                cell.likeBtn.tag = 1;
            } else {
                cell.likeBtn.selected = YES;
                cell.likeBtn.tag = 0;
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = nil;
            [cells setValue:cell forKey:simpleTableIdentifier];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [[dataDict valueForKey:[dateArr objectAtIndex:indexPath.section]] count]-1) {
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
    if (end && section==dateArr.count-1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"你已经听到底了，明天再来听吧";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithFullRed:153 green:153 blue:153 alpha:1];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        return label;
    } else {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        header.backgroundColor = [UIColor clearColor];
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speator.png"]];
        line.center = CGPointMake(320./2, 45./2);
        [header addSubview:line];
        
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectChangeY(header.frame, 0)];
        date.backgroundColor = [UIColor clearColor];
        date.center = line.center;
        
        
        if ([dateArr objectAtIndex:section]!=[NSNull null]) {
            date.text = [dateArr objectAtIndex:section];
        }
        date.textAlignment = NSTextAlignmentCenter;
        date.font = [UIFont systemFontOfSize:12];
        date.textColor = [UIColor colorWithFullRed:153 green:153 blue:153 alpha:1];
        date.shadowColor = [UIColor whiteColor];
        date.shadowOffset = CGSizeMake(0, 1);
        [header addSubview:date];
        return header;
    }
}

//
//- (void)viewDidAppear:(BOOL)animated{
//    self.view.window.backgroundColor = [UIColor blackColor];
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//    self.view.window.backgroundColor = [UIColor colorWithFullRed:227 green:227 blue:227 alpha:1];
//}

- (void)backUp{
    NSMutableArray *backUpArr = [NSMutableArray array];
    for (NSArray *temp in dataDict.allValues) {
        for (NSDictionary *dict in temp) {
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            for (NSString *key in dict.allKeys) {
                id val = [dict valueForKey:key];
                if (val == [NSNull null]) {
                    [tempDict setValue:@"" forKey:key];
                }
            }
            [backUpArr addObject:tempDict];
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:backUpArr forKey:@"datas"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [backUpArr removeAllObjects];
    backUpArr = nil;
}

- (void)config:(UIButton *)btn{
    ConfigViewController *config = [[ConfigViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:config animated:YES];
}

- (void)record:(UIButton *)btn{
    RecordViewController *record = [[RecordViewController alloc] init];
    [self.navigationController pushViewController:record animated:YES];
}

- (NSString *)pathWithURL:(NSString *)url{
    return [[url componentsSeparatedByString:@"/"] lastObject];
}

- (void)cacheToLocal{
    [self backUp];
    int count = 0;
    for (NSArray *temp in dataDict.allValues) {
        count+=temp.count;
    }
    float part = 100.0/count/100.0;
    int index = 0;
    for (NSArray *temp in dataDict.allValues) {
        for (NSDictionary *dict in temp) {
            NSString *url = [dict valueForKey:@"full_audio_url"];
            NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self pathWithURL:url]];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, url]]];
            AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation1.outputStream = [NSOutputStream outputStreamToFileAtPath:cachePath append:NO];
            [operation1 setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead, NSData *receiveData) {
                float progress = (totalBytesRead*1.0)/(totalBytesExpectedToRead*1.0);
                progress = index*part+(part*progress);
                [[NSNotificationCenter defaultCenter] postNotificationName:AudioCacheAllProgressNotification object:@(progress)];
            }];
            [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"download complet", nil);
//                [[NSFileManager defaultManager] moveItemAtPath:cachePath toPath:path error:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"download failed", nil);
                [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
            }];
            //        [operation1 start];
            [ApplicationDelegate.queue addOperation:operation1];
            index++;
        }
    }
}

- (NSIndexPath *)currentIndex{
    return currentIndexPath;
}

- (void)playIndex:(NSIndexPath *)indexPath{
    NSLog(@"play %d %d", indexPath.section, indexPath.row);

    NSString *simpleTableIdentifier = [NSString stringWithFormat:@"ListCell&%d&%d", currentIndexPath.section,currentIndexPath.row];
    Cell *cell = [cells valueForKey:simpleTableIdentifier];
//    [cell pauseAudio:nil];
    [cell removePlayingView];
    currentIndexPath = indexPath;
    simpleTableIdentifier = [NSString stringWithFormat:@"ListCell&%d&%d", currentIndexPath.section,currentIndexPath.row];
    cell = [cells valueForKey:simpleTableIdentifier];
    [cell playUI];
    [cell addPlayingView];
    [[AudioManager defaultManager] playWithURL:[self urlWithIndex:indexPath]];
}

- (BOOL)hasCacheWithIndex:(NSIndexPath *)indexPath{
    NSString *url = [[[dataDict valueForKey:[dateArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"full_audio_url"];
    NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self pathWithURL:url]];
    return [[NSFileManager defaultManager] fileExistsAtPath:cachePath];
}

- (NSString *)urlWithIndex:(NSIndexPath *)indexPath{
    NSString *url = [[[dataDict valueForKey:[dateArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"full_audio_url"];
    return [NSString stringWithFormat:@"%@%@", SERVER_URL,url ];
}

#pragma mark - audio delegate

- (void)playNext{
    int section = currentIndexPath.section;
    int row = currentIndexPath.row;
    int count = [[dataDict valueForKey:[dateArr objectAtIndex:section]] count];
    if (row==count-1) {
        if (section==dateArr.count-1) {
            return;
        }
        section += 1;
        row = 0;
    } else {
        row += 1;
    }
    [self playIndex:[NSIndexPath indexPathForRow:row inSection:section]];
    [self.tableView scrollToRowAtIndexPath:currentIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)playPre{
    int section = currentIndexPath.section;
    int row = currentIndexPath.row;
    if (row==0) {
        if (section==0) {
            return ;
        }
        section -= 1;
        row = [[dataDict valueForKey:[dateArr objectAtIndex:section]] count]-1;
    } else {
        row -= 1;
    }
    [self playIndex:[NSIndexPath indexPathForRow:row inSection:section]];
    [self.tableView scrollToRowAtIndexPath:currentIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

@end
