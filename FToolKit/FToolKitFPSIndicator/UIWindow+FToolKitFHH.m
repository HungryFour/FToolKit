//
//  UIWindow+FToolKitFHH.m
//  FBRetainCycleDetector
//
//  Created by 武建明 on 2019/3/18.
//

#import "UIWindow+FToolKitFHH.h"

static NSInteger kFpsLabelTag = 110213;

@implementation UIWindow (FToolKitFHH)

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (NSUInteger i = 0; i < self.subviews.count; ++i) {
        UIView *view = self.subviews[self.subviews.count - 1 - i];
        if ([view isKindOfClass:[UILabel class]] && view.tag == kFpsLabelTag) {
            if (view == self.subviews.lastObject) {
                return;
            }
            [self bringSubviewToFront:view];
            return;
        }
    }
}

@end
