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
        
        if ([[_keyDictionary objectAtIndex:indexPath.row] isEqualToString:@"FacilityUserID"] || [[_keyDictionary objectAtIndex:indexPath.row] isEqualToString:@"Title"] || [[_keyDictionary objectAtIndex:indexPath.row] isEqualToString:@"FirstName"] || [[_keyDictionary objectAtIndex:indexPath.row] isEqualToString:@"LastName"]) {
            
            cell.valueText.enabled = NO;
        }
        
        cell.title.text = [NSString stringWithFormat:@"%@ :",[_keyDictionary objectAtIndex:indexPath.row]];
        
        cell.valueText.text = [NSString stringWithFormat:@"%@",[_resultDict objectForKey:[_keyDictionary objectAtIndex:indexPath.row]]];
        
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
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *dataArray = [jsonData objectForKey:@"Table"];
        _resultDict = [dataArray objectAtIndex:0];
        _keyDictionary = [_resultDict allKeys];
        
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
