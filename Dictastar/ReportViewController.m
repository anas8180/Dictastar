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
#import "ReportDetailViewController.h"
#import "NoDataViewCell.h"
#import "ReportPageViewController.h"

@interface ReportViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *user_info;
@property (nonatomic) BOOL isLoading;

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
    
    _isLoading = YES;

    NSDictionary *params = @{@"AttendingPhysician":[_user_info objectForKey:@"DictatorId"],@"patientID":[dataDict objectForKey:@"PatientID"]};
    
    [[BTServicesClient sharedClient] GET:@"GetTranscriptionIDbyAttendingPhysicianforSignedJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        _dataArray  = [jsonData objectForKey:@"Table"];
        
        _isLoading = NO;

        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        _isLoading = NO;
        
        [self.tableView reloadData];

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    
    // Configure the cell...
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {  // Safety check for below iOS 7
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    cell.title.text = [NSString stringWithFormat:@"%@",[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"AttendingPhysician"]];
    
    cell.statusLable.text = [NSString stringWithFormat:@"%@",[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"ServiceDate"]];
    
    cell.subTitle.text = [NSString stringWithFormat:@"%@",[[_dataArray objectAtIndex:indexPath.row]objectForKey:@"TypeOfDictation"]];
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    ReportPageViewController *reportObj = segue.destinationViewController;
    reportObj.dataArray = _dataArray;
    reportObj.selectedIndex = indexPath.row;
}


@end
