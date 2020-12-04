//
//  MATimeRowsView.h
//  MABasicKit_Example
//
//  Created by maqihan on 2020/12/4.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, MATimeMark) {
    MATimeMarkDefault = 0,
    MATimeMarkCurrent = 1,
    MATimeMarkFloating = 2,
};

@interface MATimeRowsView : UIView

@property (assign , nonatomic) CGFloat hourSlotHeight;  

@end

NS_ASSUME_NONNULL_END
