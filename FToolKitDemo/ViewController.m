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

@property (strong, nonatomic) UIImageView *testImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[FToolKit shareInstance] show];
    
    [self.view addSubview:self.testImageView];

}

- (UIImageView *)testImageView {
    if (!_testImageView) {
        _testImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _testImageView.image = [UIImage imageNamed:@"test"];
    }
    return _testImageView;
}
@end
