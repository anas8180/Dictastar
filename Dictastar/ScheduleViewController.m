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

@interface ScheduleViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (strong, nonatomic) IBOutlet UILabel *scheduleDateLable;
@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Schedule";
    
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];

    [self fetchPatientInfo];
    
    _scheduleDateLable.text = [NSString stringWithFormat:@"%@",[self getDate]];
    
//    self.tableView.estimatedRowHeight = 70.0;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;

    
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
    
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.title.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
    cell.subTitle.text = [NSString stringWithFormat:@"%@ %@ %@",[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Gender"],[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"DOB"],[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"ProcedureName"]];
    cell.accessoryLable.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Status"];
    
    return cell;
}

-(void)fetchPatientInfo {
    
    NSString *todayDate = [self getDate];
    
    NSDictionary *params = @{@"FacilityId":[_userInfo objectForKey:@"FacilityId"],@"Fromdate":todayDate,@"Todate":todayDate};
    
    [[BTServicesClient sharedClient] GET:@"FetchPatientJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        _dataArray = [jsonData objectForKey:@"Table"];

        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        NSLog(@"%@",error.localizedDescription);
        
        
    }];

}

-(NSString *)getDate {
    
 /*   NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    NSString *dateString = [dateFormat stringFromDate:today];
    
    return dateString; */
    
    NSString *str = @"2014-04-01"; /// here this is your date with format yyyy-MM-dd
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
    [dateFormatter setDateFormat:@"yyyy-MM-dd"]; //// here set format of date which is in your output date (means above str with format)
    
    NSDate *date = [dateFormatter dateFromString: str]; // here you can fetch date from string with define format
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];// here set format which you want...
    
    NSString *convertedString = [dateFormatter stringFromDate:date]; //here convert date in NSString
    NSLog(@"Converted String : %@",convertedString);
    
    return convertedString;
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
