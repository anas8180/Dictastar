//
//  ReportViewController.m
//  Dictastar
//
//  Created by mohamed on 17/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "ReportViewController.h"
#import "BTServicesClient.h"
#import "CustomTableViewCell.h"

@interface ReportViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *user_info;

@end

@implementation ReportViewController
@synthesize dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _user_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
    [self fetchPatientInfo];

    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchPatientInfo {
    
    NSDictionary *params = @{@"AttendingPhysician":[_user_info objectForKey:@"DictatorId"],@"patientID":[dataDict objectForKey:@"PatientID"]};
    
    [[BTServicesClient sharedClient] GET:@"GetTranscriptionIDbyAttendingPhysicianforSignedJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        _dataArray  = [jsonData objectForKey:@"Table"];
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        NSLog(@"%@",error.localizedDescription);
        
        
    }];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.title.text = [NSString stringWithFormat:@"%@",[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"PatientName"]];
    
    cell.subTitle.text = [NSString stringWithFormat:@"%@",[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"ServiceDate"]];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
