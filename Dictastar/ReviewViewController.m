//
//  ReviewViewController.m
//  Dictastar
//
//  Created by mohamed on 16/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "ReviewViewController.h"
#import "CustomTableViewCell.h"
#import "BTServicesClient.h"
#import "ReviewDetailViewController.h"
#import "NoDataViewCell.h"

@interface ReviewViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *dateLable;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (strong, nonatomic) NSDate *currentDate;
@property (nonatomic) BOOL isLoading;

@end

@implementation ReviewViewController
@synthesize isFromHome;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Review";
    
    _currentDate = [NSDate date];

    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
    
    [self fetchPatientInfo];
    [self getDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isFromHome) {
        self.tabBarController.tabBar.hidden=YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (isFromHome) {
        self.tabBarController.tabBar.hidden=NO;
    }
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
    else {
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.title.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"PatientName"];
//    cell.subTitle.text = [NSString stringWithFormat:@"%@ %@ %@",[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Gender"],[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"DOB"],[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"ProcedureName"]];
    
    return cell;
    }
}

#pragma mark - Methods

-(void)fetchPatientInfo {
    
    _isLoading = YES;

    NSDictionary *params = @{@"AttendingPhysician":[_userInfo objectForKey:@"DictatorId"]};
    
    [[BTServicesClient sharedClient] GET:@"GetTranscriptionIDbyAttendingPhysicianJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
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
    
    _dateLable.text = [NSString stringWithFormat:@"%@",dateString];
    
    /*  NSString *str = @"2014-04-01"; /// here this is your date with format yyyy-MM-dd
     
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
     [dateFormatter setDateFormat:@"yyyy-MM-dd"]; //// here set format of date which is in your output date (means above str with format)
     
     NSDate *date = [dateFormatter dateFromString: str]; // here you can fetch date from string with define format
     
     dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"MM/dd/yyyy"];// here set format which you want...
     
     NSString *convertedString = [dateFormatter stringFromDate:date]; //here convert date in NSString
     NSLog(@"Converted String : %@",convertedString);
     
     return convertedString; */
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
    [self.tableView reloadData];
    [self fetchPatientInfo];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    ReviewDetailViewController *reviewDetailVC = segue.destinationViewController;
    NSDictionary *dict = [_dataArray objectAtIndex:indexPath.row];
    reviewDetailVC.dataDict = dict;
    
}


@end
