//
//  FColorPickKit.h
//
//  Created by 武建明 on 2019/3/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FColorPickKitAmplificationWindow : UIWindow


/**
 放大镜的宽高（默认为90）
 */
@property (nonatomic, assign) CGFloat amplificationSize;

/**
 放大倍数（默认2.0）
 */
@property (nonatomic, assign) CGFloat amplification;

/**
 目标视图的Window
 */
@property (nonatomic, strong) UIView *targetWindow;

/**
 目标视图展示位置
 */
@property (nonatomic, assign) CGPoint targetPoint;

@end

@interface FColorPickKit : UIWindow

+ (FColorPickKit *)shareInstance;

- (void)show;
@end

NS_ASSUME_NONNULL_END
