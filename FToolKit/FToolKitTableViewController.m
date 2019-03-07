//
//  FToolKitTableViewController.m
//  FToolKitDemo
//
//  Created by 武建明 on 2019/2/20.
//  Copyright © 2019 武建明. All rights reserved.
//

#import "FToolKitTableViewController.h"
#import "FToolKit.h"
#if __has_include(<FHHFPSIndicator/FHHFPSIndicator.h>)
#import <FHHFPSIndicator/FHHFPSIndicator.h>
#else
#import "FHHFPSIndicator.h"
#endif

#if __has_include(<FLEX/FLEX.h>)
#import <FLEX/FLEX.h>
#else
#import "FLEX.h"
#endif

#if __has_include(<RealmBrowserKit/RealmBrowserKit.h>)
#import <RealmBrowserKit/RLMBrowserViewController.h>
#else
#import "RLMBrowserViewController.h"
#endif

@interface FToolKitTableViewController ()

@end

@implementation FToolKitTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancle)];
}
- (void)cancle {
    [self dismissViewControllerAnimated:YES completion:^{
        [FToolKit shareInstance].hidden = NO;
    }];
}

- (NSArray *)titleArray{
    return @[@"FLEX", @"FHHFPSIndicator", @"Realm Browser"];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self titleArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"FToolKitCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:cellID];
    }
    cell.textLabel.text = [[self titleArray] objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0) {
        if ([[FHHFPSIndicator sharedFPSIndicator] isShowingFps]) {
            cell.detailTextLabel.text = @"关闭";
        }else{
            cell.detailTextLabel.text = @"打开";
        }
    }else if (indexPath.row == 1) {
        if (![[FLEXManager sharedManager] isHidden]) {
            cell.detailTextLabel.text = @"关闭";
        }else{
            cell.detailTextLabel.text = @"打开";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0) {
        if (![[FHHFPSIndicator sharedFPSIndicator] isShowingFps]) {
            [[FHHFPSIndicator sharedFPSIndicator] show];
            [[FHHFPSIndicator sharedFPSIndicator] setFpsLabelColor:[UIColor redColor]];
            [FHHFPSIndicator sharedFPSIndicator].fpsLabelPosition = FPSIndicatorPositionBottomCenter;
        }else {
            [[FHHFPSIndicator sharedFPSIndicator] hide];
        }
        [self cancle];
    }else if (indexPath.row == 1) {
        if ([[FLEXManager sharedManager] isHidden]) {
            [[FLEXManager sharedManager] showExplorer];
        }else {
            [[FLEXManager sharedManager] hideExplorer];
        }
        [self cancle];
    }else if (indexPath.row == 2) {
        RLMBrowserViewController *controller = [[RLMBrowserViewController alloc] init];
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }
}

@end
