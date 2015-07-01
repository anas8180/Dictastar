//
//  SendQViewController.m
//  Dictastar
//
//  Created by mohamed on 16/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "SendQViewController.h"
#import "CustomTableViewCell.h"
#import "BTServicesClient.h"
#import "NoDataViewCell.h"
#import "BRRequestUpload.h"
#import "BRRequest+_UserData.h"
#import "UIViewController+ActivityLoader.h"

@interface SendQViewController ()<UITableViewDelegate,UITableViewDataSource,BRRequestDelegate> {
    
    NSData *uploadData;
    BRRequestUpload *uploadFile;

}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *dateLable;
@property (strong, nonatomic) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (strong, nonatomic) NSDate *currentDate;
@property (nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;
@property (strong, nonatomic) NSDictionary *hostDict;

@end

@implementation SendQViewController
@synthesize isFromHome;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Outbox";
        
    _currentDate = [NSDate date];
    
    _selectedIndexPaths = [NSMutableArray new];
    
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
    
    [self getDate];
    [self fetchOutBoxDetails];
    [self fetchFTPDetails];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isFromHome) {
        self.tabBarController.tabBar.hidden=YES;
    }
    else{
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
    else {
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {  // Safety check for below iOS 7
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
    NSString *fileSize = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"FileSize"];
    
        double fileInByte = [fileSize doubleValue];
        double fileSizeInKb = fileInByte/1000;
        
        NSString *kb = [NSString stringWithFormat:@"%.2f",fileSizeInKb];
        
    cell.title.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Filename"];
    cell.subTitle.text = [NSString stringWithFormat:@"%@     %@Kb",[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"UploadDate"],kb];
        
        NSString *status = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"TranscriptionStatus"];
        
        if ([status isEqualToString:@"UNSENT"]) {
            
            cell.statusIcon.hidden = NO;
            cell.selectRadioButton.hidden = NO;
            
        }
        else {
            
            cell.statusIcon.hidden = YES;
            cell.selectRadioButton.hidden = YES;        }
        
        [cell.selectRadioButton addTarget:self action:@selector(selectReport:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectRadioButton.tag = indexPath.row;
        
        if (_selectedIndexPaths.count) {
            
            NSString *str = [NSString stringWithFormat:@"%ld",indexPath.row];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@", str];
            NSArray *filtered = [_selectedIndexPaths filteredArrayUsingPredicate:predicate];
            
            if (filtered.count) {
                [cell.selectRadioButton setImage:[UIImage imageNamed:@"outbox_check"] forState:UIControlStateNormal];
            }
            else {
                [cell.selectRadioButton setImage:[UIImage imageNamed:@"outbox_uncheck"] forState:UIControlStateNormal];
            }
            
        }
        else {
            
            [cell.selectRadioButton setImage:[UIImage imageNamed:@"outbox_uncheck"] forState:UIControlStateNormal];
            
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

-(void)fetchOutBoxDetails {
    
    if (_dataArray !=nil) {
        _dataArray = nil;
        
    }
    
    _dataArray = [[NSArray alloc]init];
    
    [_selectedIndexPaths removeAllObjects];
    
    _isLoading = YES;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    NSString *dateString = [dateFormat stringFromDate:_currentDate];
    
    NSDictionary *params = @{@"facilityID":[_userInfo objectForKey:@"FacilityId"],@"attendingPhysicianID":[_userInfo objectForKey:@"DictatorId"],@"UploadDate":dateString};
    
    [[BTServicesClient sharedClient] GET:@"FetchDictateStatusDetailsinJson" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        _dataArray = [jsonData objectForKey:@"Table"];
        NSLog(@"Upload Id:%@",_dataArray);
        _isLoading = NO;
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        NSLog(@"%@",error.localizedDescription);
        
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

-(void)selectReport:(id)sender {
    
    NSInteger tag = [sender tag];
    
    if (_selectedIndexPaths.count) {
        
        NSString *str = [NSString stringWithFormat:@"%ld",tag];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@", str];
        NSArray *filtered = [_selectedIndexPaths filteredArrayUsingPredicate:predicate];
        
        if (filtered.count) {
            
            NSUInteger indexValue = [_selectedIndexPaths indexOfObject:str];
            [_selectedIndexPaths removeObjectAtIndex:indexValue];
            
        }
        else {
            
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:tag inSection:0];
            
            [_selectedIndexPaths addObject:[NSString stringWithFormat:@"%ld",(long)selectedIndexPath.row]];
            
        }
    }
    else {
        
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:tag inSection:0];
        
        [_selectedIndexPaths addObject:[NSString stringWithFormat:@"%ld",(long)selectedIndexPath.row]];
        
    }
    
    [self.tableView reloadData];
    
}


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
    [self fetchOutBoxDetails];
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
    [self fetchOutBoxDetails];
}

- (IBAction)sendTapped:(id)sender {
    
    if (_selectedIndexPaths.count) {
        
        for (int i=0; i<_selectedIndexPaths.count; i++) {
            
            NSInteger indexVal = [[_selectedIndexPaths objectAtIndex:i] integerValue];
            NSDictionary *dict = @{@"UploadID":[[_dataArray objectAtIndex:indexVal]objectForKey:@"UploadID"]};
           
            [self updateUploadWebService:dict service:@"UpdateFileUploadListinJson"];
            [self uploadFile:[[_dataArray objectAtIndex:indexVal] objectForKey:@"Filename"]];
            
        }
    }
    
}

- (IBAction)deleteTapped:(id)sender {
    
    if (_selectedIndexPaths.count) {
        
        for (int i=0; i<_selectedIndexPaths.count; i++) {
            
            NSInteger indexVal = [[_selectedIndexPaths objectAtIndex:i] integerValue];
            
            NSDictionary *dict = @{@"UploadID":[[_dataArray objectAtIndex:indexVal] objectForKey:@"UploadID"]};
            
            [self callWebService:dict service:@"DeleteFileUploadListinJson"];
        }
    }

}

#pragma mark - Service Methods

- (void)callWebService:(NSDictionary *)params service:(NSString *)service {
    
    [[BTServicesClient sharedClient] POST:service parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        
        [self fetchOutBoxDetails];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        NSLog(@"%@",error.localizedDescription);
        
        [self addMessageLoader:error.localizedDescription];

    }];
    
}

#pragma mark - UpdateUploadFileList inJson

- (void)updateUploadWebService:(NSDictionary *)params service:(NSString *)service
{
    [[BTServicesClient sharedClient] POST:service parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        NSLog(@"%@",error.localizedDescription);
        
    }];

}

- (void) fetchOutBoxAfterUpdate {
    
    
    [self addLoader];
        if (_dataArray !=nil) {
            _dataArray = nil;
            
        }
        
        _dataArray = [[NSArray alloc]init];
        
        [_selectedIndexPaths removeAllObjects];
        
    
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        
        NSString *dateString = [dateFormat stringFromDate:_currentDate];
        
        NSDictionary *params = @{@"facilityID":[_userInfo objectForKey:@"FacilityId"],@"attendingPhysicianID":[_userInfo objectForKey:@"DictatorId"],@"UploadDate":dateString};
        
        [[BTServicesClient sharedClient] GET:@"FetchDictateStatusDetailsinJson" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
            
            NSError* error;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
            _dataArray = [jsonData objectForKey:@"Table"];
            
            [self.tableView reloadData];
            
            [self hideHud];
            
        } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
            //Failure of service call....
            
            NSLog(@"%@",error.localizedDescription);
            
            [self hideHud];

        }];
    
}


