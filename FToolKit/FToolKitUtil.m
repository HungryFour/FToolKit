//
//  FToolKitUtil.m
//  FToolKitDemo
//
//  Created by 武建明 on 2019/2/20.
//  Copyright © 2019 武建明. All rights reserved.
//

#import "FToolKitUtil.h"
#import <UIKit/UIKit.h>

@implementation FToolKitUtil

+ (BOOL)isIPhoneXSeries{
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}

@end
