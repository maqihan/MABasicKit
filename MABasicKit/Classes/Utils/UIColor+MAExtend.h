//
//  UIColor+MAExtend.h
//  Pods
//
//  Created by 马启晗 on 2020/9/13.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (MAExtend)
+ (UIColor *)colorWithHexString:(NSString *) hexString;

+ (UIColor *)colorWithHexString:(NSString *) hexString alpha:(CGFloat)alphaValue;

@end

NS_ASSUME_NONNULL_END
