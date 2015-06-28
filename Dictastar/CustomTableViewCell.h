//
//  CustomTableViewCell.h
//  Dictastar
//
//  Created by mohamed on 16/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *subTitle;
@property (nonatomic, strong) IBOutlet UILabel *accessoryLable;
@property (nonatomic, strong) IBOutlet UIButton *selectRadioButton;
@property (nonatomic, strong) IBOutlet UIImageView *statusIcon;
@property (nonatomic, strong) IBOutlet UILabel *statusLable;
@property (nonatomic, strong) IBOutlet UIImageView *recordIcon;
@property (nonatomic, strong) IBOutlet UIImageView *headSetIcon;
@property (nonatomic, strong) IBOutlet UIImageView *editIcon;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loaderView;

@end
