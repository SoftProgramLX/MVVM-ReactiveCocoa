//
//  LXTableViewCell.m
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "LXTableViewCell.h"
#import "UserModel.h"

@interface LXTableViewCell ()

@property (nonatomic, weak)   UIImageView *imageV;
@property (nonatomic, weak)   UILabel *nameLabel;
@property (nonatomic, weak)   UILabel *descLabel;

@end

@implementation LXTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"LXTableViewCell";
    LXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[LXTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(18, 10, 60, 60)];
        [self.contentView addSubview:image];
        self.imageV = image;

        CGFloat nameLabelX = image.x + image.width + 8;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, image.y, ScreenWidth - nameLabelX - 18, 16)];
        nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        CGFloat descLabelY = nameLabel.y + nameLabel.height + 5;
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, descLabelY, nameLabel.width, image.y + image.height - descLabelY)];
        descLabel.font = [UIFont systemFontOfSize:14];
        descLabel.numberOfLines = 2;
        descLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:descLabel];
        self.descLabel = descLabel;
    }
    return self;
}

- (void)configurationCell:(id)object
{
    UserModel *user = object;
    self.nameLabel.text = user.name;
    self.descLabel.text = user.desc;
    
    self.imageV.image = nil;
    //这是ARC的一个子线程去加载图片，当然也可以用SDWebImage
    @weakify(self);
    [[[AFNetWorkHelp signalForLoadingImage:user.avatar]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(UIImage *image) {
         @strongify(self);
         self.imageV.image = [image cutIntoACircleImage];
     }];
}

@end


