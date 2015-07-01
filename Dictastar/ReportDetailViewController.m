//
//  ReportDetailViewController.m
//  Dictastar
//
//  Created by mohamed on 28/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "ReportDetailViewController.h"
#import "BTServicesClient.h"

@interface ReportDetailViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLable;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ReportDetailViewController
@synthesize dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleLable.text = [NSString stringWithFormat:@"%@   %@",[dataDict objectForKey:@"AttendingPhysician"],[dataDict objectForKey:@"ServiceDate"]];

    [self fetchReportDetials];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Service Call

- (void)fetchReportDetials {
    
    NSDictionary *params = @{@"TranscriptionID":[dataDict objectForKey:@"TranscriptionID"]};
    
    [[BTServicesClient sharedClient] GET:@"GetDetailsValueJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        
        NSArray *jsonArray = [jsonData objectForKey:@"Table"];
        
        NSString *jsonString = [[jsonArray objectAtIndex:0] objectForKey:@"DetailValue"];
        
        [self setHtmlLoad:jsonString];

        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
    }];
    
}

#pragma mark - Methods

- (void)setHtmlLoad:(NSString *)htmlString {
    
    [_webView loadHTMLString:htmlString baseURL:nil];
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
