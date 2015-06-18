//
//  NoDataViewCell.h
//  Dictastar
//
//  Created by mohamed on 18/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoDataViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingView;

@end
