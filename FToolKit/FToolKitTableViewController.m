//
//  FToolKitTableViewController.m
//  FToolKitDemo
//
//  Created by 武建明 on 2019/2/20.
//  Copyright © 2019 武建明. All rights reserved.
//

#import "FToolKitTableViewController.h"
#import "FToolKitWindow.h"
@interface FToolKitTableViewController ()

@end

@implementation FToolKitTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancle)];
}
- (void)cancle {
    [[FToolKitWindow shareInstance] setHidden:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSArray *)titleArray{
    return @[@"FLEX", @"Realm Browser"];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self titleArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"FToolKitCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
    }
    cell.textLabel.text = [[self titleArray] objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            NSLog(@"显示FLEX");
            break;
        case 1:
            NSLog(@"打开Realm Browser");
            break;
        default:
            break;
    }
    
}

@end
