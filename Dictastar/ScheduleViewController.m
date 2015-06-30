//
//  ScheduleViewController.m
//  Dictastar
//
//  Created by mohamed on 16/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "ScheduleViewController.h"
#import "BTServicesClient.h"
#import "CustomTableViewCell.h"
#import "NoDataViewCell.h"
#import "ReportTypeViewController.h"

@interface ScheduleViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (strong, nonatomic) IBOutlet UILabel *scheduleDateLable;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSDate *currentDate;
@property (nonatomic) BOOL isLoading;

@end

@implementation ScheduleViewController
@synthesize isFromHome;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Schedule";
    
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];

    _currentDate = [NSDate date];

    [self getDate];
    [self fetchPatientInfo];
    
//    self.tableView.estimatedRowHeight = 70.0;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isFromHome) {
        self.tabBarController.tabBar.hidden=NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (isFromHome) {
        self.tabBarController.tabBar.hidden=NO;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(_dataArray.count == 0) {
        
        return 1;
    }
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_dataArray.count == 0) {
        
        return self.tableView.frame.size.height;
    }
    
    return 70.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataArray.count == 0) {
        
        NoDataViewCell *cell = (NoDataViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NoCell" forIndexPath:indexPath];
        
        if (_isLoading) {
            
            cell.title.text = @"Loading";
            [cell.loadingView startAnimating];
        }
        else {
            
        cell.title.text = @"No Results Found";
        [cell.loadingView stopAnimating];
            
        }
        
        return cell;
    }
    else  {
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {  // Safety check for below iOS 7
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
    cell.title.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
    cell.subTitle.text = [NSString stringWithFormat:@"%@ %@ - %@",[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Gender"],[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"DOB"],[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"ProcedureName"]];
    
    NSString *status = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Status"];
        NSLog(@"Status:%@",status);
        
        if ([status isEqualToString:@"Signed"]) {
            cell.editIcon.alpha = 1;
            cell.headSetIcon.alpha = 1;
            cell.recordIcon.alpha = 1;
        }
        else if ([status isEqualToString:@"Checked in"]) {
            cell.headSetIcon.alpha = 1;
            cell.recordIcon.alpha = 1;
            cell.editIcon.alpha = 0.2;
        }
        else if([status isEqualToString:@"Dictated"]) {
            cell.recordIcon.alpha = 1;
            cell.editIcon.alpha = 0.2;
            cell.headSetIcon.alpha = 0.2;
        }
        else{
            cell.recordIcon.alpha =0.2;
            cell.editIcon.alpha = 0.2;
            cell.headSetIcon.alpha = 0.2;
        }
    
    return cell;
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Method

-(void)fetchPatientInfo {
    
    _isLoading = YES;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    NSString *dateString = [dateFormat stringFromDate:_currentDate];
    
    NSDictionary *params = @{@"FacilityId":[_userInfo objectForKey:@"FacilityId"],@"Fromdate":dateString,@"Todate":dateString};
    
    [[BTServicesClient sharedClient] GET:@"FetchPatientJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        _dataArray = [jsonData objectForKey:@"Table"];
        
        _isLoading = NO;
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        _isLoading = NO;
        
        [self.tableView reloadData];

    }];

}

-(void)getDate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    NSString *dateString = [dateFormat stringFromDate:_currentDate];
    
    _scheduleDateLable.text = [NSString stringWithFormat:@"%@",dateString]; 
    
   /* NSString *str = @"2014-04-01"; /// here this is your date with format yyyy-MM-dd
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
    [dateFormatter setDateFormat:@"yyyy-MM-dd"]; //// here set format of date which is in your output date (means above str with format)
    
    NSDate *date = [dateFormatter dateFromString: str]; // here you can fetch date from string with define format
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];// here set format which you want...
    
    NSString *convertedString = [dateFormatter stringFromDate:date]; //here convert date in NSString
    NSLog(@"Converted String : %@",convertedString);
   
   _scheduleDateLable.text = [NSString stringWithFormat:@"%@",convertedString]; */
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.day   = -1;
    NSDate *date = [calendar dateByAddingComponents:comps toDate:_currentDate options:0];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date]; // Get necessary date components
    /*NSLog(@"Previous month: %ld",(long)[components month]);
    NSLog(@"Previous day  : %ld",(long)[components day]);
    NSLog(@"Previous month: %ld",(long)[components year]); */
    
    NSString *str = [NSString stringWithFormat:@"%ld-%ld-%ld",[components year],[components month],[components day]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dt = [dateFormatter dateFromString: str];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
     NSString *convertedString = [dateFormatter stringFromDate:dt];
    _currentDate = [dateFormatter dateFromString:convertedString];

    [self getDate];
    if (_dataArray != nil) {
        _dataArray = nil;
    }
    
    _dataArray = [[NSArray alloc]init];
    [self.tableView reloadData];
    [self fetchPatientInfo];
}
- (IBAction)forwardAction:(id)sender {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.day   = +1;
    NSDate *date = [calendar dateByAddingComponents:comps toDate:_currentDate options:0];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date]; // Get necessary date components
 /*   NSLog(@"Previous month: %ld",(long)[components month]);
    NSLog(@"Previous day  : %ld",(long)[components day]);
    NSLog(@"Previous month: %ld",(long)[components year]); */
    
    NSString *str = [NSString stringWithFormat:@"%ld-%ld-%ld",[components year],[components month],[components day]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dt = [dateFormatter dateFromString: str];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *convertedString = [dateFormatter stringFromDate:dt];
    _currentDate = [dateFormatter dateFromString:convertedString];
    
    [self getDate];
    if (_dataArray != nil) {
        _dataArray = nil;
    }
    
    _dataArray = [[NSArray alloc]init];
    [self.tableView reloadData];
    [self fetchPatientInfo];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    ReportTypeViewController *dictateVC = segue.destinationViewController;
    dictateVC.dataDict = [_dataArray objectAtIndex:indexPath.row];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString *status = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Status"];

    if ([status isEqualToString:@"Dictated"]) {
        
        return YES;
    }
    
    else {
        
        return NO;
    }
    
}


@end
