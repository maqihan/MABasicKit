//
//  MAExpendListCell.h
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/9/12.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAExpendListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MAExpendListCell : UITableViewCell

@property (strong , nonatomic) MAExpendListModel *model;

@property (strong , nonatomic) UILabel     *titleLabel;
@property (strong , nonatomic) UIImageView *icon;
@property (strong , nonatomic) UIButton    *checkboxButton;
@property (strong , nonatomic) NSIndexPath *indexPath;

@property (nonatomic, copy) void (^didChangeSeletedBlock)(MAExpendListModel *model);

@end

NS_ASSUME_NONNULL_END
