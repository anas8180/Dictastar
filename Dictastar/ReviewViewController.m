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
#import "BTActionService.h"

@interface ReviewViewController ()<UITableViewDelegate,UITableViewDataSource> {
    
    BOOL isSelectedAll,isSelectedSingle;
    NSDictionary *jobDict;
}

@property (strong, nonatomic) IBOutlet UILabel *dateLable;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;
@property (nonatomic) BOOL isLoading;

@end

@implementation ReviewViewController
@synthesize isFromHome;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectedIndexPaths = [NSMutableArray new];
    
    self.title = @"Review";
    
    _currentDate = [NSDate date];

    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
    
    [self fetchPatientInfo];
    
    isSelectedAll = NO;
    isSelectedSingle = NO;
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
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
    cell.subTitle.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"DocumentFlag"];
    cell.statusLable.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"DOB"];
    
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

#pragma mark - Methods

-(void)fetchPatientInfo {
    
    _isLoading = YES;

    NSDictionary *params = @{@"AttendingPhysician":[_userInfo objectForKey:@"DictatorId"]};
    
    [[BTServicesClient sharedClient] GET:@"GetTranscriptionIDbyAttendingPhysicianJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        _dataArray = [jsonData objectForKey:@"Table"];
        NSLog(@"%@",_dataArray);
        _isLoading = NO;
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        _isLoading = NO;
        
        [self.tableView reloadData];

    }];
    
}

#pragma mark - Button Action

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
- (IBAction)selectAllReport:(id)sender {
    
    if (isSelectedAll) {
        
        [_selectedIndexPaths removeAllObjects];

        [sender setImage:[UIImage imageNamed:@"outbox_uncheck"] forState:UIControlStateNormal];
        
        [self.tableView reloadData];

        isSelectedAll = NO;
    }
    else {
    [_selectedIndexPaths removeAllObjects];
    
    for (int i=0; i<_dataArray.count; i++) {
        
        [_selectedIndexPaths addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    [sender setImage:[UIImage imageNamed:@"outbox_check"] forState:UIControlStateNormal];
    
    [self.tableView reloadData];
        
        isSelectedAll = YES;
    }
}
- (IBAction)signTapped:(id)sender {
    
    if (_selectedIndexPaths.count) {
        
            NSMutableArray *transIdArray = [NSMutableArray new];
            
            for (int i=0; i<_selectedIndexPaths.count; i++) {
                
                NSInteger indexVal = [[_selectedIndexPaths objectAtIndex:i] integerValue];
                
                NSString *transId = [[_dataArray objectAtIndex:indexVal] objectForKey:@"TranscriptionID"];
                
                [transIdArray addObject:transId];


            }
            
            NSString *transIsStr = [transIdArray componentsJoinedByString:@","];
            
            NSDictionary *params = @{@"TranscriptionID":transIsStr,@"Facilityid":[_userInfo objectForKey:@"FacilityId"]};
            [self callWebService:params service:@"GetMultipleJobDetailsJSON"];
        
    }
}

- (IBAction)deleteTappe:(id)sender {
    
    if (_selectedIndexPaths.count) {
        
        NSMutableArray *transIdArray = [NSMutableArray new];
        
        for (int i=0; i<_selectedIndexPaths.count; i++) {
            
            NSInteger indexVal = [[_selectedIndexPaths objectAtIndex:i] integerValue];
            
            NSString *transId = [[_dataArray objectAtIndex:indexVal] objectForKey:@"TranscriptionID"];
            
            [transIdArray addObject:transId];
            
            
        }
        
        NSString *transIsStr = [transIdArray componentsJoinedByString:@","];
        
        NSDictionary *params = @{@"TranscriptionID":transIsStr};
        [self callWebService:params service:@"GetMultipleDeleteReviewJSON"];
        
    }

}

#pragma mark - Service Methods

- (void)callWebService:(NSDictionary *)params service:(NSString *)service {
    
    [[BTServicesClient sharedClient] GET:service parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        NSLog(@"%@",error.localizedDescription);
    }];
    
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
