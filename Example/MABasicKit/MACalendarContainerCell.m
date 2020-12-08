//
//  MACalendarContainerCell.m
//  MABasicKit_Example
//
//  Created by maqihan on 2020/12/4.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MACalendarContainerCell.h"
#import "MATimeRowsView.h"
#import "MATimedEventsViewLayout.h"
#import "MAEventCell.h"

@interface MACalendarContainerCell()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,MATimedEventsViewLayoutDelegate>

@property (nonatomic, strong) UIScrollView *timeScrollView;
@property (nonatomic, strong) MATimeRowsView *timeRowsView;

@property (nonatomic, strong) MATimedEventsViewLayout *timedEventsViewLayout;
@property (nonatomic, strong) UICollectionView *timedEventsView;

@property (nonatomic, strong) UIView *interactiveEventView;

@end

@implementation MACalendarContainerCell

static NSString* const event_cell_id = @"MAEventCellID";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.contentView addSubview:self.timeScrollView];
        [self.timeScrollView addSubview:self.timeRowsView];
        [self.contentView addSubview:self.timedEventsView];

    }
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - Gesture

- (void)handleLongPress:(UILongPressGestureRecognizer*)gesture
{
    CGPoint ptSelf = [gesture locationInView:self];
    
    UICollectionView *view = (UICollectionView*)gesture.view;
    NSIndexPath *path = [view indexPathForItemAtPoint:[gesture locationInView:view]];
    if (path) {
        
        UICollectionViewCell *cell = [view cellForItemAtIndexPath:path];
        self.interactiveEventView.frame = cell.frame;
        self.interactiveEventView.center = cell.center;

    }else{
        self.interactiveEventView.frame = CGRectMake(0, 0, 200, 60);
        self.interactiveEventView.center = ptSelf;
    }
    
    if (!self.interactiveEventView.superview) {
        [self.timedEventsView addSubview:self.interactiveEventView];
    }
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MAEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:event_cell_id forIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    return cell;;
}

//- (UICollectionViewCell*)dequeueCellForEventOfType:(MGCEventType)type atIndexPath:(NSIndexPath*)indexPath
//{
//
//}

#pragma mark - MATimedEventsViewLayoutDelegate

- (CGRect)collectionView:(UICollectionView*)collectionView layout:(MATimedEventsViewLayout*)layout rectForEventAtIndexPath:(NSIndexPath*)indexPath
{
    return CGRectMake(0, 150 + indexPath.row * 40, 0, 150);
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.timedEventsView) {
        CGPoint contentOffset = scrollView.contentOffset;
        self.timeScrollView.contentOffset = CGPointMake(0, contentOffset.y);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.timeScrollView.frame = self.contentView.bounds;
    self.timeScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame), 65 * 30);
    
    self.timedEventsView.frame = self.contentView.bounds;

    self.timeRowsView.frame = CGRectMake(0, 0, self.timeScrollView.contentSize.width, self.timeScrollView.contentSize.height);
}

#pragma mark - Getter

- (UIScrollView*)timeScrollView
{
    if (!_timeScrollView) {
        _timeScrollView = [[UIScrollView alloc] init];
        _timeScrollView.backgroundColor = [UIColor whiteColor];
        _timeScrollView.delegate = self;
        _timeScrollView.showsVerticalScrollIndicator = YES;
        _timeScrollView.showsHorizontalScrollIndicator = YES;
        _timeScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return _timeScrollView;
}

- (MATimeRowsView *)timeRowsView
{
    if (!_timeRowsView) {
        _timeRowsView = [[MATimeRowsView alloc] init];
        _timeRowsView.contentMode = UIViewContentModeRedraw;
    }
    return _timeRowsView;
}

- (MATimedEventsViewLayout*)timedEventsViewLayout
{
    if (!_timedEventsViewLayout) {
        _timedEventsViewLayout = [MATimedEventsViewLayout new];
        _timedEventsViewLayout.delegate = self;
    }
    return _timedEventsViewLayout;
}

- (UICollectionView*)timedEventsView
{
    if (!_timedEventsView) {
        _timedEventsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.timedEventsViewLayout];
        _timedEventsView.backgroundColor = [UIColor clearColor];
        _timedEventsView.dataSource = self;
        _timedEventsView.delegate = self;
        _timedEventsView.showsVerticalScrollIndicator = NO;
        _timedEventsView.showsHorizontalScrollIndicator = NO;
        _timedEventsView.scrollsToTop = NO;
        _timedEventsView.decelerationRate = UIScrollViewDecelerationRateFast;
        _timedEventsView.allowsSelection = NO;
        _timedEventsView.directionalLockEnabled = YES;
        
        [_timedEventsView registerClass:MAEventCell.class forCellWithReuseIdentifier:event_cell_id];
        
        UILongPressGestureRecognizer *longPress = [UILongPressGestureRecognizer new];
        [longPress addTarget:self action:@selector(handleLongPress:)];
        [_timedEventsView addGestureRecognizer:longPress];
//
//        UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
//        [tap addTarget:self action:@selector(handleTap:)];
//        [_timedEventsView addGestureRecognizer:tap];
//
//        UIPinchGestureRecognizer *pinch = [UIPinchGestureRecognizer new];
//        [pinch addTarget:self action:@selector(handlePinch:)];
//        [_timedEventsView addGestureRecognizer:pinch];
    }
    return _timedEventsView;
}

- (UIView *)interactiveEventView
{
    if (!_interactiveEventView) {
        _interactiveEventView = [UIView new];
        _interactiveEventView.backgroundColor = [UIColor redColor];
        _interactiveEventView.layer.zPosition = 10;
    }
    return _interactiveEventView;
}

@end
