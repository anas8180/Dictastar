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
#import "UIViewController+ActivityLoader.h"

@interface ReportTypeViewController ()<UITableViewDataSource,UITableViewDelegate> {
    
    NSIndexPath *selectedIndexPath;
    
}

@property (nonatomic, strong) NSArray *dataArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSDictionary *defaultTypeDict;

@end

@implementation ReportTypeViewController
@synthesize dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];

    [self fetchDictateTypeInfo];
    [self fetchDefaultType];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    selectedIndexPath = nil;
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
        
        _isLoading = NO;
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        _isLoading = NO;
        
        [self.tableView reloadData];
        
    }];
    
}

-(void) fetchDefaultType {
    
    NSDictionary *params = @{@"Facilityuserid":[_userInfo objectForKey:@"DictatorId"]};
    
    [[BTServicesClient sharedClient] GET:@"GetDictateTypeinJson" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *data = [jsonDict objectForKey:@"Table"];
        _defaultTypeDict = [data objectAtIndex:0];
        
        NSArray *filteredArray = [_dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"Dictateid = %@",[_defaultTypeDict objectForKey:@"Dictateid"]]]];
        
        NSInteger indexVal = [_dataArray indexOfObject:[filteredArray objectAtIndex:0]];
        
        selectedIndexPath = [NSIndexPath indexPathForRow:indexVal inSection:0];
        
        [self.tableView reloadData];

        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
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
        
        if (indexPath.row == selectedIndexPath.row) {
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
- (IBAction)makeDefault:(id)sender {
    
    
    NSDictionary *params = @{@"Tid":[[_dataArray objectAtIndex:selectedIndexPath.row] objectForKey:@"Tid"],@"Dictateid":[[_dataArray objectAtIndex:selectedIndexPath.row] objectForKey:@"Dictateid"]};
    
    [[BTServicesClient sharedClient] GET:@"UpdateDefaultDictateTypeinJson" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *data = [jsonDict objectForKey:@"Table"];
        [self addMessageLoader:@"Success"];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        
    }];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    

    DictateViewController *dictateObj = segue.destinationViewController;
    dictateObj.dataDict = dataDict;
    dictateObj.jobTypeDict = [_dataArray objectAtIndex:selectedIndexPath.row];
    
}


@end
