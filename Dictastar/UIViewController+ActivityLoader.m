//
//  UIViewController+ActivityLoader.m
//  PinkyApp
//
//  Created by mohamed on 21/04/15.
//  Copyright (c) 2015 Arsalan. All rights reserved.
//

#import "UIViewController+ActivityLoader.h"
#import "MBProgressHUD.h"

@implementation UIViewController (ActivityLoader)

-(void)addLoader
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    NSLog(@"%@",NSStringFromCGRect(hud.frame));
}

-(void)addMessageLoader:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

-(void)hideHud
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
