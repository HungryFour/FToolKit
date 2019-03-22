//
//  FToolKitAlignKit.m
//  FBRetainCycleDetector
//
//  Created by 武建明 on 2019/3/18.
//

#import "FToolKitAlignKit.h"
#import "FToolKitDefine.h"

static CGFloat const kViewCheckSize = 44;

@interface FToolKitAlignKit()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *horizontalLine;//水平线
@property (nonatomic, strong) UIView *verticalLine;//垂直线
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UILabel *bottomLabel;

@end


@implementation FToolKitAlignKit

+ (FToolKitAlignKit *)shareInstance {
    static dispatch_once_t once;
    static FToolKitAlignKit *instance;
    dispatch_once(&once, ^{
        instance = [[FToolKitAlignKit alloc] init];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, FToolKitScreenWidth, FToolKitScreenHeight);
        self.backgroundColor = [UIColor clearColor];
        self.layer.zPosition = FLT_MAX;

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(FToolKitScreenWidth/2-kViewCheckSize/2, FToolKitScreenHeight/2-kViewCheckSize/2, kViewCheckSize, kViewCheckSize)];
        imageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        imageView.layer.cornerRadius = kViewCheckSize/2;
        imageView.layer.masksToBounds = YES;
        [self addSubview:imageView];
        _imageView = imageView;
        
        imageView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [imageView addGestureRecognizer:pan];
        
        _horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, imageView.center.y-0.25, self.frame.size.width, 0.5)];
        _horizontalLine.backgroundColor = [UIColor redColor];
        [self addSubview:_horizontalLine];
        
        _verticalLine = [[UIView alloc] initWithFrame:CGRectMake(imageView.center.x-0.25, 0, 0.5, self.frame.size.height)];
        _verticalLine.backgroundColor = [UIColor redColor];
        [self addSubview:_verticalLine];
        
        [self bringSubviewToFront:_imageView];
        
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.font = [UIFont systemFontOfSize:12];
        _leftLabel.textColor = [UIColor redColor];
        _leftLabel.text = [NSString stringWithFormat:@"%.1f",imageView.center.x];
        [self addSubview:_leftLabel];
        [_leftLabel sizeToFit];
        _leftLabel.frame = CGRectMake(imageView.center.x/2, imageView.center.y-_leftLabel.frame.size.height, _leftLabel.frame.size.width, _leftLabel.frame.size.height);
        
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = [UIFont systemFontOfSize:12];
        _topLabel.textColor = [UIColor redColor];
        _topLabel.text = [NSString stringWithFormat:@"%.1f",imageView.center.y];
        [self addSubview:_topLabel];
        [_topLabel sizeToFit];
        _topLabel.frame = CGRectMake(imageView.center.x-_topLabel.frame.size.width, imageView.center.y/2, _topLabel.frame.size.width, _topLabel.frame.size.height);
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont systemFontOfSize:12];
        _rightLabel.textColor = [UIColor redColor];
        _rightLabel.text = [NSString stringWithFormat:@"%.1f",self.frame.size.width-imageView.center.x];
        [self addSubview:_rightLabel];
        [_rightLabel sizeToFit];
        _rightLabel.frame = CGRectMake(imageView.center.x+(self.frame.size.width-imageView.center.x)/2, imageView.center.y-_rightLabel.frame.size.height, _rightLabel.frame.size.width, _rightLabel.frame.size.height);
        
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textColor = [UIColor redColor];
        _bottomLabel.text = [NSString stringWithFormat:@"%.1f",self.frame.size.height - imageView.center.y];
        [self addSubview:_bottomLabel];
        [_bottomLabel sizeToFit];
        _bottomLabel.frame = CGRectMake(imageView.center.x-_bottomLabel.frame.size.width, imageView.center.y+(self.frame.size.height - imageView.center.y)/2, _bottomLabel.frame.size.width, _bottomLabel.frame.size.height);
    }
    return self;
}


- (void)pan:(UIPanGestureRecognizer *)sender{
    //1、获得拖动位移
    CGPoint offsetPoint = [sender translationInView:sender.view];
    //2、清空拖动位移
    [sender setTranslation:CGPointZero inView:sender.view];
    //3、重新设置控件位置
    UIView *panView = sender.view;
    CGFloat newX = panView.center.x+offsetPoint.x;
    CGFloat newY = panView.center.y+offsetPoint.y;
    
    CGPoint centerPoint = CGPointMake(newX, newY);
    [self setImageViewCenterPoint:centerPoint];
    if(sender.state == UIGestureRecognizerStateEnded) {
        // 如果拖动结束后,在删除区域,则进入毁灭程序
        if (CGRectContainsPoint(FToolKitDeletedRect, self.imageView.center)) {
            // 如果拖动结束后,隐藏
            [self remove];
            return;
        }
    }
    
}

- (void)setImageViewCenterPoint:(CGPoint)center {
    self.imageView.center = center;
    _horizontalLine.frame = CGRectMake(0, _imageView.center.y-0.25, self.frame.size.width, 0.5);
    _verticalLine.frame = CGRectMake(_imageView.center.x-0.25, 0, 0.5, self.frame.size.height);
    
    _leftLabel.text = [NSString stringWithFormat:@"%.1f",_imageView.center.x];
    [_leftLabel sizeToFit];
    _leftLabel.frame = CGRectMake(_imageView.center.x/2, _imageView.center.y-_leftLabel.frame.size.height, _leftLabel.frame.size.width, _leftLabel.frame.size.height);
    
    _topLabel.text = [NSString stringWithFormat:@"%.1f",_imageView.center.y];
    [_topLabel sizeToFit];
    _topLabel.frame = CGRectMake(_imageView.center.x-_topLabel.frame.size.width, _imageView.center.y/2, _topLabel.frame.size.width, _topLabel.frame.size.height);
    
    _rightLabel.text = [NSString stringWithFormat:@"%.1f",self.frame.size.width-_imageView.center.x];
    [_rightLabel sizeToFit];
    _rightLabel.frame = CGRectMake(_imageView.center.x+(self.frame.size.width-_imageView.center.x)/2, _imageView.center.y-_rightLabel.frame.size.height, _rightLabel.frame.size.width, _rightLabel.frame.size.height);
    
    _bottomLabel.text = [NSString stringWithFormat:@"%.1f",self.frame.size.height - _imageView.center.y];
    [_bottomLabel sizeToFit];
    _bottomLabel.frame = CGRectMake(_imageView.center.x-_bottomLabel.frame.size.width, _imageView.center.y+(self.frame.size.height - _imageView.center.y)/2, _bottomLabel.frame.size.width, _bottomLabel.frame.size.height);
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if(CGRectContainsPoint(_imageView.frame, point)){
        return YES;
    }
    return NO;
}

- (void)show {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    for (UIView *view in keyWindow.subviews) {
        if ([view isKindOfClass:[FToolKitAlignKit class]]) {
            return;
        }
    }
    [self setImageViewCenterPoint:keyWindow.center];
    [keyWindow addSubview:self];
}

- (void)remove {
    [self removeFromSuperview];
}

- (BOOL)isShowing {
    if (self.superview != nil) {
        return YES;
    }
    return NO;
}

@end
