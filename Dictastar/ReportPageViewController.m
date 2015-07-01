//
//  ReportPageViewController.m
//  Dictastar
//
//  Created by mohamed on 29/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "ReportPageViewController.h"
#import "ReportDetailViewController.h"

@interface ReportPageViewController ()

@property (nonatomic, strong) UIPageViewController *pageController;
@property (strong, nonatomic) IBOutlet UILabel *titleLable;
@property (strong, nonatomic) IBOutlet UIButton *previousButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation ReportPageViewController
@synthesize dataArray;
@synthesize selectedIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    NSLog(@"%lu",(unsigned long)selectedIndex);
    NSLog(@"%@",dataArray);
    
    _titleLable.text = [NSString stringWithFormat:@"%@   %@",[[dataArray objectAtIndex:selectedIndex] objectForKey:@"AttendingPhysician"],[[dataArray objectAtIndex:selectedIndex] objectForKey:@"ServiceDate"]];
    
    [self setupPageViewController];
    
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

- (ReportDetailViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([dataArray count] == 0) || (index >= [dataArray count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ReportDetailViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportDetailVC"];
    pageContentViewController.dataDict = dataArray[index];
    pageContentViewController.pageIndex = index;

    return pageContentViewController;
}

-(void)setupPageViewController
{
    _pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    
    _pageController.delegate = self;
    _pageController.dataSource = self;
    
    ReportDetailViewController *startingViewController = [self viewControllerAtIndex:selectedIndex];
    NSArray *viewControllers = @[startingViewController];

    [_pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    _pageController.view.frame = CGRectMake(0, 114, self.view.frame.size.width, self.view.frame.size.height-114);
    [self addChildViewController:_pageController];
    [self.view addSubview:_pageController.view];
    [_pageController didMoveToParentViewController:self];
    
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ReportDetailViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        
        return nil;
    }
    
    index--;
    _titleLable.text = [NSString stringWithFormat:@"%@   %@",[[dataArray objectAtIndex:index] objectForKey:@"AttendingPhysician"],[[dataArray objectAtIndex:index] objectForKey:@"ServiceDate"]];

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ReportDetailViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [dataArray count]) {
        
        return nil;
    }
    
    _titleLable.text = [NSString stringWithFormat:@"%@   %@",[[dataArray objectAtIndex:index] objectForKey:@"AttendingPhysician"],[[dataArray objectAtIndex:index] objectForKey:@"ServiceDate"]];

    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [dataArray count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


- (IBAction)goToNext:(id)sender {
    
    [self changePage:UIPageViewControllerNavigationDirectionForward];
    
}
- (IBAction)goToPrevious:(id)sender {
    
    [self changePage:UIPageViewControllerNavigationDirectionReverse];

}

- (void)changePage:(UIPageViewControllerNavigationDirection)direction {
    
    NSUInteger pageIndex = ((ReportDetailViewController *) [_pageController.viewControllers objectAtIndex:0]).pageIndex;
    
    if (direction == UIPageViewControllerNavigationDirectionForward) {
        pageIndex++;
    }
    else {
        pageIndex--;
    }
    
    ReportDetailViewController *viewController = [self viewControllerAtIndex:pageIndex];
    
    if (viewController == nil) {
        return;
    }
    
    _titleLable.text = [NSString stringWithFormat:@"%@   %@",[[dataArray objectAtIndex:pageIndex] objectForKey:@"AttendingPhysician"],[[dataArray objectAtIndex:pageIndex] objectForKey:@"ServiceDate"]];

    [_pageController setViewControllers:@[viewController]
                                  direction:direction
                                   animated:YES
                                 completion:nil];
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
