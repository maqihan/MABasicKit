//
//  MACalendarContainerCell.m
//  MABasicKit_Example
//
//  Created by maqihan on 2020/12/4.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MACalendarContainerCell.h"
#import "MGCTimeRowsView.h"

@interface MACalendarContainerCell()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *timeScrollView;
@property (nonatomic, strong) MGCTimeRowsView *timeRowsView;

@end

@implementation MACalendarContainerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.timeScrollView];
        [self.timeScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        [self.contentView addSubview:self.timeRowsView];
        [self.timeRowsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading);
            make.top.equalTo(self.contentView.mas_top);
            make.trailing.equalTo(self.contentView.mas_trailing);
            make.height.equalTo(self.timeScrollView.contentSize.height);
        }];
    }
    return self;
}

- (UIScrollView*)timeScrollView
{
    if (!_timeScrollView) {
        _timeScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _timeScrollView.backgroundColor = [UIColor clearColor];
        _timeScrollView.delegate = self;
        _timeScrollView.showsVerticalScrollIndicator = NO;
        _timeScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _timeScrollView.scrollEnabled = NO;
    }
    return _timeScrollView;
}

- (MGCTimeRowsView *)timeRowsView
{
    if (!_timeRowsView) {
        _timeRowsView = [[MGCTimeRowsView alloc] initWithFrame:CGRectZero];
        _timeRowsView.contentMode = UIViewContentModeRedraw;
        [_timeScrollView addSubview:_timeRowsView];
    }
    return _timeRowsView;
}

@end
