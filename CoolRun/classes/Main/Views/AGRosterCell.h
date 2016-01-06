//
//  AGRosterCell.h
//  CoolRun
//
//  Created by adrian gong on 16/1/6.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGRosterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *onLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@end
