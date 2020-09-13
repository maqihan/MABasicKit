//
//  MAExpendListModel.h
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/9/12.
//  Copyright © 2020 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MAExpendListModel : NSObject

@property (strong , nonatomic) NSString *Id;
@property (strong , nonatomic) NSString *title;
@property (strong , nonatomic) NSString *parentId;

//是否是展开状态
@property (assign , nonatomic) BOOL expend;
//三种状态 0未选中 1选中  2子节点有选中
@property (assign , nonatomic) NSInteger state;
//节点深度
@property (assign , nonatomic) NSInteger depth;

@property (strong , nonatomic) NSArray <MAExpendListModel *> *children;

@end

NS_ASSUME_NONNULL_END
