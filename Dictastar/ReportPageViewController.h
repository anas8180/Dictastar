//
//  ReportPageViewController.h
//  Dictastar
//
//  Created by mohamed on 29/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportPageViewController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property NSUInteger selectedIndex;

@end
