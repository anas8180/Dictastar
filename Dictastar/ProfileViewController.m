//
//  ProfileViewController.m
//  Dictastar
//
//  Created by mohamed on 28/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileTableViewCell.h"
#import "BTServicesClient.h"

@interface ProfileViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) NSDictionary *resultDict;

@property (nonatomic, strong) NSArray *keyDictionary;

@end

@implementation ProfileViewController

NSMutableDictionary *dict;
NSArray *sortedArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];

    [self fetchPatientInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else {
    return _keyDictionary.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopCell" forIndexPath:indexPath];
        
        // Configure the cell...
        
        return cell;
        
    }
    
    else {
        
        ProfileTableViewCell *cell = (ProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
        
        cell.valueText.delegate = self;
        
        if ([[sortedArray objectAtIndex:indexPath.row] isEqualToString:@"A"] || [[sortedArray objectAtIndex:indexPath.row] isEqualToString:@"B"] || [[sortedArray objectAtIndex:indexPath.row] isEqualToString:@"C"] || [[sortedArray objectAtIndex:indexPath.row] isEqualToString:@"D"]) {
            
            cell.valueText.enabled = NO;
        }
        NSString *titleText = [NSString stringWithFormat:@"%@",[sortedArray objectAtIndex:indexPath.row]];
        
        cell.title.text = [self getLabelText:titleText];
        
        cell.valueText.text = [NSString stringWithFormat:@"%@",[dict objectForKey:titleText]];
        
        return cell;

    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 100.0;
    }
    else {
        
        return 50.0;
    }
}




#pragma mark - Methods

-(void)fetchPatientInfo {
    
    NSDictionary *params = @{@"facilityUserID":[_userInfo objectForKey:@"DictatorId"]};
    
    [[BTServicesClient sharedClient] GET:@"FetchFacilityUserInfoJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
//        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
//        NSArray *dataArray = [jsonData objectForKey:@"Table"];
//        _resultDict = [dataArray objectAtIndex:0];
        
        NSArray *newdataArray =[NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        
        NSArray *recipes = [NSArray arrayWithObjects:newdataArray, nil];
        NSArray *arrangeOrder = [[recipes objectAtIndex:0]objectForKey:@"Table"];

        
       
        
        dict = [NSMutableDictionary dictionary];
        int i =0;
        
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"FacilityUserID"] forKey:@"A"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Title"]  forKey:@"B"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"FirstName"]  forKey:@"C"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"LastName"]  forKey:@"D"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"AddressLine1"]  forKey:@"E"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"City"]  forKey:@"F"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Zipcode"]  forKey:@"G"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"State"]  forKey:@"H"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Country"]  forKey:@"I"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Phone"]  forKey:@"J"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Fax"]  forKey:@"K"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Email"]  forKey:@"L"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Username"]  forKey:@"M"];
        [dict setObject:[[arrangeOrder objectAtIndex:i]objectForKey:@"Password"]  forKey:@"N"];
        
        
        _keyDictionary = [dict allKeys];
//         NSLog(@"Keys:%@",_keyDictionary);
        sortedArray = [_keyDictionary sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//        NSLog(@"SortedArray:%@",sortedArray);
        

        
//        _keyDictionary =[_resultDict allKeys];
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        [self.tableView reloadData];
        
    }];
    
}

- (IBAction)cancelTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)OkTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - TextField Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

#pragma Return Text Arugument From Json

-(NSString *)getLabelText:(NSString *)currentText
{
    NSString *returnText;
    if([currentText  isEqualToString:@"A"])
    {
        returnText = @"FacilityUserId";
    }
    else if ([currentText isEqualToString:@"B"])
    {
        returnText = @"Title";
    }
    else if ([currentText isEqualToString:@"C"])
    {
        returnText = @"FirstName";
    }
    else if ([currentText isEqualToString:@"D"])
    {
        returnText = @"LastName";
    }
    else if ([currentText isEqualToString:@"E"])
    {
        returnText = @"AddressLine1";
    }
    else if ([currentText isEqualToString:@"F"])
    {
        returnText = @"City";
    }
    else if ([currentText isEqualToString:@"G"])
    {
        returnText = @"Zipcode";
    }
    else if ([currentText isEqualToString:@"H"])
    {
        returnText = @"State";
    }
    else if ([currentText isEqualToString:@"I"])
    {
        returnText = @"Country";
    }
    else if ([currentText isEqualToString:@"J"])
    {
        returnText = @"Phone";
    }
    else if ([currentText isEqualToString:@"K"])
    {
        returnText = @"Fax";
    }
    else if ([currentText isEqualToString:@"L"])
    {
        returnText = @"Email";
    }
    else if ([currentText isEqualToString:@"M"])
    {
        returnText = @"Username";
    }
    else if ([currentText isEqualToString:@"N"])
    {
        returnText = @"Password";
    }
    return returnText;
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
