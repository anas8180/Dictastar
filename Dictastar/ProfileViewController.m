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
#import "Constant.h"
#import "UIViewController+ActivityLoader.h"

@interface ProfileViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    
    NSString *email,*username,*pswd;
    NSString *facilityId,*title,*fname,*lname;
    NSString *address,*city,*zipCode,*state,*country;
    NSString *phone,*fax;
    
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) NSDictionary *resultDict;

@property (nonatomic, strong) NSArray *keyDictionary;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topLayout;

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
        
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {  // Safety check for below iOS 7
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        cell.valueText.delegate = self;
        
        cell.valueText.tag = indexPath.row;
        
        if ([[sortedArray objectAtIndex:indexPath.row] isEqualToString:@"A"] || [[sortedArray objectAtIndex:indexPath.row] isEqualToString:@"B"] || [[sortedArray objectAtIndex:indexPath.row] isEqualToString:@"C"] || [[sortedArray objectAtIndex:indexPath.row] isEqualToString:@"D"]) {
            
            cell.valueText.enabled = NO;
        }
        else {
            
            cell.valueText.enabled = YES;
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
        
        facilityId = [[arrangeOrder objectAtIndex:i]objectForKey:@"FacilityUserID"];
        title = [[arrangeOrder objectAtIndex:i]objectForKey:@"Title"];
        fname = [[arrangeOrder objectAtIndex:i]objectForKey:@"FirstName"];
        lname = [[arrangeOrder objectAtIndex:i]objectForKey:@"LastName"];

        address = [[arrangeOrder objectAtIndex:i]objectForKey:@"AddressLine1"];
        city = [[arrangeOrder objectAtIndex:i]objectForKey:@"City"];
        zipCode = [[arrangeOrder objectAtIndex:i]objectForKey:@"Zipcode"];
        state = [[arrangeOrder objectAtIndex:i]objectForKey:@"State"];
        country = [[arrangeOrder objectAtIndex:i]objectForKey:@"Country"];
        
        phone = [[arrangeOrder objectAtIndex:i]objectForKey:@"Phone"];
        fax = [[arrangeOrder objectAtIndex:i]objectForKey:@"Fax"];

        email = [[arrangeOrder objectAtIndex:i]objectForKey:@"Email"];
        username = [[arrangeOrder objectAtIndex:i]objectForKey:@"Username"];
        pswd = [[arrangeOrder objectAtIndex:i]objectForKey:@"Password"];

        
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
    
    
    NSDictionary *params = @{@"facilityUserID":facilityId,@"title":title,@"firstName":fname,@"lastName":lname,@"AddressLine1":address,@"city":city,@"zipcode":zipCode,@"state":state,@"country":country,@"phone":phone,@"fax":fax,@"email":email,@"Username":username,@"password":pswd};
    
    [[BTServicesClient sharedClient] POST:@"UpdateFacilityUserInfo" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        [self addMessageLoader:@"Success"];
        
        [self dismissViewControllerAnimated:YES completion:nil];

        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        [self addMessageLoader:error.localizedDescription];

    }];

}

#pragma mark - TextField Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSLog(@"%@",textField.text);
    
    
    
    if (textField.tag == 0) {
        facilityId = textField.text;
    }
    else if (textField.tag == 1) {
        
        title = textField.text;
    }
    else if (textField.tag == 2) {
        
        fname = textField.text;
    }
    else if (textField.tag == 3) {
        
        lname = textField.text;
    }
    else if (textField.tag == 4) {
        
        address = textField.text;
    }
    else if (textField.tag == 5) {
        
        city = textField.text;
    }
    else if (textField.tag == 6) {
        
        zipCode = textField.text;
    }

    else if (textField.tag == 7) {
        
        state = textField.text;
    }
    else if (textField.tag == 8) {
        
        country = textField.text;
    }
    else if (textField.tag == 9) {
        
        phone = textField.text;
    }
    else if (textField.tag == 10) {
        
        fax = textField.text;
    }
    else if (textField.tag == 11) {
        
        email = textField.text;
    }
    else if (textField.tag == 12) {
        
        username = textField.text;
    }
    else if (textField.tag == 13) {
        
        pswd = textField.text;
    }



    _topLayout.constant = 0;
    
    [self moveViewUpAndDown];

    return [textField resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == 0) {
        facilityId = textField.text;
    }
    else if (textField.tag == 1) {
        
        title = textField.text;
    }
    else if (textField.tag == 2) {
        
        fname = textField.text;
    }
    else if (textField.tag == 3) {
        
        lname = textField.text;
    }
    else if (textField.tag == 4) {
        
        address = textField.text;
    }
    else if (textField.tag == 5) {
        
        city = textField.text;
    }
    else if (textField.tag == 6) {
        
        zipCode = textField.text;
    }
    
    else if (textField.tag == 7) {
        
        state = textField.text;
    }
    else if (textField.tag == 8) {
        
        country = textField.text;
    }
    else if (textField.tag == 9) {
        
        phone = textField.text;
    }
    else if (textField.tag == 10) {
        
        fax = textField.text;
    }
    else if (textField.tag == 11) {
        
        email = textField.text;
    }
    else if (textField.tag == 12) {
        
        username = textField.text;
    }
    else if (textField.tag == 13) {
        
        pswd = textField.text;
    }

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    NSLog(@"%@",textField.text);
    
    if (IS_IPHONE4) {
       
        if (textField.tag == 10 || textField.tag == 11) {
            _topLayout.constant = -500;
        }
        
        else if (textField.tag == 12 || textField.tag == 13) {
            
            _topLayout.constant = - 600;
        }

    }
    else if (IS_IPHONE5) {
        
        if (textField.tag == 10 || textField.tag == 11 ||textField.tag == 12 || textField.tag == 13) {
            _topLayout.constant = -500;
        }
        
    }
    else if (IS_IPHONE6) {
        
        if (textField.tag == 10 || textField.tag == 11 ||textField.tag == 12 || textField.tag == 13) {
            _topLayout.constant = -400;
        }

    }
    else if (IS_IPHONE6PLUS) {
       
        if (textField.tag == 10 || textField.tag == 11 ||textField.tag == 12 || textField.tag == 13) {
            _topLayout.constant = -350;
        }

    }
    [self moveViewUpAndDown];
    
    if (textField.tag == 0) {
        facilityId = textField.text;
    }
    else if (textField.tag == 1) {
        
        title = textField.text;
    }
    else if (textField.tag == 2) {
        
        fname = textField.text;
    }
    else if (textField.tag == 3) {
        
        lname = textField.text;
    }
    else if (textField.tag == 4) {
        
        address = textField.text;
    }
    else if (textField.tag == 5) {
        
        city = textField.text;
    }
    else if (textField.tag == 6) {
        
        zipCode = textField.text;
    }
    
    else if (textField.tag == 7) {
        
        state = textField.text;
    }
    else if (textField.tag == 8) {
        
        country = textField.text;
    }
    else if (textField.tag == 9) {
        
        phone = textField.text;
    }
    else if (textField.tag == 10) {
        
        fax = textField.text;
    }
    else if (textField.tag == 11) {
        
        email = textField.text;
    }
    else if (textField.tag == 12) {
        
        username = textField.text;
    }
    else if (textField.tag == 13) {
        
        pswd = textField.text;
    }


    return YES;
}

- (void)moveViewUpAndDown{
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
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
