//
//  ProfileTableViewCell.h
//  Dictastar
//
//  Created by mohamed on 28/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UITextField *valueText;
@property (nonatomic, strong) IBOutlet UIButton *selectRadioButton;

@end
