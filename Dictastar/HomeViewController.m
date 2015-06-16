//
//  HomeViewController.m
//  Dictastar
//
//  Created by mohamed on 16/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "HomeViewController.h"
#import "BTServicesClient.h"

@interface HomeViewController ()

@property (strong, nonatomic) IBOutlet UILabel *doctorName;
@property (nonatomic, strong) NSDictionary *userInfo;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Home";
    
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
    NSLog(@"%@",_userInfo);
    
    _doctorName.text = [NSString stringWithFormat:@"WELCOME DR. %@",[_userInfo objectForKey:@"DictatorName"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)getAlert:(id)sender {
    
    NSDictionary *params = @{@"AttendingPhysician":[_userInfo objectForKey:@"DictatorId"]};
    
    [[BTServicesClient sharedClient] GET:@"GetAlertJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *jsonArray = [jsonData objectForKey:@"Table"];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        NSLog(@"%@",error.localizedDescription);
        
        
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
