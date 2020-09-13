//
//  MAHomeViewController.m
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/9/12.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MAHomeViewController.h"
#import "MAHomeListCell.h"

@interface MAHomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) NSArray      *dataArray;

@end

@implementation MAHomeViewController

static NSString * const cell_ID   = @"MAHomeListCellID";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"Example List";
    self.dataArray = @[@{@"vc":@"MAExpendListViewController",
                         @"title":@"多级列表",
                         @"desc":@"支持选择状态，多级展开，多级折叠"}];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - table detagate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAHomeListCell * cell = [tableView dequeueReusableCellWithIdentifier:cell_ID];
    NSDictionary *dict = self.dataArray[indexPath.row];
    cell.titleLabel.text = [dict valueForKey:@"title"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *vcName = [self.dataArray[indexPath.row] valueForKey:@"vc"];
    UIViewController *viewController = [[NSClassFromString(vcName) alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - getter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;

        [_tableView registerClass:[MAHomeListCell class] forCellReuseIdentifier:cell_ID];
    }
    return _tableView;
}

@end
