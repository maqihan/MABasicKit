//
//  MATimedEventsViewLayoutInvalidationContext.m
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/12/6.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MATimedEventsViewLayoutInvalidationContext.h"

@implementation MATimedEventsViewLayoutInvalidationContext
- (instancetype)init {
    if (self = [super init]) {
        self.invalidateDimmingViews = NO;
        self.invalidateEventCells = YES;
    }
    return self;
}

@end
