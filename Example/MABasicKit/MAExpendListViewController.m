//
//  MAExpendListViewController.m
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/9/12.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MAExpendListViewController.h"
#import "MAExpendListModel.h"
#import "MAExpendListCell.h"


@interface MAExpendListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView    *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) NSMutableArray *sectionArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation MAExpendListViewController
static NSString * const cell_ID   = @"MAExpendListCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"多级列表";
    
    [self loadData];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
        
}

#pragma mark - table detagate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *subArray = self.sectionArray[section];
    return subArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 62;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAExpendListCell * cell = [tableView dequeueReusableCellWithIdentifier:cell_ID];
    
    NSArray *subArray = self.sectionArray[indexPath.section];
    MAExpendListModel *model = subArray[indexPath.row];

    cell.model = model;
    cell.indexPath = indexPath;

    @weakify(self);
    cell.didChangeSeletedBlock = ^(MAExpendListModel * _Nonnull model) {
        @strongify(self);

        [self _updateParentsDataWithModel:model];
        [self _updateChildrenDataWithModel:model];
        [self.tableView reloadData];
    };
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *subArray = self.sectionArray[indexPath.section];
    MAExpendListModel *model = subArray[indexPath.row];

    //没有子节点
    if (!model.children.count) {
        return;
    }
    
    model.expend = !model.expend;
    
    NSMutableArray *pathArray = [NSMutableArray array];

    [self.tableView beginUpdates];
    
    //刷新点击的cell的状态
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    if (model.expend) {
        //打开cell
        for (NSInteger i = 0; i < model.children.count; i++) {

            NSIndexPath* insertPath = [NSIndexPath indexPathForRow:indexPath.row+i+1 inSection:indexPath.section];
            [pathArray addObject:insertPath];
            
            MAExpendListModel *subModel = model.children[i];
            [subArray insertObject:subModel atIndex:insertPath.row];
        }
        [self.tableView insertRowsAtIndexPaths:pathArray withRowAnimation:UITableViewRowAnimationNone];

    }else{
        //关闭cell 需要递归将所有子节点都关闭
        [self _foldWithModel:model section:subArray path:pathArray indexPath:indexPath];
        [self.tableView deleteRowsAtIndexPaths:pathArray withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self.tableView endUpdates];
}

- (void)_foldWithModel:(MAExpendListModel *)model
               section:(NSMutableArray *)subArray
                  path:(NSMutableArray *)pathArray
             indexPath:(NSIndexPath *)indexPath
{
    for (NSInteger i = 0; i < model.children.count; i++) {
        MAExpendListModel *subModel = model.children[i];
        [subArray removeObject:subModel];

        NSIndexPath* lastPath = [pathArray lastObject];
        NSIndexPath* deletePath = nil;
        if (!lastPath) {
            deletePath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            [pathArray addObject:deletePath];
        }else{
            deletePath = [NSIndexPath indexPathForRow:lastPath.row + 1 inSection:indexPath.section];
            [pathArray addObject:deletePath];
        }
                
        if (subModel.expend && subModel.children.count) {
            [self _foldWithModel:subModel section:subArray path:pathArray indexPath:deletePath];
        }
        
        subModel.expend = NO;
    }
}

//获取选择的知识点 需要过滤掉父节点 只保留叶子结点
- (void)_leafSeletedModelsWithData:(NSArray *)dataArray
{
    for (MAExpendListModel *model in dataArray) {
        if (model.state == 1 && !model.children.count) {
            [self.selectedArray addObject:model];
        }
        [self _leafSeletedModelsWithData:model.children];
    }
}

- (MAExpendListModel *)_modelWithId:(NSString *)Id data:(NSArray *)dataArray
{
    for (MAExpendListModel *model in dataArray) {
        if ([model.Id isEqualToString:Id]) {
            return model;
        }
        
        MAExpendListModel * res =[self _modelWithId:Id data:model.children];
        if (!res) {
            continue;
        }else{
            return res;
        }
    }
    return nil;
}

