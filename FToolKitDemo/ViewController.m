//
//  ViewController.m
//  FToolKitDemo
//
//  Created by 武建明 on 2019/2/20.
//  Copyright © 2019 武建明. All rights reserved.
//

#import "ViewController.h"
#import "FToolKitWindow.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[FToolKitWindow shareInstance] show];

}


@end
