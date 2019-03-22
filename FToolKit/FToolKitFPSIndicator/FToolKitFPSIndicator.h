//
//  FToolKitFPSIndicator.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIWindow+FToolKitFHH.h"


typedef enum {
    FToolKitFPSIndicatorPositionTopLeft,        ///<left-center on statusBar
    FToolKitFPSIndicatorPositionTopRight,       ///<right-center on statusBar
    FToolKitFPSIndicatorPositionBottomCenter,   ///<under the statusBar
    FToolKitFPSIndicatorPositionCenter          ///center in the Screen
} FToolKitFPSIndicatorPosition;


@interface FToolKitFPSIndicator : NSObject

#pragma mark - Attribute

@property(nonatomic,assign) FToolKitFPSIndicatorPosition fpsLabelPosition;


#pragma mark - Initializer

+ (FToolKitFPSIndicator *)sharedIndicator;


#pragma mark - Access Methods

- (void)setFpsLabelColor:(UIColor *)color;


- (void)show;


- (void)hide;


- (BOOL)isShowingFps;

@end
