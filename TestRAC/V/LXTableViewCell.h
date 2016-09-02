//
//  LXTableViewCell.h
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (void)configurationCell:(id)object;

@end
