//
//  MATimedEventsViewLayout.m
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/12/6.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MATimedEventsViewLayout.h"
#import "MAEventCellLayoutAttributes.h"
#import "MATimedEventsViewLayoutInvalidationContext.h"
#import "MGCAlignedGeometry.h"

static NSString* const EventCellsKey = @"EventCellsKey";

@interface MATimedEventsViewLayout()

@property (nonatomic) NSMutableDictionary *layoutInfo;

#ifdef BUG_FIX
@property (nonatomic) CGRect visibleBounds;
@property (nonatomic) BOOL shouldInvalidate;
#endif

@end

@implementation MATimedEventsViewLayout

- (instancetype)init {
    if (self = [super init]) {
        _minimumVisibleHeight = 15.;
        _ignoreNextInvalidation = NO;
    }
    return self;
}

- (NSMutableDictionary*)layoutInfo
{
    if (!_layoutInfo) {
        NSInteger numSections = self.collectionView.numberOfSections;
        _layoutInfo = [NSMutableDictionary dictionaryWithCapacity:numSections];
    }
    return _layoutInfo;
}

- (NSArray*)layoutAttributesForEventCellsInSection:(NSUInteger)section
{
    NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
    NSMutableArray *layoutAttribs = [NSMutableArray arrayWithCapacity:numItems];

    for (NSInteger item = 0; item < numItems; item++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];

        CGRect rect = [self.delegate collectionView:self.collectionView layout:self rectForEventAtIndexPath:indexPath];
        if (!CGRectIsNull(rect)) {
            MAEventCellLayoutAttributes *cellAttribs = [MAEventCellLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

            rect.origin.x = self.collectionView.frame.size.width * indexPath.section;
            rect.size.width = self.collectionView.frame.size.width;
            rect.size.height = fmax(self.minimumVisibleHeight, rect.size.height);

            cellAttribs.frame = MGCAlignedRect(CGRectInset(rect , 0, 1));
            cellAttribs.visibleHeight = cellAttribs.frame.size.height;
            cellAttribs.zIndex = 1;  // should appear above dimming views

            [layoutAttribs addObject:cellAttribs];
        }
    }

    return [self adjustLayoutForOverlappingCells:layoutAttribs inSection:section];
}

- (NSDictionary*)layoutAttributesForSection:(NSUInteger)section
{
    NSMutableDictionary *sectionAttribs = [self.layoutInfo objectForKey:@(section)];
    
    if (!sectionAttribs) {
        sectionAttribs = [NSMutableDictionary dictionary];
    }
    
    if (![sectionAttribs objectForKey:EventCellsKey]) {
        NSArray *cellsAttribs = [self layoutAttributesForEventCellsInSection:section];
        [sectionAttribs setObject:cellsAttribs forKey:EventCellsKey];
    }
    
    [self.layoutInfo setObject:sectionAttribs forKey:@(section)];
   
    return sectionAttribs;
}

