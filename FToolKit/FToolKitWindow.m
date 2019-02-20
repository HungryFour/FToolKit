//
//  FToolKitWindow.m
//  FToolKitDemo
//
//  Created by 武建明 on 2019/2/20.
//  Copyright © 2019 武建明. All rights reserved.
//

#import "FToolKitWindow.h"
#import "FToolKitDefine.h"
#import "FToolKitTableViewController.h"

#define FToolKitWindowWidth  44
#define FToolKitWindowHeight 44


static const CGFloat kUIAutoHideTimeInterval = 3.0;//UI显示时间

static const CGFloat kUIShowTimeInterval = 0.3;//UI渐变时间

@interface FToolKitWindow () {
    CGPoint lastPoint;
}

@property (assign, nonatomic)BOOL isShow;

@property (strong, nonatomic) UILabel *iconLabel;

@end

@implementation FToolKitWindow

+ (FToolKitWindow *)shareInstance{
    static dispatch_once_t once;
    static FToolKitWindow *instance;
    dispatch_once(&once, ^{
        instance = [[FToolKitWindow alloc] initWithFrame:CGRectMake(FToolKitScreenWidth-FToolKitWindowWidth*2, FToolKitScreenHeight-FToolKitWindowWidth*4, FToolKitWindowWidth, FToolKitWindowHeight)];
        [instance setRootViewController:[UIViewController new]];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor= [UIColor whiteColor];
        self.windowLevel=UIWindowLevelAlert+1;
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
        _iconLabel.layer.cornerRadius = FToolKitWindowHeight/2;
        _iconLabel.layer.masksToBounds = YES;
        _iconLabel.layer.borderWidth = 1.5;
        _iconLabel.layer.borderColor = [UIColor blueColor].CGColor;
    }
    return _iconLabel;
}
- (void)defaultConfig {
    [self addGesture];
    self.userInteractionEnabled = YES;
    self.limitRect = CGRectMake(0, IPHONE_NAVIGATIONBAR_HEIGHT, FToolKitScreenWidth, FToolKitScreenHeight-IPHONE_STATUSBAR_HEIGHT-IPHONE_SAFEBOTTOMAREA_HEIGHT);
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
    UIWindow *appWindow = [[UIApplication sharedApplication].delegate window];
    self.hidden = YES;
    [appWindow.rootViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:[[FToolKitTableViewController alloc] init]] animated:YES completion:^{
        
    }];
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
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //拖动结束，释放，此时需要根据位置，将图片恢复到边缘位置
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
        if(currentCenter.x<(self.limitRect.origin.x + FToolKitWindowWidth*0.5f)){
            //太靠左
            newX = (self.limitRect.origin.x + FToolKitWindowWidth*0.5f);
        }
        if(currentCenter.x > (CGRectGetMaxX(self.limitRect) - FToolKitWindowWidth*0.5f)){
            //太靠右
            newX = (CGRectGetMaxX(self.limitRect) - FToolKitWindowWidth*0.5f);
        }
        
        if(currentCenter.y < (self.limitRect.origin.y + FToolKitWindowHeight*0.5f)){
            //太靠上
            newY =  (self.limitRect.origin.y + FToolKitWindowHeight*0.5f);
        }
        if(currentCenter.y > (CGRectGetMaxY(self.limitRect)- FToolKitWindowHeight*0.5f)){
            //太靠下
            newY =  (CGRectGetMaxY(self.limitRect) - FToolKitWindowHeight*0.5f);
        }
        
        //处理是在左侧还是在右侧
        if(currentCenter.x <= CGRectGetMidX(self.limitRect)){//在区域的左侧
            if(dyT <= dyB && dxL > dyT && self.adsorptionTop){//顶部
                newY = (self.limitRect.origin.y + FToolKitWindowHeight*0.5f);
            }else if(dyT > dyB && dxL > dyB && self.adsorptionBottom){//底部
                newY =  (CGRectGetMaxY(self.limitRect) - FToolKitWindowHeight*0.5f);
            }else{
                newX = (self.limitRect.origin.x + FToolKitWindowWidth*0.5f);
            }
            
        }else{//在区域右侧
            if(dyT <= dyB && dxR > dyT && self.adsorptionTop){//顶部
                newY =  (self.limitRect.origin.y + FToolKitWindowHeight*0.5f);
            }else if(dyT > dyB && dxR > dyB && self.adsorptionBottom){//底部
                newY =  (CGRectGetMaxY(self.limitRect) - FToolKitWindowHeight*0.5f);
            }else{
                newX = (CGRectGetMaxX(self.limitRect) - FToolKitWindowWidth*0.5f);
            }
        }
        
        endPoint = CGPointMake(newX, newY);
        [UIView animateWithDuration:0.2 animations:^{
            self.center = endPoint;
        }];
    }
}

- (void)show {
    [self makeKeyAndVisible];
}

- (void)remove {
    [self resignKeyWindow];
}

@end