#pragma mark - Uplaod FTP on Server

- (void)uploadFile:(NSString *)fileName
{
    
    [self addLoader];
    
    //----- get the file to upload as an NSData object
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               fileName,
                               nil];
    
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    uploadData = [NSData dataWithContentsOfURL:outputFileURL];
    
    uploadFile = [[BRRequestUpload alloc] initWithDelegate:self];
    
    uploadFile.path = [NSString stringWithFormat:@"/%@/%@",[_userInfo objectForKey:@"FacilityId"],fileName];
//    uploadFile.hostname = [_hostDict objectForKey:@"HOST"];
    uploadFile.hostname = @"192.168.1.7";
    uploadFile.username = [_hostDict objectForKey:@"UN"];
    uploadFile.password = [_hostDict objectForKey:@"PWD"];
    
    [uploadFile start];
}

-(BOOL) shouldOverwriteFileWithRequest: (BRRequest *) request
{
    //----- set this as appropriate if you want the file to be overwritten
    if (request == uploadFile)
    {
        //----- if uploading a file, we set it to YES
        return YES;
    }
    
    //----- anything else (directories, etc) we set to NO
    return NO;
}

-(void) requestCompleted: (BRRequest *) request
{
    [self hideHud];
    NSLog(@"Completed:%@ completed!", request);
    uploadFile = nil;
    [self fetchOutBoxAfterUpdate];
}

- (NSData *) requestDataToSend: (BRRequestUpload *) request
{
    //----- returns data object or nil when complete
    //----- basically, first time we return the pointer to the NSData.
    //----- and BR will upload the data.
    //----- Second time we return nil which means no more data to send
    NSData *temp = uploadData;                                                  // this is a shallow copy of the pointer, not a deep copy
    
    uploadData = nil;                                                           // next time around, return nil...
    
    return temp;
}

-(void) requestFailed:(BRRequest *) request
{
    [self hideHud];

    NSLog(@"Failed:%@", request.error.message);
    
    uploadFile = nil;
    
    [self fetchOutBoxAfterUpdate];

}

#pragma mark - Service Call

-(void)fetchFTPDetails {
    
    [[BTServicesClient sharedClient] GET:@"GetFTPDetailsJSON" parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *data  = [jsonData objectForKey:@"Table"];
        _hostDict = [data objectAtIndex:0];
        
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        NSLog(@"%@",error.localizedDescription);
        [self hideHud];
        
    }];
    
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