- (NSArray*)adjustLayoutForOverlappingCells:(NSArray*)attributes inSection:(NSUInteger)section
{
    // sort layout attributes by frame y-position
    NSArray *adjustedAttributes = [attributes sortedArrayUsingComparator:^NSComparisonResult(MAEventCellLayoutAttributes *att1, MAEventCellLayoutAttributes *att2) {
        if (att1.frame.origin.y > att2.frame.origin.y) {
            return NSOrderedDescending;
        }
        else if (att1.frame.origin.y < att2.frame.origin.y) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];

    // Create clusters - groups of rectangles which don't have common parts with other groups
    NSMutableArray *uninspectedAttributes = [adjustedAttributes mutableCopy];
    NSMutableArray<NSMutableArray<MAEventCellLayoutAttributes *> *> *clusters = [NSMutableArray new];
    
    while (uninspectedAttributes.count > 0) {
        MAEventCellLayoutAttributes *attrib = [uninspectedAttributes firstObject];
        NSMutableArray<MAEventCellLayoutAttributes *> *destinationCluster;
        
        for (NSMutableArray<MAEventCellLayoutAttributes *> *cluster in clusters) {
            for (MAEventCellLayoutAttributes *clusteredAttrib in cluster) {
                if (CGRectIntersectsRect(clusteredAttrib.frame, attrib.frame)) {
                    destinationCluster = cluster;
                    break;
                }
            }
        }
        
        if (destinationCluster) {
            [destinationCluster addObject:attrib];
        } else {
            NSMutableArray<MAEventCellLayoutAttributes *> *cluster = [NSMutableArray new];
            [cluster addObject:attrib];
            [clusters addObject:cluster];
        }
        
        [uninspectedAttributes removeObject:attrib];
    }
    
    // Distribute rectangles evenly in clusters
    for (NSMutableArray<MAEventCellLayoutAttributes *> *cluster in clusters) {
        [self expandCellsToMaxWidthInCluster:cluster];
    }
    
    // Gather all the attributes and return them
    NSMutableArray *attributesArray = [NSMutableArray new];
    for (NSMutableArray<MAEventCellLayoutAttributes *> *cluster in clusters) {
        [attributesArray addObjectsFromArray:cluster];
    }
    
    return attributesArray;
}

- (void)expandCellsToMaxWidthInCluster:(NSMutableArray<MAEventCellLayoutAttributes *> *)cluster
{
    // Expand the attributes to maximum possible width
    NSMutableArray<NSMutableArray<MAEventCellLayoutAttributes *> *> *columns = [NSMutableArray new];
    [columns addObject:[NSMutableArray new]];
    for (MAEventCellLayoutAttributes *attribs in cluster) {
        BOOL isPlaced = NO;
        for (NSMutableArray<MAEventCellLayoutAttributes *> *column in columns) {
            if (column.count == 0) {
                [column addObject:attribs];
                isPlaced = YES;
            } else if (!CGRectIntersectsRect(attribs.frame, [column lastObject].frame)) {
                [column addObject:attribs];
                isPlaced = YES;
                break;
            }
        }
        if (!isPlaced) {
            NSMutableArray<MAEventCellLayoutAttributes *> *column = [NSMutableArray new];
            [column addObject:attribs];
            [columns addObject:column];
        }
    }

    // Calculate left and right position for all the attributes, get the maxRowCount by looking in all columns
    NSInteger maxRowCount = 0;
    for (NSMutableArray<MAEventCellLayoutAttributes *> *column in columns) {
        maxRowCount = fmax(maxRowCount, column.count);
    }

    CGFloat totalWidth = self.collectionView.frame.size.width - 2.f;

    for (NSInteger i = 0; i < maxRowCount; i++) {
        // Set the x position of the rect
        NSInteger j = 0;
        for (NSMutableArray<MAEventCellLayoutAttributes *> *column in columns) {
            CGFloat colWidth = totalWidth / columns.count;
            if (column.count >= i + 1) {
                MAEventCellLayoutAttributes *attribs = [column objectAtIndex:i];
                attribs.frame = MGCAlignedRectMake(attribs.frame.origin.x + j * colWidth,
                                                   attribs.frame.origin.y,
                                                   colWidth,
                                                   attribs.frame.size.height);
            }
            j++;
        }
    }
}

#pragma mark - UICollectionViewLayout

+ (Class)layoutAttributesClass
{
    return [MAEventCellLayoutAttributes class];
}

+ (Class)invalidationContextClass
{
    return [MATimedEventsViewLayoutInvalidationContext class];
}

- (MAEventCellLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath
{
    //NSLog(@"layoutAttributesForItemAtIndexPath %@", indexPath);
    
    NSArray *attribs = [[self layoutAttributesForSection:indexPath.section] objectForKey:EventCellsKey];
    return [attribs objectAtIndex:indexPath.item];
}

- (void)prepareForCollectionViewUpdates:(NSArray*)updateItems
{
    //NSLog(@"prepare Collection updates");
    
    [super prepareForCollectionViewUpdates:updateItems];
}

- (void)invalidateLayoutWithContext:(MATimedEventsViewLayoutInvalidationContext *)context
{
    //NSLog(@"invalidateLayoutWithContext");
    
    [super invalidateLayoutWithContext:context];
    
    if (self.ignoreNextInvalidation) {
        self.ignoreNextInvalidation = NO;
        return;
        
    }
    
    if (context.invalidateEverything || context.invalidatedSections == nil) {
        self.layoutInfo = nil;
    }
    else {
        [context.invalidatedSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            if (context.invalidateEventCells) {
                [[self.layoutInfo objectForKey:@(idx)]removeObjectForKey:EventCellsKey];
            }
        }];
    }
}

- (void)invalidateLayout
{
    //NSLog(@"invalidateLayout");
    
    [super invalidateLayout];
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.frame.size.width, 1000);
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    
#ifdef BUG_FIX
    self.shouldInvalidate = self.visibleBounds.origin.y != rect.origin.y || self.visibleBounds.size.height != rect.size.height;
    //self.shouldInvalidate = !CGRectEqualToRect(self.visibleBounds, rect);
    self.visibleBounds = rect;
#endif
    
    NSMutableArray *allAttribs = [NSMutableArray array];
    
    // determine first and last day intersecting rect
    NSUInteger maxSection = self.collectionView.numberOfSections;
    NSUInteger first = MAX(0, floorf(rect.origin.x  / self.collectionView.frame.size.width));
    NSUInteger last =  MIN(MAX(first, ceilf(CGRectGetMaxX(rect) / self.collectionView.frame.size.width)), maxSection);
    
    for (NSInteger day = first; day < last; day++) {
        NSDictionary *layoutDic = [self layoutAttributesForSection:day];
        NSArray *attribs = [layoutDic objectForKey:EventCellsKey];
        
        for (UICollectionViewLayoutAttributes *a in attribs) {
            if (CGRectIntersectsRect(rect, a.frame)) {
#ifdef BUG_FIX
                CGRect frame = a.frame;
                frame.size.height = fminf(frame.size.height, CGRectGetMaxY(rect) - frame.origin.y);
                a.frame = frame;
#endif
                [allAttribs addObject:a];
            }
        }
    }

    return allAttribs;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    //NSLog(@"shouldInvalidateLayoutForBoundsChange %@", NSStringFromCGRect(newBounds));
    
    CGRect oldBounds = self.collectionView.bounds;
    
    return
#ifdef BUG_FIX
        self.shouldInvalidate ||
#endif
        oldBounds.size.width != newBounds.size.width;
}

// we keep this for iOS 8 compatibility. As of iOS 9, this is replaced by collectionView:targetContentOffsetForProposedContentOffset:
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    id<UICollectionViewDelegate> delegate = (id<UICollectionViewDelegate>)self.collectionView.delegate;
    return [delegate collectionView:self.collectionView targetContentOffsetForProposedContentOffset:proposedContentOffset];
}



@end
