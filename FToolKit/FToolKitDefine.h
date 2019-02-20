//
//  FToolKitDefine.h
//  FToolKitDemo
//
//  Created by 武建明 on 2019/2/20.
//  Copyright © 2019 武建明. All rights reserved.
//

#ifndef FToolKitDefine_h
#define FToolKitDefine_h

#import "FToolKitUtil.h"

#define FToolKitScreenWidth [UIScreen mainScreen].bounds.size.width
#define FToolKitScreenHeight [UIScreen mainScreen].bounds.size.height

#define IS_IPHONE_X_Series [FToolKitUtil isIPhoneXSeries]
#define IPHONE_NAVIGATIONBAR_HEIGHT  (IS_IPHONE_X_Series ? 88 : 64)
#define IPHONE_STATUSBAR_HEIGHT      (IS_IPHONE_X_Series ? 44 : 20)
#define IPHONE_SAFEBOTTOMAREA_HEIGHT (IS_IPHONE_X_Series ? 34 : 0)
#define IPHONE_TOPSENSOR_HEIGHT      (IS_IPHONE_X_Series ? 32 : 0)

#endif /* FToolKitDefine_h */
