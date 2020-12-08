//
//  MATimedEventsViewLayoutInvalidationContext.h
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/12/6.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MATimedEventsViewLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

@property (nonatomic) BOOL invalidateDimmingViews;  // set to true if layout attributes of dimming views must be recomputed
@property (nonatomic) BOOL invalidateEventCells;  // set to true if layout attributes of event cells must be recomputed
@property (nonatomic) NSMutableIndexSet *invalidatedSections;   // sections whose layout attributes (dimming views or event cells) must be recomputed - if nil, recompute everything

@end

NS_ASSUME_NONNULL_END
