//
//  FColorPickKit.m
//
//  Created by 武建明 on 2019/3/15.
//

#import "FColorPickKit.h"
#import "FToolKitDefine.h"
#import "UIImage+FToolKit.h"

@implementation FColorPickKitAmplificationWindow

#pragma mark - Lifecycle

- (void)dealloc {
    NSLog(@"FColorPickKitAmplificationWindow dealloc");
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.amplificationSize = 90;
        self.amplification = 3.0;
        
        self.frame = CGRectMake(0, 0, self.amplificationSize, self.amplificationSize);
        self.layer.delegate = self;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.layer.contentsScale = [[UIScreen mainScreen] scale];
    }
    return self;
}

#pragma mark - Override

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGContextTranslateCTM(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGContextScaleCTM(ctx, _amplification, _amplification);
    CGContextTranslateCTM(ctx, -1 * self.targetPoint.x, -1 * self.targetPoint.y);
    
    [self.targetWindow.layer renderInContext:ctx];
}

#pragma mark - Setter

- (void)setAmplification:(CGFloat)amplification {
    if (amplification > 0) {
        _amplification = amplification;
    }
}

- (void)setTargetWindow:(UIView *)targetWindow {
    _targetWindow = targetWindow;
    [self setTargetPoint:self.targetPoint];
    
}

- (void)setAmplificationSize:(CGFloat)amplificationSize {
    _amplificationSize = amplificationSize;
    self.frame = CGRectMake(0, 0, _amplificationSize, _amplificationSize);
    self.layer.cornerRadius = self.amplificationSize/2;
    self.layer.masksToBounds = YES;
}

- (void)setTargetPoint:(CGPoint)targetPoint {
    _targetPoint = targetPoint;
    if (self.targetWindow) {
        self.center = CGPointMake(targetPoint.x, targetPoint.y);
        [self.layer setNeedsDisplay];
    }
}

@end


@interface FColorPickKit ()

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *colorLabel;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic) CGRect deletedRect;

@property (nonatomic, strong) FColorPickKitAmplificationWindow *amplificationWindow;

@end

static CGFloat const FToolKitColorPickKitSize = 125;

static CGFloat const kAmplificationSize = 125;

@implementation FColorPickKit

+ (FColorPickKit *)shareInstance{
    static dispatch_once_t once;
    static FColorPickKit *instance;
    dispatch_once(&once, ^{
        instance = [[FColorPickKit alloc] initWithFrame:CGRectMake(0, 0, FToolKitColorPickKitSize, FToolKitColorPickKitSize)];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 11.f;
        [self addSubview:self.iconImageView];
        [self addSubview:self.colorLabel];
        self.deletedRect = CGRectMake(0, FToolKitScreenHeight-FToolKitColorPickKitSize, FToolKitScreenWidth, FToolKitColorPickKitSize);
        self.hidden = YES;
        [self addGesture];
    }
    return self;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage fToolkit_imageNamed:@"magnifying"]];
        _iconImageView.frame = CGRectMake(-2, -2, 156, 156);
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.userInteractionEnabled = YES;
        _iconImageView.backgroundColor = [UIColor clearColor];
    }
    return _iconImageView;
}

- (FColorPickKitAmplificationWindow *)amplificationWindow {
    if (!_amplificationWindow) {
        _amplificationWindow = [[FColorPickKitAmplificationWindow alloc] init];
        _amplificationWindow.targetWindow = [[UIApplication sharedApplication].delegate window];
        _amplificationWindow.amplificationSize = kAmplificationSize; //设置宽度
        _amplificationWindow.amplification = 4.0;
    }
    return _amplificationWindow;
}

- (UILabel *)colorLabel {
    if (!_colorLabel) {
        _colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, FToolKitColorPickKitSize, 20)];
        _colorLabel.backgroundColor = [UIColor clearColor];
        _colorLabel.textColor = [UIColor redColor];
        _colorLabel.textAlignment = NSTextAlignmentCenter;
        _colorLabel.numberOfLines = 1;
        _colorLabel.font = [UIFont systemFontOfSize:12];
    }
    return _colorLabel;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if(CGRectContainsPoint(_iconImageView.frame, point)){
        return YES;
    }
    return NO;
}

//不能让该View成为keyWindow，每一次它要成为keyWindow的时候，都要将appDelegate的window指为keyWindow
- (void)becomeKeyWindow{
    UIWindow *appWindow = [[UIApplication sharedApplication].delegate window];
    [appWindow makeKeyWindow];
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
        _lastPoint = CGPointMake(panPoint.x, panPoint.y);
        self.amplificationWindow.hidden = NO;
        self.colorLabel.hidden = NO;
    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //拖动过程中
        self.center = CGPointMake(self.center.x + panPoint.x-_lastPoint.x, self.center.y+panPoint.y-_lastPoint.y);
        _lastPoint = CGPointMake(panPoint.x, panPoint.y);
        CGPoint colorPoint = CGPointMake(self.center.x, self.center.y);
        NSString *hexColor = [self getColorWithCenterPoint:colorPoint];
        self.colorLabel.text = hexColor;
        self.amplificationWindow.targetPoint = self.center;
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        // 如果拖动结束后,在删除区域,则进入毁灭程序
        if (CGRectContainsPoint(self.deletedRect, self.center)) {
            // 如果拖动结束后,隐藏
            [self remove];
            return;
        }
        self.amplificationWindow.hidden = YES;
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
    self.amplificationWindow.hidden = YES;
    self.colorLabel.hidden = YES;
    self.hidden = YES;
}


@end
