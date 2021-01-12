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
#import "MAEventFloatingView.h"

@interface MACalendarContainerCell()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,MATimedEventsViewLayoutDelegate>

@property (nonatomic, strong) UIScrollView *timeScrollView;
@property (nonatomic, strong) MATimeRowsView *timeRowsView;

@property (nonatomic, strong) UICollectionView *timedEventsView;

@property (nonatomic, strong) MAEventFloatingView *floatingView;

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
    UICollectionView *view = (UICollectionView*)gesture.view;
    NSIndexPath *path = [view indexPathForItemAtPoint:[gesture locationInView:view]];
    if (path) {
        
        UICollectionViewCell *cell = [view cellForItemAtIndexPath:path];
        self.floatingView.frame = cell.frame;
        self.floatingView.center = cell.center;

    }else{
        
        CGPoint point = [gesture locationInView:view];
        self.floatingView.frame = CGRectMake(0, 0, 200, 60);
        self.floatingView.center = point;
    }
    self.floatingView.hidden = NO;
}

- (void)handleTap:(UITapGestureRecognizer*)gesture
{
    if (_floatingView) {
        self.floatingView.hidden = YES;
        self.floatingView = nil;
    }else{
        UICollectionView *view = (UICollectionView*)gesture.view;
        CGPoint point = [gesture locationInView:view];
        self.floatingView.frame = CGRectMake(0, 0, 200, 60);
        self.floatingView.center = point;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)gesture
{
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
    self.timeScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame), 65 *24);
    
    self.timedEventsView.frame = self.contentView.bounds;
    self.timedEventsView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame), 650 *24);

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

- (UICollectionView*)timedEventsView
{
    if (!_timedEventsView) {
        
        MATimedEventsViewLayout *layout = [MATimedEventsViewLayout new];
        layout.delegate = self;

        _timedEventsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
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

        UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
        [tap addTarget:self action:@selector(handleTap:)];
        [_timedEventsView addGestureRecognizer:tap];

//        UIPinchGestureRecognizer *pinch = [UIPinchGestureRecognizer new];
//        [pinch addTarget:self action:@selector(handlePinch:)];
//        [_timedEventsView addGestureRecognizer:pinch];
    }
    return _timedEventsView;
}

- (MAEventFloatingView *)floatingView
{
    if (!_floatingView) {
        _floatingView = [MAEventFloatingView new];
        _floatingView.backgroundColor = [UIColor redColor];
        _floatingView.layer.zPosition = 10;
        [self.timedEventsView addSubview:_floatingView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_floatingView addGestureRecognizer:pan];

    }
    return _floatingView;
}

@end
