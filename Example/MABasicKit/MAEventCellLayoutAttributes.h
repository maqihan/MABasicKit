//
//  MAEventCellLayoutAttributes.h
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/12/6.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MAEventCellLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic) CGFloat visibleHeight;  // height of the visible portion of the cell
@property (nonatomic) NSUInteger numberOfOtherCoveredAttributes;    // number of events which share a time section with this attribute

@end

NS_ASSUME_NONNULL_END
