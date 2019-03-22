//
//  FToolKitFPSIndicator.m
//  FToolKitFPSIndicator

#import "FToolKitFPSIndicator.h"
#import "FToolKitDefine.h"

#define SIZE_fpsLabel CGSizeMake(60, 20)
#define FONT_SIZE_fpsLabel (12)
#define TAG_fpsLabel (110213)
#define PADDING_TOP_fpsLabel (1)

#if TARGET_IPHONE_SIMULATOR // SIMULATOR
#define PADDING_LEFT_fpsLabel (47)
#define PADDING_RIGHT_fpsLabel (9)
#define PADDING_CENTER_fpsLabel (31)
#elif TARGET_OS_IPHONE  // iPhone
#define PADDING_LEFT_fpsLabel (36)
#define PADDING_RIGHT_fpsLabel (-3)
#define PADDING_CENTER_fpsLabel (3)
#endif

@interface FToolKitFPSIndicator ()

{
    CADisplayLink *_displayLink;
    NSTimeInterval _lastTime;
    NSUInteger _count;
}

@property (nonatomic, strong) UILabel *fpsLabel;

@end

@implementation FToolKitFPSIndicator

+ (FToolKitFPSIndicator *)sharedIndicator {
    static dispatch_once_t onceToken;
    static FToolKitFPSIndicator *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[FToolKitFPSIndicator alloc] init];
    });
    return _instance;
}

- (id)init {
    if (self = [super init]) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_displayLinkTick:)];
        [_displayLink setPaused:YES];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        // create fpsLabel
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationDidBecomeActiveNotification)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillResignActiveNotification)
                                                     name: UIApplicationWillResignActiveNotification
                                                   object: nil];
    }
    return self;
}

- (UILabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [[UILabel alloc] init];
        _fpsLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE_fpsLabel];
        _fpsLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _fpsLabel.textColor = [UIColor greenColor];
        _fpsLabel.tag = TAG_fpsLabel;
        _fpsLabel.userInteractionEnabled = YES;
        _fpsLabel.textAlignment = NSTextAlignmentCenter;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        [_fpsLabel addGestureRecognizer:pan];
    }
    return _fpsLabel;
}

- (void)locationChange:(UIPanGestureRecognizer *)sender{
    //1、获得拖动位移
    CGPoint offsetPoint = [sender translationInView:sender.view];
    //2、清空拖动位移
    [sender setTranslation:CGPointZero inView:sender.view];
    //3、重新设置控件位置
    UIView *panView = sender.view;
    CGFloat newX = panView.center.x+offsetPoint.x;
    CGFloat newY = panView.center.y+offsetPoint.y;
    CGPoint centerPoint = CGPointMake(newX, newY);
    self.fpsLabel.center = centerPoint;
    if(sender.state == UIGestureRecognizerStateEnded) {
        // 如果拖动结束后,在删除区域,则进入毁灭程序
        if (CGRectContainsPoint(FToolKitDeletedRect, self.fpsLabel.center)) {
            // 如果拖动结束后,隐藏
            [self hide];
            return;
        }
    }
    
}

- (void)p_displayLinkTick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) {
        return;
    }
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    NSString *text = [NSString stringWithFormat:@"%d FPS",(int)round(fps)];
    [self.fpsLabel setText: text];
    
    if ((int)round(fps) > 56) {
        self.fpsLabel.textColor = [UIColor greenColor];
    } else {
        self.fpsLabel.textColor = [UIColor redColor];
    }
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    for (NSUInteger i = 0; i < keyWindow.subviews.count; ++i) {
        UIView *view = keyWindow.subviews[keyWindow.subviews.count - 1 - i];
        if ([view isKindOfClass:[UILabel class]] && view.tag == TAG_fpsLabel) {        
                return;
        }
    }
    self.fpsLabelPosition = FToolKitFPSIndicatorPositionBottomCenter;
    [_displayLink setPaused:NO];
    [keyWindow addSubview:self.fpsLabel];
}

- (void)hide {
    [_displayLink setPaused:YES];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    for (UIView *label in keyWindow.subviews) {
        if ([label isKindOfClass:[UILabel class]]&& label.tag == TAG_fpsLabel) {
            [label removeFromSuperview];
            return;
        }
    }
}

- (BOOL)isShowingFps {
    if (self.fpsLabel.superview != nil) {
        return YES;
    }
    return NO;
}

#pragma mark - notification
- (void)applicationDidBecomeActiveNotification {
    [_displayLink setPaused:NO];
}

- (void)applicationWillResignActiveNotification {
    [_displayLink setPaused:YES];
}

#pragma mark - setter
- (void)setFpsLabelPosition:(FToolKitFPSIndicatorPosition)fpsLabelPosition {
    _fpsLabelPosition = fpsLabelPosition;
    switch (_fpsLabelPosition) {
        case FToolKitFPSIndicatorPositionTopLeft:
            self.fpsLabel.frame = CGRectMake(PADDING_LEFT_fpsLabel, 2.5, SIZE_fpsLabel.width, SIZE_fpsLabel.height);
            break;
        case FToolKitFPSIndicatorPositionTopRight:
            self.fpsLabel.frame = CGRectMake((FToolKitScreenWidth - SIZE_fpsLabel.width) - (PADDING_RIGHT_fpsLabel) , 2.5, SIZE_fpsLabel.width, SIZE_fpsLabel.height);
            break;
        case FToolKitFPSIndicatorPositionBottomCenter:
            if (@available(iOS 11.0, *)) {
                self.fpsLabel.frame = CGRectMake((FToolKitScreenWidth - SIZE_fpsLabel.width) / 2, [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom+PADDING_TOP_fpsLabel, SIZE_fpsLabel.width, SIZE_fpsLabel.height);
            }else{
                self.fpsLabel.frame = CGRectMake((FToolKitScreenWidth - SIZE_fpsLabel.width) / 2, PADDING_TOP_fpsLabel, SIZE_fpsLabel.width, SIZE_fpsLabel.height);
            }
            break;
        case FToolKitFPSIndicatorPositionCenter:
            self.fpsLabel.frame = CGRectMake((FToolKitScreenWidth - SIZE_fpsLabel.width) / 2, (FToolKitScreenHeight - SIZE_fpsLabel.height) / 2, SIZE_fpsLabel.width, SIZE_fpsLabel.height);
            break;
        default:
            break;
    }
    self.fpsLabel.layer.cornerRadius = SIZE_fpsLabel.height/2;
    self.fpsLabel.layer.masksToBounds = YES;
}

- (void)setFpsLabelColor:(UIColor *)color {
    if (color == nil) {
        self.fpsLabel.textColor = [UIColor greenColor];
    } else {
        self.fpsLabel.textColor = color;
    }    
}

@end
