//
//  ReviewDetailViewController.m
//  Dictastar
//
//  Created by mohamed on 17/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "ReviewDetailViewController.h"
#import "BTServicesClient.h"
#import "BTActionService.h"
#import "UIViewController+ActivityLoader.h"

@interface ReviewDetailViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *titleLable;
@property (strong, nonatomic) NSDictionary *jobDict;
@property (strong, nonatomic) NSDictionary *user_info;

@end

@implementation ReviewDetailViewController
@synthesize dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self fetchDetail];
    
    
    _titleLable.text = [NSString stringWithFormat:@"%@   %@",[dataDict objectForKey:@"PatientName"],[dataDict objectForKey:@"ServiceDate"]];
    
    _user_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
    
    [self fetchJobDetials];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.tabBarController.tabBar.hidden=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)fetchDetail {
    
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


- (void)setHtmlLoad:(NSString *)htmlString {
    
    NSString *loadHtml = [NSString stringWithFormat:@"<html> <script type='text/javascript'> document.addEventListener('touchend', function(e) { var touch = e.changedTouches.item(0); var touchX = touch.clientX; var touchY = touch.clientY; var contentDIVRect = document.getElementById('content').getClientRects()[0]; if (touchX > contentDIVRect.left && touchY < contentDIVRect.bottom) { return; } document.getElementById('content').focus(); }, false); function moveImageAtTo(x, y, newX, newY) { var element  = document.elementFromPoint(x, y); if (element.toString().indexOf('Image') == -1) { return; }var caretRange = document.caretRangeFromPoint(newX, newY); var selection = window.getSelection(); var imageSrc = element.src; var nodeRange = document.createRange(); nodeRange.selectNode(element); selection.removeAllRanges(); selection.addRange(nodeRange); document.execCommand('delete'); var selection = window.getSelection(); var range = document.createRange(); selection.removeAllRanges(); selection.addRange(caretRange); document.execCommand('insertImage', false, imageSrc); } </script> <body> <div id='content' contenteditable='true' style='font-family: Helvetica'>%@</div> </body> </html>",htmlString];
    
    [_webView loadHTMLString:loadHtml baseURL:nil];

}

-(NSString *)cutStringDate:(NSString *)dateString
{
    // cut the String
    NSRange range = [dateString rangeOfString:@"T"];
    NSString *newString = [dateString substringWithRange:NSMakeRange(0, range.location)];
    
    // chanage the Date Format
    NSDateFormatter *oldFormatter = [[NSDateFormatter alloc] init];
    [oldFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *theDate= [oldFormatter dateFromString:newString];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc]init];
    [newFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *cutDate = [NSString stringWithFormat:@"%@",[newFormatter stringFromDate:theDate]];
    
    cutDate = [cutDate stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    
    return cutDate;
    
}

#pragma mark - Action

- (IBAction)saveTapped:(id)sender {
    
    NSString *webHTMLSourceCodeString = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    NSDictionary *params = @{@"TranscriptionID":[dataDict objectForKey:@"TranscriptionID"],@"Content":webHTMLSourceCodeString};
    
    [self callWebService:params service:@"SaveRecord"];

}
- (IBAction)signTapped:(id)sender {
    
    NSString *webHTMLSourceCodeString = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];

    NSDictionary *params = @{@"TranscriptionID":[dataDict objectForKey:@"TranscriptionID"],@"ReviewState":@"Signed",@"_Content":webHTMLSourceCodeString,@"jobid":[_jobDict objectForKey:@"JobID"],@"PDFModule":[_jobDict objectForKey:@"PDFModule"],@"FacilityId":[_user_info objectForKey:@"FacilityId"],@"FileNames":[_jobDict objectForKey:@"ReportName"]};
    
    [self callWebService:params service:@"SignRecordWS"];

    
}
- (IBAction)deleteTapped:(id)sender {
        
    NSDictionary *params = @{@"TranscriptionID":[dataDict objectForKey:@"TranscriptionID"],@"Status":@"Deleted"};

    [self callWebService:params service:@"DeleteRecord"];
}

#pragma mark - Service Methods

- (void)callWebService:(NSDictionary *)params service:(NSString *)service {
    
    [[BTActionService sharedClient] GET:service parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        
        [self addMessageLoader:@"Success"];
        
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        NSLog(@"%@",error.localizedDescription);
    }];

}

- (void)fetchJobDetials {
    
    NSDictionary *params = @{@"TranscriptionID":[dataDict objectForKey:@"TranscriptionID"]};
    
    [[BTServicesClient sharedClient] GET:@"GetJobDetailsJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *data = [jsonData objectForKey:@"Table"];
        _jobDict = [data objectAtIndex:0];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
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
