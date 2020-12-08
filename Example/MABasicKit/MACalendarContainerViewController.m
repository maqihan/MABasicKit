//
//  MACalendarContainerViewController.m
//  MABasicKit_Example
//
//  Created by maqihan on 2020/12/2.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MACalendarContainerViewController.h"
#import "MACalendarContainerCell.h"

@interface MACalendarContainerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView *containerView;

@end

@implementation MACalendarContainerViewController
static NSString * const cell_id_0   = @"MACalendarContainerCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"日历";
    self.navigationController.navigationBar.translucent = NO;
    
    [self.view addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)_recenterIfNeeded
{
    CGFloat xOffset = self.containerView.contentOffset.x;
    CGFloat xContentSize = self.containerView.contentSize.width;
    CGFloat xPageSize = self.containerView.bounds.size.width;

    if (xOffset < xPageSize || xOffset + 2 * xPageSize > xContentSize) {

        [self.containerView setContentOffset:CGPointMake(xPageSize * 2, self.containerView.contentOffset.y)];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollview
{
    [self _recenterIfNeeded];
}

#pragma mark - UICollectionView

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
    MACalendarContainerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cell_id_0 forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor grayColor];
    return cell;;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (UICollectionView *)containerView
{
    if (!_containerView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;

        _containerView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _containerView.pagingEnabled = YES;
        _containerView.dataSource =self;
        _containerView.delegate   =self;
        _containerView.showsVerticalScrollIndicator = NO;
        _containerView.showsHorizontalScrollIndicator = YES;
        _containerView.backgroundColor = [UIColor whiteColor];
        
        [_containerView registerClass:[MACalendarContainerCell class] forCellWithReuseIdentifier:cell_id_0];
    }
    return _containerView;
}



@end
