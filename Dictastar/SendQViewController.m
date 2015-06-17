//
//  SendQViewController.m
//  Dictastar
//
//  Created by mohamed on 16/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "SendQViewController.h"
#import "CustomTableViewCell.h"

@interface SendQViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *dateLable;

@end

@implementation SendQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Send Q";
    
    _dateLable.text = [NSString stringWithFormat:@"%@",[self getDate]];
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
    
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
//    cell.title.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
//    cell.subTitle.text = [NSString stringWithFormat:@"%@ %@ %@",[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Gender"],[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"DOB"],[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"ProcedureName"]];
//    cell.accessoryLable.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Status"];
    
    return cell;
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
}
- (IBAction)forwardAction:(id)sender {
}

#pragma mark - Methods

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
