//
//  MATimedEventsViewLayout.h
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/12/6.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MATimedEventsViewLayoutDelegate;

@interface MATimedEventsViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<MATimedEventsViewLayoutDelegate> delegate;

@property (nonatomic) CGFloat minimumVisibleHeight;
@property (nonatomic) BOOL ignoreNextInvalidation;
@end

@protocol MATimedEventsViewLayoutDelegate <UICollectionViewDelegate>

// x and width of returned rect are ignored
- (CGRect)collectionView:(UICollectionView*)collectionView layout:(MATimedEventsViewLayout*)layout rectForEventAtIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
