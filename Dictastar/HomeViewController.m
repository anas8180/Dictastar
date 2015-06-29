//
//  HomeViewController.m
//  Dictastar
//
//  Created by mohamed on 16/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "HomeViewController.h"
#import "BTServicesClient.h"
#import "SendQViewController.h"
#import "ReviewViewController.h"
#import "ScheduleViewController.h"
#import "Constant.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController ()

@property (strong, nonatomic) IBOutlet UILabel *doctorName;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topLayout;
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UILabel *alertLable1;
@property (strong, nonatomic) IBOutlet UILabel *alertLable2;
@property (strong, nonatomic) IBOutlet UILabel *alertLable3;
@property (strong, nonatomic) IBOutlet UILabel *alertTitle;
@property (strong, nonatomic) NSDictionary *alertData;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loader;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Home";
    
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
    
    _doctorName.text = [NSString stringWithFormat:@"WELCOME DR. %@",[_userInfo objectForKey:@"DictatorName"]];
    
    if (IS_IPHONE4) {
        _topLayout.constant = 10;

    }
    
    _alertView.layer.cornerRadius = 5;
    _alertView.layer.masksToBounds = YES;
    
    _alertTitle.font = [UIFont boldSystemFontOfSize:16.0f];
    _loadingView.hidden = NO;
    
    [self fetchAlertInfo];
}

//-(void)viewWillAppear:(BOOL)animated {
//    
//    [super viewWillAppear:YES];
//    
//    self.hidesBottomBarWhenPushed = YES;
//    
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Method

-(void)fetchAlertInfo {
    
    NSDictionary *params = @{@"AttendingPhysician":[_userInfo objectForKey:@"DictatorId"]};

    [[BTServicesClient sharedClient] GET:@"GetAlertJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *dataArray = [jsonData objectForKey:@"Table"];
        _alertData = [dataArray objectAtIndex:0];
        [self setAlertDetails];
        
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
    }];
    
}

-(void) setAlertDetails {
    
    _alertLable1.text = [NSString stringWithFormat:@"%@ Files Ready For Approval",[_alertData objectForKey:@"Approved"]];
    _alertLable1.userInteractionEnabled= YES;
    UITapGestureRecognizer *tapLabel1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapaction1)];
    [_alertLable1 addGestureRecognizer:tapLabel1];
    _alertLable2.text = [NSString stringWithFormat:@"%@ Files Waiting For Transcription",[_alertData objectForKey:@"YettoTranscripted"]];
   
    _alertLable2.text = [NSString stringWithFormat:@"0 Files Waiting For Transcription"];
    _alertLable2.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapLabel2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapaction2)];
    [_alertLable2 addGestureRecognizer:tapLabel2];

    _loadingView.hidden = YES;
}

-(void)tapaction1
{
    [self performSegueWithIdentifier:@"ScheduleSegue" sender:self];
}
-(void)tapaction2
{
    [self performSegueWithIdentifier:@"ReviewSegue" sender:self];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"SendQSegue"]) {
        
        SendQViewController *sendQVC = segue.destinationViewController;
        sendQVC.isFromHome = YES;
    }
    else if ([segue.identifier isEqualToString:@"ReviewSegue"]) {
        
        ReviewViewController *reviewVC = segue.destinationViewController;
        reviewVC.isFromHome = YES;
    }
    else if ([segue.identifier isEqualToString:@"ScheduleSegue"]) {
        
        ScheduleViewController *reviewVC = segue.destinationViewController;
        reviewVC.isFromHome = YES;

    }
}


@end
