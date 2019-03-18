//
//  FColorPickView.h
//  FHHFPSIndicator
//
//  Created by 武建明 on 2019/3/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FColorPickView : UIWindow

+ (FColorPickView *)shareInstance;

- (void)show;
@end

NS_ASSUME_NONNULL_END
