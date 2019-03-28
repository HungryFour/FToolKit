//
//  FToolKitFPSIndicator.m
//  FToolKitFPSIndicator

#import "FToolKitFPSIndicator.h"
#import "FToolKitDefine.h"

#define SIZE_FPSView CGSizeMake(60, 20)
#define FONT_SIZE_FPSView (12)
#define PADDING_TOP_FPSView (20)

#if TARGET_IPHONE_SIMULATOR // SIMULATOR
#define PADDING_LEFT_FPSView (47)
#define PADDING_RIGHT_FPSView (9)
#define PADDING_CENTER_FPSView (31)
#elif TARGET_OS_IPHONE  // iPhone
#define PADDING_LEFT_FPSView (36)
#define PADDING_RIGHT_FPSView (-3)
#define PADDING_CENTER_FPSView (3)
#endif

@interface FToolKitFPSView ()

@property (nonatomic, strong) UILabel *fpsLabel;

@end

@implementation FToolKitFPSView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [self addSubview:self.fpsLabel];
    }
    return self;
}

- (UILabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SIZE_FPSView.width, SIZE_FPSView.height)];
        _fpsLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE_FPSView];
        _fpsLabel.textColor = [UIColor greenColor];
        _fpsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _fpsLabel;
}

- (void)setText:(NSString *)text {
    _text = text;
    _fpsLabel.text = text;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _fpsLabel.textColor = _textColor;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if(CGRectContainsPoint(CGRectMake(self.fpsLabel.frame.origin.x-20, self.fpsLabel.frame.origin.y-20, self.fpsLabel.frame.size.width+40, self.fpsLabel.frame.size.height+40), point)){
        return YES;
    }
    return NO;
}

@end

@interface FToolKitFPSIndicator ()

{
    CADisplayLink *_displayLink;
    NSTimeInterval _lastTime;
    NSUInteger _count;
}

@property (nonatomic, strong) FToolKitFPSView *fpsView;

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

- (FToolKitFPSView *)fpsView {
    if (!_fpsView) {
        _fpsView = [[FToolKitFPSView alloc] init];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        [_fpsView addGestureRecognizer:pan];
    }
    return _fpsView;
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
    self.fpsView.center = centerPoint;
    if(sender.state == UIGestureRecognizerStateEnded) {
        // 如果拖动结束后,在删除区域,则进入毁灭程序
        if (CGRectContainsPoint(FToolKitDeletedRect, self.fpsView.center)) {
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
    [self.fpsView setText:text];
    if ((int)round(fps) > 50) {
        self.fpsView.textColor = [UIColor greenColor];
    } else {
        self.fpsView.textColor = [UIColor redColor];
    }
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    for (NSUInteger i = 0; i < keyWindow.subviews.count; ++i) {
        UIView *view = keyWindow.subviews[keyWindow.subviews.count - 1 - i];
        if ([view isKindOfClass:[FToolKitFPSView class]]) {
                return;
        }
    }
    self.fpsLabelPosition = FToolKitFPSIndicatorPositionBottomCenter;
    [_displayLink setPaused:NO];
    [keyWindow addSubview:self.fpsView];
}

- (void)hide {
    [_displayLink setPaused:YES];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    for (UIView *view in keyWindow.subviews) {
        if ([view isKindOfClass:[FToolKitFPSView class]]) {
            [view removeFromSuperview];
            return;
        }
    }
}

- (BOOL)isShowingFps {
    if (self.fpsView.superview != nil) {
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
            self.fpsView.frame = CGRectMake(PADDING_LEFT_FPSView, 2.5, SIZE_FPSView.width, SIZE_FPSView.height);
            break;
        case FToolKitFPSIndicatorPositionTopRight:
            self.fpsView.frame = CGRectMake((FToolKitScreenWidth - SIZE_FPSView.width) - (PADDING_RIGHT_FPSView) , 2.5, SIZE_FPSView.width, SIZE_FPSView.height);
            break;
        case FToolKitFPSIndicatorPositionBottomCenter:
            if (@available(iOS 11.0, *)) {
                if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom>0) {
                    self.fpsView.frame = CGRectMake((FToolKitScreenWidth - SIZE_FPSView.width) / 2, [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom, SIZE_FPSView.width, SIZE_FPSView.height);
                }else{
                    self.fpsView.frame = CGRectMake((FToolKitScreenWidth - SIZE_FPSView.width) / 2, PADDING_TOP_FPSView, SIZE_FPSView.width, SIZE_FPSView.height);
                }
            }else{
                self.fpsView.frame = CGRectMake((FToolKitScreenWidth - SIZE_FPSView.width) / 2, PADDING_TOP_FPSView, SIZE_FPSView.width, SIZE_FPSView.height);
            }
            break;
        case FToolKitFPSIndicatorPositionCenter:
            self.fpsView.frame = CGRectMake((FToolKitScreenWidth - SIZE_FPSView.width) / 2, (FToolKitScreenHeight - SIZE_FPSView.height) / 2, SIZE_FPSView.width, SIZE_FPSView.height);
            break;
        default:
            break;
    }
    self.fpsView.layer.cornerRadius = SIZE_FPSView.height/2;
    self.fpsView.layer.masksToBounds = YES;
}

@end
