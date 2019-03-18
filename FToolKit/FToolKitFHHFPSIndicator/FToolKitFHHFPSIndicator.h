//
//  FToolKitFHHFPSIndicator.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIWindow+FToolKitFHH.h"


typedef enum {
    FToolKitFPSIndicatorPositionTopLeft,        ///<left-center on statusBar
    FToolKitFPSIndicatorPositionTopRight,       ///<right-center on statusBar
    FToolKitFPSIndicatorPositionBottomCenter    ///<under the statusBar
} FToolKitFPSIndicatorPosition;


@interface FToolKitFHHFPSIndicator : NSObject

#pragma mark - Attribute

@property(nonatomic,assign) FToolKitFPSIndicatorPosition fpsLabelPosition;


#pragma mark - Initializer

+ (FToolKitFHHFPSIndicator *)sharedIndicator;


#pragma mark - Access Methods

- (void)setFpsLabelColor:(UIColor *)color;


- (void)show;


- (void)hide;


- (BOOL)isShowingFps;

@end