//更新父节点状态
- (void)_updateParentsDataWithModel:(MAExpendListModel *)model
{
    if (!model.parentId.length) {
        return;
    }
    
    MAExpendListModel *parentModel = [self _modelWithId:model.parentId data:self.dataArray];
    
    if (!parentModel) {
        return;
    }
    NSInteger state0Count = 0;
    NSInteger state1Count = 0;
    NSInteger state2Count = 0;
    
    for (MAExpendListModel *subModel in parentModel.children) {
        if (subModel.state == 0) {
            state0Count++;
        }else if (subModel.state == 1){
            state1Count++;
        }else{
            state2Count++;
        }
    }
    
    if (parentModel.children.count == state0Count) {
        parentModel.state = 0;
    }else if (parentModel.children.count == state1Count){
        parentModel.state = 1;
    }else{
        parentModel.state = 2;
    }
        
    [self _updateParentsDataWithModel:parentModel];
}

//更新子节点状态
- (void)_updateChildrenDataWithModel:(MAExpendListModel *)model
{
    for (MAExpendListModel *subModel in model.children) {
        subModel.state = model.state;
        [self _updateChildrenDataWithModel:subModel];
    }
}

//计算node的深度
- (void)_depthInRoot:(MAExpendListModel *)node depth:(NSInteger)depth
{
    node.depth = depth;
    if (node.children.count) {
        depth++;
    }
    for (MAExpendListModel *subNode in node.children) {
        [self _depthInRoot:subNode depth:depth];
    }
}

#pragma mark - getter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        //如果不添加下面的方法，会导致添加cell时候 页面跳动
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        
        [_tableView registerClass:[MAExpendListCell class] forCellReuseIdentifier:cell_ID];
    }
    return _tableView;
}

- (NSMutableArray *)sectionArray
{
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray array];
    }
    return _sectionArray;
}

- (NSMutableArray *)selectedArray
{
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

- (void)loadData
{
    NSArray *data = @[@{@"Id":@"1",
                        @"parentId":@"0",
                        @"title":@"第一单元",
                        @"children":@[@{
                                          @"Id":@"1-1",
                                          @"parentId":@"1",
                                          @"title":@"第一节",
                                          @"children":@[@{
                                                            @"Id":@"1-1-1",
                                                            @"parentId":@"1-1",
                                                            @"title":@"第一课",
                                          }],
                        },@{
                                          @"Id":@"1-2",
                                          @"parentId":@"1",
                                          @"title":@"第二节",
                                          @"children":@[@{
                                                            @"Id":@"1-2-1",
                                                            @"parentId":@"1-2",
                                                            @"title":@"第一课",
                                          }],
                        }
                        ],},@{@"Id":@"2",
                              @"parentId":@"0",
                              @"title":@"第二单元",
                              @"children":@[@{
                                                @"Id":@"2-1",
                                                @"parentId":@"2",
                                                @"title":@"第2-1节",
                                                @"children":@[@{
                                                                  @"Id":@"2-1-1",
                                                                  @"parentId":@"2-1",
                                                                  @"title":@"第2-1-1课",
                                                }],
                              }],},@{@"Id":@"3",
                                     @"parentId":@"0",
                                     @"title":@"第三单元",
                                     @"children":@[@{
                                                       @"Id":@"3-1",
                                                       @"parentId":@"3",
                                                       @"title":@"第3-1节",
                                                       @"children":@[@{
                                                                         @"Id":@"3-1-1",
                                                                         @"parentId":@"3-1",
                                                                         @"title":@"第3-1-1课",
                                                       }],
                                     }],},@{@"Id":@"4",
                                            @"parentId":@"0",
                                            @"title":@"第四单元",
                                            @"children":@[@{
                                                              @"Id":@"4-1",
                                                              @"parentId":@"4",
                                                              @"title":@"第4-1节",
                                                              @"children":@[@{
                                                                                @"Id":@"4-1-1",
                                                                                @"parentId":@"4-1",
                                                                                @"title":@"第4-1-1课",
                                                              }],
                                            }],},];
    self.dataArray = [MAExpendListModel mj_objectArrayWithKeyValuesArray:data];

    //计算每个节点的深度
    for (MAExpendListModel *model in self.dataArray) {
        [self _depthInRoot:model depth:0];
    }
    
    for (MAExpendListModel *model in self.dataArray) {
        NSMutableArray *subArray = [NSMutableArray array];
        [subArray addObject:model];
        [self.sectionArray addObject:subArray];
    }
}

@end
