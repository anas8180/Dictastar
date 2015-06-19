//
//  DictateViewController.m
//  Dictastar
//
//  Created by mohamed on 17/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "DictateViewController.h"
#import "InformationViewController.h"
#import "RecordViewController.h"
#import "ReportViewController.h"

@interface DictateViewController ()
{
    UIScrollView *pageScrollView;
    NSInteger currentPageIndex;
}
@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) NSMutableArray *viewControllerArray;
@property (strong, nonatomic) IBOutlet UIImageView *infoArrow;
@property (strong, nonatomic) IBOutlet UIImageView *dictateArrow;
@property (strong, nonatomic) IBOutlet UIImageView *reportArrow;

@end

@implementation DictateViewController
@synthesize dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _viewControllerArray = [NSMutableArray array];

    NSLog(@"%@",dataDict);
    
    InformationViewController *infoVC = (InformationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"InformationView"];
    infoVC.dataDict = dataDict;
    infoVC.title = @"INFORMATION";
    
    RecordViewController *recordVC = (RecordViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"RecordView"];
    recordVC.dataDict = dataDict;
    recordVC.title = @"DICTATE";

    ReportViewController *reportVC = (ReportViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ReportView"];
    reportVC.dataDict = dataDict;
    reportVC.title = @"PRE REPORTS";


    [_viewControllerArray addObject:infoVC];
    [_viewControllerArray addObject:recordVC];
    [_viewControllerArray addObject:reportVC];
    
    [self setupPageViewController];
    
    _reportArrow.hidden = YES;
    _dictateArrow.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.tabBarController.tabBar.hidden=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupPageViewController
{
    _pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    
    _pageController.delegate = self;
    _pageController.dataSource = self;
    [_pageController setViewControllers:@[[_viewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    _pageController.view.frame = CGRectMake(0, 114, self.view.frame.size.width, self.view.frame.size.height - 114);
    [self addChildViewController:_pageController];
    [self.view addSubview:_pageController.view];
    [_pageController didMoveToParentViewController:self];
    
    [self syncScrollView];
}

-(void)syncScrollView
{
    for (UIView* view in _pageController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]])
        {
            pageScrollView = (UIScrollView *)view;
            pageScrollView.delegate = self;
        }
    }
}
- (IBAction)segmentToggled:(id)sender {
    
    NSInteger tempIndex = currentPageIndex;
    
    __weak typeof(self) weakSelf = self;
    
    //%%% check to see if you're going left -> right or right -> left
    if ([sender tag] > tempIndex) {
        
        //%%% scroll through all the objects between the two points
        for (int i = (int)tempIndex+1; i<=[sender tag]; i++) {
            [_pageController setViewControllers:@[[_viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
                
                //%%% if the action finishes scrolling (i.e. the user doesn't stop it in the middle),
                //then it updates the page that it's currently on
                if (complete) {
                    [weakSelf updateCurrentPageIndex:i];
                }
            }];
        }
    }
    
    //%%% this is the same thing but for going right -> left
    else if ([sender tag] < tempIndex) {
        for (int i = (int)tempIndex-1; i >= [sender tag]; i--) {
            [_pageController setViewControllers:@[[_viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
                if (complete) {
                    [weakSelf updateCurrentPageIndex:i];
                }
            }];
        }
    }

}

-(void)updateCurrentPageIndex:(int)newIndex
{
    currentPageIndex = newIndex;
    NSLog(@"%ld",(long)currentPageIndex);
    
    if(currentPageIndex == 0) {
        
        _infoArrow.hidden = NO;
        _dictateArrow.hidden = YES;
        _reportArrow.hidden = YES;
    }
    else if (currentPageIndex == 1) {
        
        _infoArrow.hidden = YES;
        _dictateArrow.hidden = NO;
        _reportArrow.hidden = YES;
    }
    else {
        _infoArrow.hidden = YES;
        _dictateArrow.hidden = YES;
        _reportArrow.hidden = NO;
    }
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    index--;
    return [_viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [_viewControllerArray count]) {
        return nil;
    }
    return [_viewControllerArray objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        currentPageIndex = [self indexOfController:[pageViewController.viewControllers lastObject]];
        
        if(currentPageIndex == 0) {
            
            _infoArrow.hidden = NO;
            _dictateArrow.hidden = YES;
            _reportArrow.hidden = YES;
        }
        else if (currentPageIndex == 1) {
            
            _infoArrow.hidden = YES;
            _dictateArrow.hidden = NO;
            _reportArrow.hidden = YES;
        }
        else {
            _infoArrow.hidden = YES;
            _dictateArrow.hidden = YES;
            _reportArrow.hidden = NO;
        }

    }
}

-(NSInteger)indexOfController:(UIViewController *)viewController
{
    for (int i = 0; i<[_viewControllerArray count]; i++) {
        if (viewController == [_viewControllerArray objectAtIndex:i])
        {
            return i;
        }
    }
    return NSNotFound;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
