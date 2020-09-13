//
//  MAExpendListCell.m
//  MABasicKit_Example
//
//  Created by 马启晗 on 2020/9/12.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MAExpendListCell.h"

@implementation MAExpendListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.icon];
        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.left.equalTo(self.contentView.mas_left).offset(15);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
        
        [self.contentView addSubview:self.checkboxButton];
        [self.checkboxButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.right.equalTo(self.contentView.mas_right).offset(-5);
            make.width.equalTo(@50);
        }];
        
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.left.equalTo(self.icon.mas_right).offset(5);
            make.right.equalTo(self.checkboxButton.mas_left);
        }];
    }
    return self;
}

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (indexPath.row != 0 ) {
        self.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setModel:(MAExpendListModel *)model
{
    _model = model;
    self.titleLabel.text = model.title;
    
    if (model.state == 0) {
        [self.checkboxButton setImage:[UIImage imageNamed:@"chapter_state_0"] forState:UIControlStateNormal];

    }else if (model.state == 1){
        [self.checkboxButton setImage:[UIImage imageNamed:@"chapter_state_1"] forState:UIControlStateNormal];

    }else{
        [self.checkboxButton setImage:[UIImage imageNamed:@"chapter_state_2"] forState:UIControlStateNormal];
    }
    
    if (!model.children.count) {
        self.icon.image = nil;
    }else{
        if (model.expend) {
            self.icon.image = [UIImage imageNamed:@"homework_knowledge_list_2"];
        }else{
            self.icon.image = [UIImage imageNamed:@"homework_knowledge_list_1"];
        }
    }
    
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset((model.depth+1) * 15);
        make.width.equalTo(@10);
        make.height.equalTo(@10);
    }];
}

- (void)checkboxButtonAction
{
    if (self.model.state == 0) {
        self.model.state = 1;
    }else if (self.model.state == 1){
        self.model.state = 0;
    }else{
        self.model.state = 1;
    }
    
    !self.didChangeSeletedBlock ? : self.didChangeSeletedBlock(self.model);
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel               = [[UILabel alloc] init];
        _titleLabel.font          = [UIFont systemFontOfSize:16];
//        _titleLabel.textColor     = [UIColor colorWithHexString:@"323233"];
    }
    return _titleLabel;
}

- (UIButton *)checkboxButton
{
    if (!_checkboxButton) {
        _checkboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkboxButton setImage:[UIImage imageNamed:@"chapter_state_0"] forState:UIControlStateNormal];
        [_checkboxButton addTarget:self action:@selector(checkboxButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkboxButton;
}

- (UIImageView *)icon
{
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _icon;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
