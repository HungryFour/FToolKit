//
//  UIImage+FToolKit.m
//  FBRetainCycleDetector
//
//  Created by 武建明 on 2019/3/15.
//

#import "UIImage+FToolKit.h"

@implementation UIImage (FToolKit)

+ (UIImage *)fToolkit_imageNamed:(NSString *)name{
    if(name){
        NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"FToolKit")];
        NSURL *url = [bundle URLForResource:@"FToolKit" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        
        NSString *imageName = nil;
        CGFloat scale = [UIScreen mainScreen].scale;
        if (ABS(scale-3) <= 0.001){
            imageName = [NSString stringWithFormat:@"%@@3x",name];
        }else if(ABS(scale-2) <= 0.001){
            imageName = [NSString stringWithFormat:@"%@@2x",name];
        }else{
            imageName = name;
        }
        UIImage *image = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:imageName ofType:@"png"]];
        if (!image) {
            image = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:name ofType:@"png"]];
            if (!image) {
                image = [UIImage imageNamed:name];
            }
        }
        return image;
    }
    return nil;
}


@end
