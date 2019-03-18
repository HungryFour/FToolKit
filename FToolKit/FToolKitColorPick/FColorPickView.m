//
//  FColorPickView.m
//  FHHFPSIndicator
//
//  Created by 武建明 on 2019/3/15.
//

#import "FColorPickView.h"
#import "FToolKitDefine.h"
#import "UIImage+FToolKit.h"

static CGFloat const FToolKitColorPickViewSize = 88;

@interface FColorPickView ()

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *colorLabel;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation FColorPickView

+ (FColorPickView *)shareInstance{
    static dispatch_once_t once;
    static FColorPickView *instance;
    dispatch_once(&once, ^{
        instance = [[FColorPickView alloc] initWithFrame:CGRectMake(0, 0, FToolKitColorPickViewSize, FToolKitColorPickViewSize)];
        instance.backgroundColor = [UIColor clearColor];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGesture];
        self.windowLevel = UIWindowLevelStatusBar + 11.f;
        [self addSubview:self.iconImageView];
        [self addSubview:self.colorLabel];
        [self addSubview:self.closeButton];
        [self makeKeyAndVisible];
        self.hidden = YES;
    }
    return self;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage fToolkit_imageNamed:@"pen_alt_stroke"]];
        _iconImageView.frame = CGRectMake(FToolKitColorPickViewSize/2, FToolKitColorPickViewSize/2, FToolKitColorPickViewSize/2, FToolKitColorPickViewSize/2);
        _iconImageView.userInteractionEnabled = YES;
        _iconImageView.backgroundColor = [UIColor clearColor];
    }
    return _iconImageView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(0, FToolKitColorPickViewSize-30, 30, 30);
        [_closeButton setTitle:@"✘" forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:30];
        [_closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)colorLabel {
    if (!_colorLabel) {
        _colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, FToolKitColorPickViewSize, FToolKitColorPickViewSize/2)];
        _colorLabel.backgroundColor = [UIColor clearColor];
        _colorLabel.textColor = [UIColor redColor];
        _colorLabel.textAlignment = NSTextAlignmentLeft;
        _colorLabel.numberOfLines = 1;
        _colorLabel.font = [UIFont systemFontOfSize:12];
    }
    return _colorLabel;
}

-(void)addGesture{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
    pan.delaysTouchesBegan = YES;
    [self.iconImageView addGestureRecognizer:pan];
}

- (void)locationChange:(UIPanGestureRecognizer *)gestureRecognizer{
    //1、获得拖动位移
    CGPoint panPoint = [gestureRecognizer locationInView:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //拖动开始
        self.colorLabel.hidden = NO;
        _lastPoint = CGPointMake(panPoint.x, panPoint.y);
    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //拖动过程中
        self.center = CGPointMake(self.center.x + panPoint.x-_lastPoint.x, self.center.y+panPoint.y-_lastPoint.y);
        _lastPoint = CGPointMake(panPoint.x, panPoint.y);
        CGPoint colorPoint = CGPointMake(self.center.x, self.center.y);
        NSString *hexColor = [self getColorWithCenterPoint:colorPoint];
        self.colorLabel.text = hexColor;
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // 如果拖动结束后,隐藏
        self.colorLabel.hidden = YES;
    }
}

- (NSString *)getColorWithCenterPoint:(CGPoint)centerPoint{
    UIView *delegateWindow = [[UIApplication sharedApplication].delegate window];
    return [self getColorOfPoint:centerPoint InView:delegateWindow];
}

- (NSString *)getColorOfPoint:(CGPoint)point InView:(UIView*)view{
    unsigned char pixel[4] = {0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel,
                                                 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [view.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    NSString *hexColor = [NSString stringWithFormat:@"#%02x%02x%02x",pixel[0],pixel[1],pixel[2]];
    return hexColor;
}

- (void)show {
    self.center = CGPointMake(FToolKitScreenWidth/2, FToolKitScreenHeight/2);
    self.hidden = NO;
}

- (void)remove {
    self.hidden = YES;
}


@end
