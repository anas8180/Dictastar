//
//  ReportTypeViewController.m
//  Dictastar
//
//  Created by mohamed on 26/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "ReportTypeViewController.h"
#import "BTServicesClient.h"
#import "NoDataViewCell.h"
#import "CustomTableViewCell.h"
#import "DictateViewController.h"

@interface ReportTypeViewController ()<UITableViewDataSource,UITableViewDelegate> {
    
    NSIndexPath *selectedIndexPath;
    
}

@property (nonatomic, strong) NSArray *dataArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSDictionary *userInfo;


@end

@implementation ReportTypeViewController
@synthesize dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
    NSLog(@"%@",dataDict);
    [self fetchDictateTypeInfo];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Method

-(void)fetchDictateTypeInfo {
    
    _isLoading = YES;

    NSDictionary *params = @{@"Facilityuserid":[_userInfo objectForKey:@"DictatorId"]};
    
    [[BTServicesClient sharedClient] GET:@"GetDictateTypeinJson" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        _dataArray = [jsonDict objectForKey:@"Table"];
        NSLog(@"%@",_dataArray);
        
        _isLoading = NO;
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        NSLog(@"%@",error.localizedDescription);
        
        _isLoading = NO;
        
        [self.tableView reloadData];
        
    }];
    
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
    
    return 50.0;
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
    else  {
        CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        cell.title.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"Type"];
        
        [cell.selectRadioButton addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectRadioButton.tag = indexPath.row;
        
        if (indexPath == selectedIndexPath) {
            [cell.selectRadioButton setImage:[UIImage imageNamed:@"radio_on"] forState:UIControlStateNormal];
            cell.title.textColor = [UIColor colorWithRed:35/255.0 green:122/255.0 blue:190/255.0 alpha:1.0];
;
        }
        else {
            [cell.selectRadioButton setImage:[UIImage imageNamed:@"radio_off"] forState:UIControlStateNormal];
            cell.title.textColor = [UIColor blackColor];

        }
        
        return cell;
    }
}


#pragma mark - Button Action

-(void)selectType:(id)sender {
    
    NSInteger tag = [sender tag];
    
    selectedIndexPath = [NSIndexPath indexPathForRow:tag inSection:0];

    [self.tableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    

    DictateViewController *dictateObj = segue.destinationViewController;
    dictateObj.dataDict = dataDict;
    dictateObj.jobType = [[_dataArray objectAtIndex:selectedIndexPath.row] objectForKey:@"Tid"];
    
}


@end