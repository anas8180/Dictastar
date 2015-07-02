//
//  InformationViewController.m
//  Dictastar
//
//  Created by mohamed on 17/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "InformationViewController.h"
#import "BTServicesClient.h"
#import "CustomTableViewCell.h"

@interface InformationViewController ()

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSDictionary *resultDict;
@property (nonatomic, strong) NSArray *keyDictionary;

@end

@implementation InformationViewController

NSMutableDictionary *infodict;
NSArray *sortArray;

@synthesize dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
//    [self fetchPatientInfo];
    [self fetchPatientInformation];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchPatientInformation
{
     NSDictionary *params = @{@"FacilityId":[_userInfo objectForKey:@"FacilityId"],@"patientID":[dataDict objectForKey:@"PatientID"]};
    
    [[BTServicesClient sharedClient] GET:@"FetchPatientInfoJSONIOS" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSArray *newdataArray =[NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *recipes = [NSArray arrayWithObjects:newdataArray, nil];
        NSArray *arrangeOrder = [[recipes objectAtIndex:0]objectForKey:@"Table"];
        NSLog(@"ArrangeOrder:%@",arrangeOrder);
        
        infodict = [NSMutableDictionary dictionary];
        int i =0;
        
        [infodict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Name"] forKey:@"A"];
        [infodict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"MRNNo"]  forKey:@"B"];
        [infodict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"DOB"]  forKey:@"C"];
        [infodict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Gender"]  forKey:@"D"];
        [infodict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"AddressLine1"]  forKey:@"E"];
        [infodict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Phone"]  forKey:@"F"];
        [infodict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"InsuranceProvider"]  forKey:@"G"];
        
        _keyDictionary = [infodict allKeys];
        sortArray = [_keyDictionary sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSLog(@"KeyDict:%@",_keyDictionary);
        NSLog(@"SortArray:%@",sortArray);
        NSLog(@"Info:%@",infodict);
        
        [self.tableView reloadData];
    }
     failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
          NSLog(@"%@",error.localizedDescription);
         [self.tableView reloadData];
     }];

}

-(NSString *)getLabelText:(NSString *)currentText
{
    NSString *returnText;
    if([currentText  isEqualToString:@"A"])
    {
        returnText = @"Name";
    }
    else if ([currentText isEqualToString:@"B"])
    {
        returnText = @"MRNNo";
    }
    else if ([currentText isEqualToString:@"C"])
    {
        returnText = @"DOB";
    }
    else if ([currentText isEqualToString:@"D"])
    {
        returnText = @"Gender";
    }
    else if ([currentText isEqualToString:@"E"])
    {
        returnText = @"AddressLine1";
    }
    else if ([currentText isEqualToString:@"F"])
    {
        returnText = @"Phone";
    }
    else if ([currentText isEqualToString:@"G"])
    {
        returnText = @"InsuranceProvider";
    }
    return returnText;
}

-(void)fetchPatientInfo {
        
    NSDictionary *params = @{@"FacilityId":[_userInfo objectForKey:@"FacilityId"],@"patientID":[dataDict objectForKey:@"PatientID"]};
    
    [[BTServicesClient sharedClient] GET:@"FetchPatientInfoJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *dataArray = [jsonData objectForKey:@"Table"];
        _resultDict = [dataArray objectAtIndex:0];
        _keyDictionary = [_resultDict allKeys];
        
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
    return _keyDictionary.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {  // Safety check for below iOS 7
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    NSString *titleText = [NSString stringWithFormat:@"%@",[sortArray objectAtIndex:indexPath.row]];
    
    cell.title.text = [NSString stringWithFormat:@"%@ %@",[self getLabelText:titleText],@":"];
    
    cell.subTitle.text = [NSString stringWithFormat:@"%@",[infodict objectForKey:titleText]];
    
    
//    cell.title.text = [NSString stringWithFormat:@"%@ :",[_keyDictionary objectAtIndex:indexPath.row]];
//    cell.subTitle.text = [NSString stringWithFormat:@"%@",[_resultDict objectForKey:[_keyDictionary objectAtIndex:indexPath.row]]];
    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
