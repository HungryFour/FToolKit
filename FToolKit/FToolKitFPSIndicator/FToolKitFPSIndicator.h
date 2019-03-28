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

@interface FToolKitFPSView : UIView

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) UIColor *textColor;

@end

@interface FToolKitFPSIndicator : NSObject

#pragma mark - Attribute

@property(nonatomic,assign) FToolKitFPSIndicatorPosition fpsLabelPosition;


#pragma mark - Initializer

+ (FToolKitFPSIndicator *)sharedIndicator;


#pragma mark - Access Methods

- (void)show;


- (void)hide;


- (BOOL)isShowingFps;

@end
