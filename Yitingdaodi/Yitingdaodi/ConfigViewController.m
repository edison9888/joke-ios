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
@interface ConfigViewController ()

@end

@implementation ConfigViewController {
    NSMutableArray *dataSource;
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
    return folderSizeStr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    dataSource = [[NSMutableArray alloc] init];
    [dataSource addObject:@[@"自动连播"]];
    [dataSource addObject:@[[NSString stringWithFormat:@"清除缓存 (已使用%@)", [self sizeOfFolder:NSTemporaryDirectory()]]]];
    [dataSource addObject:@[@"离线听 (下载最新20条)"]];
    [dataSource addObject:@[@"意见反馈", @"联系我们"]];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBarHidden = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor colorWithFullRed:227 green:227 blue:227 alpha:1];
    self.tableView.backgroundView = bgView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor grayColor];
    naviBar.titleLabel.text = @"设置";
    
}

//- (void)viewWillDisappear:(BOOL)animated{
//    [navi hideBar];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//}

- (void)viewDidAppear:(BOOL)animated{
    [UIView animateWithDuration:.3 animations:^{
        [navi showBar];
        self.tableView.frame = CGRectMake(0, 59, 320, [UIScreen screenHeight]-59);
    }];
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
        blackView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.5];
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
        UISwitch *swi = [[UISwitch alloc] init];
        [swi addTarget:self action:@selector(changePlayList:) forControlEvents:UIControlEventValueChanged];
        [swi setOn:[[[UserDataManager defaultUserData] valueForKey:@"autoPlay"] boolValue]];
        swi.center = CGPointMake(340-swi.frame.size.width, 55/2);
        [cell addSubview:swi];
    }

    return cell;
}

- (void)changePlayList:(UISwitch *)swi{
    [[UserDataManager defaultUserData] setValue:@(swi.on) forKey:@"autoPlay"];
    [UserDataManager synchronizeUserData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
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
        NSLog(@"%@", NSTemporaryDirectory());
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
        NSEnumerator *contentsEnumurator = [contents objectEnumerator];
        
        NSString *file;
        while (file = [contentsEnumurator nextObject]) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:file] error:nil];
        }
        
        [dataSource replaceObjectAtIndex:1 withObject:@[@"清除缓存 (已使用Zero KB)"]];
        [self.tableView reloadData];
    }
    if (indexPath.section==3&&indexPath.row==0) {
        RecordViewController *record = [[RecordViewController alloc] initWithFeedBack];
        [self.navigationController pushViewController:record animated:YES];
    }
}

@end
