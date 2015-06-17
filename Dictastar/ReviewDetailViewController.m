//
//  ReviewDetailViewController.m
//  Dictastar
//
//  Created by mohamed on 17/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "ReviewDetailViewController.h"
#import "BTServicesClient.h"

@interface ReviewDetailViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *titleLable;

@end

@implementation ReviewDetailViewController
@synthesize dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self fetchDetail];
    
    _titleLable.text = [NSString stringWithFormat:@"%@ %@",[dataDict objectForKey:@"PatientName"],[dataDict objectForKey:@"ServiceDate"]];
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
        NSLog(@"%@",jsonData);
        
        NSArray *jsonArray = [jsonData objectForKey:@"Table"];
        
        NSString *jsonString = [[jsonArray objectAtIndex:0] objectForKey:@"DetailValue"];
        
        NSLog(@"%@",jsonString);
        
        [self setHtmlLoad:jsonString];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
    }];

}


- (void)setHtmlLoad:(NSString *)htmlString {
    
    NSString *loadHtml = [NSString stringWithFormat:@"<html> <script type='text/javascript'> document.addEventListener('touchend', function(e) { var touch = e.changedTouches.item(0); var touchX = touch.clientX; var touchY = touch.clientY; var contentDIVRect = document.getElementById('content').getClientRects()[0]; if (touchX > contentDIVRect.left && touchY < contentDIVRect.bottom) { return; } document.getElementById('content').focus(); }, false); function moveImageAtTo(x, y, newX, newY) { var element  = document.elementFromPoint(x, y); if (element.toString().indexOf('Image') == -1) { return; }var caretRange = document.caretRangeFromPoint(newX, newY); var selection = window.getSelection(); var imageSrc = element.src; var nodeRange = document.createRange(); nodeRange.selectNode(element); selection.removeAllRanges(); selection.addRange(nodeRange); document.execCommand('delete'); var selection = window.getSelection(); var range = document.createRange(); selection.removeAllRanges(); selection.addRange(caretRange); document.execCommand('insertImage', false, imageSrc); } </script> <body> <div id='content' contenteditable='true' style='font-family: Helvetica'>%@</div> </body> </html>",htmlString];
    
    [_webView loadHTMLString:loadHtml baseURL:nil];

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
