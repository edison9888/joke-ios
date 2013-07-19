//
//  ConfigViewController.m
//  Yitingdaodi
//
//  Created by Johnil on 13-6-18.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "ConfigViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RecordViewController.h"
#import "UserDataManager.h"
#import "iRate.h"
#import "MobClick.h"
@interface ConfigViewController ()

@end

@implementation ConfigViewController {
    NSMutableArray *dataSource;
    UILabel *progressLabel;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSString *)sizeOfFolder:(NSString *)folderPath
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long int folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    
    //This line will give you formatted size from bytes ....
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    if ([folderSizeStr isEqualToString:@"Zero KB"]) {
        folderSizeStr = @"0 KB";
    }
    return folderSizeStr;
}

- (void)viewWillAppear:(BOOL)animated{
    naviBar.titleLabel.text = @"设置";
    [navi showBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    dataSource = [[NSMutableArray alloc] init];
    [dataSource addObject:@[@"自动连播"]];
    [dataSource addObject:@[[NSString stringWithFormat:@"清除缓存 (已使用%@)", [self sizeOfFolder:NSTemporaryDirectory()]]]];
    [dataSource addObject:@[@"离线听"]];
    [dataSource addObject:@[@"意见反馈", @"给个好评呗", @"关于一听到底"]];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.tableView.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor colorWithFullRed:227 green:227 blue:227 alpha:1];
    self.tableView.backgroundView = bgView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor grayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        UIView *blackView = [[UIView alloc] initWithFrame:cell.backgroundView.frame];
        blackView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.5];
        cell.selectedBackgroundView = blackView;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        if ([[dataSource objectAtIndex:indexPath.section] count]==1) {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[imageNamed(@"cell_once.png") resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
        } else {
            if (indexPath.row == 0) {
                cell.backgroundView = [[UIImageView alloc] initWithImage:[imageNamed(@"cell_top.png") resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
            } else if (indexPath.row == [[dataSource objectAtIndex:indexPath.section] count]-1) {
                cell.backgroundView = [[UIImageView alloc] initWithImage:[imageNamed(@"cell_bottom.png") resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
            } else {
                cell.backgroundView = [[UIImageView alloc] initWithImage:[imageNamed(@"cell_center.png") resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
            }
        }
        if (indexPath.section==3) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell.textLabel.text = [[dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (indexPath.section==0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *swi = [[UISwitch alloc] init];
        [swi addTarget:self action:@selector(changePlayList:) forControlEvents:UIControlEventValueChanged];
        [swi setOn:[[[UserDataManager defaultUserData] valueForKey:@"autoPlay"] boolValue]];
        swi.center = CGPointMake(340-swi.frame.size.width, 55/2);
        [cell addSubview:swi];
    } else if (indexPath.section==2 && !progressLabel){
        progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 55)];
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.textAlignment = NSTextAlignmentRight;
        progressLabel.text = @"0.0%";
        [cell addSubview:progressLabel];
    }

    return cell;
}

- (void)changePlayList:(UISwitch *)swi{
    [MobClick event:@"openPlayList" label:swi.on?@"打开":@"关闭"];

    [[UserDataManager defaultUserData] setValue:@(swi.on) forKey:@"autoPlay"];
    [UserDataManager synchronizeUserData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?70:0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    return 0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1) {
//        NSLog(@"%@", NSTemporaryDirectory());
        [MobClick event:@"clearCache"];

        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
        NSEnumerator *contentsEnumurator = [contents objectEnumerator];
        
        NSString *file;
        while (file = [contentsEnumurator nextObject]) {
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"datas"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:file] error:nil];
        }
        [AppUtil warning:@"缓存已清空" withType:m_success];
        [dataSource replaceObjectAtIndex:1 withObject:@[@"清除缓存 (已使用0 KB)"]];
        [self.tableView reloadData];
    }
    if (indexPath.section==2) {
        if (![UIDevice isNetworkReachable]) {
            [AppUtil warning:@"请检查网络连接!" withType:m_error];
            return;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:AudioCacheAllProgressNotification object:nil];
        [MobClick event:@"offline"];
        [List cacheToLocal];
    }
    if (indexPath.section==3&&indexPath.row==0) {
        RecordViewController *record = [[RecordViewController alloc] initWithFeedBack];
        [self.navigationController pushViewController:record animated:YES];
    }
    if (indexPath.section==3&&indexPath.row==1) {
        [[iRate sharedInstance] openRatingsPageInAppStore];
    }
}

- (void)updateProgress:(NSNotification *)notifi{
    float progress = [notifi.object floatValue];
    progressLabel.text = [NSString stringWithFormat:@"%.2f%%", progress*100];
}

@end
