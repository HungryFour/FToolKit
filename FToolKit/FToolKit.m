//
//  FToolKit.m
//
//  Created by 武建明 on 2019/2/20.
//  Copyright © 2019 武建明. All rights reserved.
//

#import "FToolKit.h"
#import "FToolKitDefine.h"
#import "FToolKitTableViewController.h"

#define FToolKitWidth  44
#define FToolKitHeight 44
#define TAG_ToolKit (110554)
#define TAG_ToolKitMNAV (110553)


static const CGFloat kUIAutoHideTimeInterval = 3.0;//UI显示时间
static const CGFloat kUIShowTimeInterval = 0.3;//UI渐变时间


@interface FToolKit () {
    CGPoint lastPoint;
}

@property (assign, nonatomic)BOOL isShow;

@property (strong, nonatomic) UILabel *iconLabel;

@end

@implementation FToolKit

+ (FToolKit *)shareInstance{
    static dispatch_once_t once;
    static FToolKit *instance;
    dispatch_once(&once, ^{
        instance = [[FToolKit alloc] initWithFrame:[self originFrame]];
        instance.tag = TAG_ToolKit;
    });
    return instance;
}

+ (CGRect)originFrame {
    return CGRectMake(FToolKitScreenWidth-FToolKitWidth*2, FToolKitScreenHeight-FToolKitWidth*4, FToolKitWidth, FToolKitHeight);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor= [UIColor whiteColor];
//        self.windowLevel=UIWindowLevelAlert+1;
        self.backgroundColor = [UIColor clearColor];
        [self defaultConfig];
        [self addSubview:self.iconLabel];
        self.alpha = 0.5;
        self.isShow = NO;
    }
    return self;
}
- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _iconLabel.text = @"调";
        _iconLabel.textColor = [UIColor greenColor];
        _iconLabel.backgroundColor = [UIColor clearColor];
        _iconLabel.font = [UIFont systemFontOfSize:20];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.layer.cornerRadius = FToolKitHeight/2;
        _iconLabel.layer.masksToBounds = YES;
        _iconLabel.layer.borderWidth = 1.5;
        _iconLabel.layer.borderColor = [UIColor blueColor].CGColor;
    }
    return _iconLabel;
}
- (void)defaultConfig {
    [self addGesture];
    self.userInteractionEnabled = YES;
    self.limitRect = CGRectMake(0, IPHONE_NAVIGATIONBAR_HEIGHT, FToolKitScreenWidth, FToolKitScreenHeight-IPHONE_STATUSBAR_HEIGHT-IPHONE_SAFEBOTTOMAREA_HEIGHT-FToolKitHeight-2*FToolKitWidth);
    self.deletedRect = CGRectMake(0, FToolKitScreenHeight-2*FToolKitWidth, FToolKitScreenWidth, 2*FToolKitWidth);
    self.adsorptionTop = NO;
    self.adsorptionBottom = NO;
}

-(void)addGesture{
    //拖动
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
    pan.delaysTouchesBegan = YES;
    [self addGestureRecognizer:pan];
    //点击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClick:)];
    [self addGestureRecognizer:tap];
}

- (void)didClick:(UITapGestureRecognizer *)tap{
    [self animateControlShow];
    [self showTableViewController];
}
/* 隐藏UI */
- (void)animateControlHide
{
    if (!self.isShow) {
        return;
    }
    self.isShow = NO;
    [UIView animateWithDuration:kUIShowTimeInterval animations:^{
        self.alpha = 0.5;
    } completion:^(BOOL finished) {

    }];
}
/* 展示UI */
- (void)animateControlShow{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateControlHide) object:nil];
    self.isShow = YES;
    [UIView animateWithDuration:kUIShowTimeInterval animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self autoFadeOutUI];
    }];
}

- (void)showTableViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootController = window.rootViewController;
    if ([rootController.presentedViewController isKindOfClass:[UINavigationController class]] && (rootController.presentedViewController.view.tag==TAG_ToolKitMNAV)) {
        return;
    }
    self.hidden = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[FToolKitTableViewController alloc] init]];
    nav.view.tag = TAG_ToolKitMNAV;
    [rootController presentViewController:nav animated:YES completion:nil];
}

