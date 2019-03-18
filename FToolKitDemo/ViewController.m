//
//  ViewController.m
//  FToolKitDemo
//
//  Created by 武建明 on 2019/2/20.
//  Copyright © 2019 武建明. All rights reserved.
//

#import "ViewController.h"
#import "FToolKit.h"

@interface ViewController ()

@property (strong, nonatomic) UILabel *iconLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[FToolKit shareInstance] show];
    
    [self.view addSubview:self.iconLabel];

}

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        _iconLabel.text = @"调";
        _iconLabel.textColor = [UIColor greenColor];
        _iconLabel.backgroundColor = [UIColor grayColor];
        _iconLabel.font = [UIFont systemFontOfSize:20];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.layer.masksToBounds = YES;
        _iconLabel.layer.borderWidth = 1.5;
        _iconLabel.layer.borderColor = [UIColor blueColor].CGColor;
    }
    return _iconLabel;
}
@end
