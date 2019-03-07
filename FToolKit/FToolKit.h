//
//  FToolKit.h
//  FToolKitDemo
//
//  Created by 武建明 on 2019/2/20.
//  Copyright © 2019 武建明. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FToolKit : UIView

+ (FToolKit *)shareInstance;

@property (nonatomic) CGRect limitRect;//View所能活动的区域范围，包括四个方向的临界
@property (nonatomic) CGRect deletedRect;//View所能活动的区域范围，包括四个方向的临界
@property (nonatomic, assign) BOOL adsorptionTop;//能否吸附顶部
@property (nonatomic, assign) BOOL adsorptionBottom;//能否吸附底部
@property (nonatomic, assign) CGFloat limitX;//左右距离活动区域边界,默认40
@property (nonatomic, assign) CGFloat limitY;//上下距离活动区域边界,默认40

- (void)show;

- (void)remove;

@end

NS_ASSUME_NONNULL_END
