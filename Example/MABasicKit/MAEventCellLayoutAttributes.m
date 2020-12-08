//
//  MAEventCellLayoutAttributes.m
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/12/6.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MAEventCellLayoutAttributes.h"

@implementation MAEventCellLayoutAttributes

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object])
        return NO;
    
    MAEventCellLayoutAttributes* attribs = (MAEventCellLayoutAttributes*)object;
    return (attribs.visibleHeight == self.visibleHeight);
}

- (id)copyWithZone:(NSZone*)zone
{
    MAEventCellLayoutAttributes *attribs = [super copyWithZone:zone];
    attribs.visibleHeight = self.visibleHeight;
    return attribs;
}

@end