/* 自动展示UI */
- (void)autoFadeOutUI {
    if (!self.isShow) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateControlHide) object:nil];
    [self performSelector:@selector(animateControlHide) withObject:nil afterDelay:kUIAutoHideTimeInterval];
}
//改变位置
-(void)locationChange:(UIGestureRecognizer*)gestureRecognizer {
    [self animateControlShow];
    CGPoint panPoint = [gestureRecognizer locationInView:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //拖动开始
        lastPoint = CGPointMake(panPoint.x, panPoint.y);
    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //拖动过程中
        self.center = CGPointMake(self.center.x + panPoint.x-lastPoint.x, self.center.y+panPoint.y-lastPoint.y);
        lastPoint = CGPointMake(panPoint.x, panPoint.y);
        
        if (CGRectContainsPoint(self.deletedRect, self.center)) {
            self.iconLabel.text = @"删";
            self.iconLabel.textColor = [UIColor redColor];
        }else{
            self.iconLabel.text = @"调";
            self.iconLabel.textColor = [UIColor greenColor];
        }
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        // 如果拖动结束后,在删除区域,则进入毁灭程序
        if (CGRectContainsPoint(self.deletedRect, self.center)) {
            [self remove];
            return;
        }
        
        //拖动结束，释放，此时需要根据位置，将self恢复到边缘位置
        //根据当前中心点的坐标，超过限定区域的一半，则在右侧，否则在左侧
        CGPoint endPoint ;
        CGPoint currentCenter = CGPointMake(self.center.x + panPoint.x-lastPoint.x, self.center.y+panPoint.y-lastPoint.y);
        CGFloat dxL = currentCenter.x - self.limitRect.origin.x - self.limitX;
        CGFloat dxR = CGRectGetMaxX(self.limitRect) - currentCenter.x - self.limitX;
        CGFloat dyT = currentCenter.y - self.limitRect.origin.y - self.limitY;
        CGFloat dyB = CGRectGetMaxY(self.limitRect) - currentCenter.y - self.limitY;
        CGFloat newX = currentCenter.x;
        CGFloat newY = currentCenter.y;
        //1、处理边界位置的情况
        if(currentCenter.x<(self.limitRect.origin.x + FToolKitWidth*0.5f)){
            //太靠左
            newX = (self.limitRect.origin.x + FToolKitWidth*0.5f);
        }
        if(currentCenter.x > (CGRectGetMaxX(self.limitRect) - FToolKitWidth*0.5f)){
            //太靠右
            newX = (CGRectGetMaxX(self.limitRect) - FToolKitWidth*0.5f);
        }
        
        if(currentCenter.y < (self.limitRect.origin.y + FToolKitHeight*0.5f)){
            //太靠上
            newY =  (self.limitRect.origin.y + FToolKitHeight*0.5f);
        }
        if(currentCenter.y > (CGRectGetMaxY(self.limitRect)- FToolKitHeight*0.5f)){
            //太靠下
            newY =  (CGRectGetMaxY(self.limitRect) - FToolKitHeight*0.5f);
        }
        
        //处理是在左侧还是在右侧
        if(currentCenter.x <= CGRectGetMidX(self.limitRect)){//在区域的左侧
            if(dyT <= dyB && dxL > dyT && self.adsorptionTop){//顶部
                newY = (self.limitRect.origin.y + FToolKitHeight*0.5f);
            }else if(dyT > dyB && dxL > dyB && self.adsorptionBottom){//底部
                newY =  (CGRectGetMaxY(self.limitRect) - FToolKitHeight*0.5f);
            }else{
                newX = (self.limitRect.origin.x + FToolKitWidth*0.5f);
            }
            
        }else{//在区域右侧
            if(dyT <= dyB && dxR > dyT && self.adsorptionTop){//顶部
                newY =  (self.limitRect.origin.y + FToolKitHeight*0.5f);
            }else if(dyT > dyB && dxR > dyB && self.adsorptionBottom){//底部
                newY =  (CGRectGetMaxY(self.limitRect) - FToolKitHeight*0.5f);
            }else{
                newX = (CGRectGetMaxX(self.limitRect) - FToolKitWidth*0.5f);
            }
        }
        
        endPoint = CGPointMake(newX, newY);
        [UIView animateWithDuration:0.2 animations:^{
            self.center = endPoint;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)show {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
        for (UIView *view in keyWindow.subviews) {
            if ([view isKindOfClass:[FToolKit class]] && view.tag == TAG_ToolKit) {
                return;
            }
        }
        self.frame = [FToolKit originFrame];
        [keyWindow addSubview:self];
    });
}

- (void)remove {
    [self removeFromSuperview];
}

@end
