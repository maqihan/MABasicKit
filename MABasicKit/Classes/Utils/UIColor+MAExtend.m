//
//  UIColor+MAExtend.m
//  Pods
//
//  Created by 马启晗 on 2020/9/13.
//

#import "UIColor+MAExtend.h"


@implementation UIColor (MAExtend)

+ (UIColor *)colorWithHexString:(NSString *) hexString
{
    if (hexString.length == 0 || hexString.length > 6) {
        NSLog(@"------------->颜色值需要输入16进制字符串");
        return nil;
    }
    
    return  [self colorWithHexString:hexString alpha:1.0f];
}


+ (UIColor *)colorWithHexString:(NSString *) hexString alpha:(CGFloat)alphaValue
{
    if (hexString.length == 0 || hexString.length > 6) {
        NSLog(@"------------->颜色值需要输入16进制字符串");
        return nil;
    }
    
    unsigned int redInt_, greenInt_, blueInt_;
    NSRange rangeNSRange_;
    rangeNSRange_.length = 2;  // 范围长度为2
    
    // 取红色的值
    rangeNSRange_.location = 0;
    [[NSScanner scannerWithString:[hexString substringWithRange:rangeNSRange_]]
     scanHexInt:&redInt_];
    
    // 取绿色的值
    rangeNSRange_.location = 2;
    [[NSScanner scannerWithString:[hexString substringWithRange:rangeNSRange_]]
     scanHexInt:&greenInt_];
    
    // 取蓝色的值
    rangeNSRange_.location = 4;
    [[NSScanner scannerWithString:[hexString substringWithRange:rangeNSRange_]]
     scanHexInt:&blueInt_];
    
    return [UIColor colorWithRed:(float)(redInt_/255.0f)
                           green:(float)(greenInt_/255.0f)
                            blue:(float)(blueInt_/255.0f)
                           alpha:alphaValue];
}


@end
