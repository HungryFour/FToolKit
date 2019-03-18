//
//  FToolKitAlignKit.h
//  FBRetainCycleDetector
//
//  Created by 武建明 on 2019/3/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FToolKitAlignKit : UIView

+ (FToolKitAlignKit *)shareInstance;

- (void)show;

- (void)remove;

- (BOOL)isShowing;

@end

NS_ASSUME_NONNULL_END
