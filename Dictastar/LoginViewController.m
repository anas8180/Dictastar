//
//  LoginViewController.m
//  Dictastar
//
//  Created by mohamed on 16/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "LoginViewController.h"
#import "Constant.h"
#import "BTServicesClient.h"
#import "UIViewController+ActivityLoader.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController () {
    
    BOOL savePswdChecked;
}

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topLayout;
@property (strong, nonatomic) IBOutlet UITextField *emailTextFld;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextFld;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoBtmLayout;
@property (strong, nonatomic) IBOutlet UIView *forgotView;
@property (strong, nonatomic) IBOutlet UIView *forgotPswdView;
@property (strong, nonatomic) IBOutlet UITextField *forgotTextField;
@property (strong, nonatomic) IBOutlet UIImageView *forgot_user_icon;
@property (strong, nonatomic) IBOutlet UILabel *forgot_status_text;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IS_IPHONE4) {
        
        _topLayout.constant = 20;
        _logoBtmLayout.constant = 70;
    }
    
    else if (IS_IPHONE5) {
        
        _topLayout.constant = 20;
        _logoBtmLayout.constant = 100;
    }
    
    else if (IS_IPHONE6 || IS_IPHONE6PLUS) {
        
        _topLayout.constant = 70;
    }
    
    _forgotView.hidden = YES;
    
    savePswdChecked = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view, typically from a nib.
    
    _emailTextFld.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    _passwordTextFld.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Notifications
- (void)keyboardDidShow:(NSNotification *)notification{
    
        if (IS_IPHONE4) {
            self.topLayout.constant = -120;
        }
        else if (IS_IPHONE5) {
            self.topLayout.constant = -30;
        }
        else if (IS_IPHONE6) {
            self.topLayout.constant = 20;
        }
    
        [self moveViewUpAndDown];
    
}

- (void)keyboardDidHide:(NSNotification *)notification{
   
    if (IS_IPHONE4) {
        self.topLayout.constant = 20;
    }
    else if (IS_IPHONE5) {
        self.topLayout.constant = 20;
    }
    else if (IS_IPHONE6) {
        self.topLayout.constant = 70;
    }
    [self moveViewUpAndDown];
}

- (void)moveViewUpAndDown{
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

#pragma mark - Action

- (IBAction)loginAction:(id)sender {
    
    if ([_emailTextFld.text isEqualToString:@""] || [_passwordTextFld.text isEqualToString:@""]) {
        
        [self addMessageLoader:@"Please Enter the Field"];
    }
    else {
        
    self.view.userInteractionEnabled = NO;
        
    NSDictionary *params = @{@"Username":_emailTextFld.text,@"Password":_passwordTextFld.text};
    
    [[BTServicesClient sharedClient] GET:@"CheckAuthenticationinJson" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
   
        NSError* error;
        NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        
        NSArray *jsonArray = [jsonDict objectForKey:@"Table"];
        
        NSDictionary *dict = [jsonArray objectAtIndex:0];
        
        NSString *username = [dict objectForKey:@"username"];
        
        if (username == nil) {
            
            [self addMessageLoader:@"Invalid Username/Password"];
        }
        else
        {
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"user_info"];
        [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"10" forKey:@"max_dict"];
            [[NSUserDefaults standardUserDefaults] synchronize];

        
        UITabBarController *tabVc = (UITabBarController *)[self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        
        [self presentViewController:tabVc animated:YES completion:nil];
        }
        
        self.view.userInteractionEnabled = YES;

        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        NSLog(@"%@",error.localizedDescription);
        
        [self addMessageLoader:error.localizedDescription];
        
        self.view.userInteractionEnabled = YES;
    }];
    }

}

- (IBAction)forgotPasswordTapped:(id)sender {
    
    _forgotView.hidden = NO;
    _forgot_status_text.hidden = YES;
}
- (IBAction)closePopUp:(id)sender {
    
    
    _forgotView.hidden = YES;

    _forgot_status_text.hidden = YES;

    _forgotTextField.hidden = NO;
    _forgot_user_icon.hidden = NO;
    _submitButton.hidden = NO;

}


- (IBAction)submitAction:(id)sender {
    
    NSDictionary *params = @{@"Username":_forgotTextField.text};
    
    [[BTServicesClient sharedClient] GET:@"FetchFacilityUserPWDJSON" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *data = [jsonDict objectForKey:@"Table"];
        
        if (data.count) {
            
            _forgotTextField.hidden = YES;
            _forgot_user_icon.hidden = YES;
            _submitButton.hidden = YES;
            _forgot_status_text.hidden = NO;
            
            _forgot_status_text.text = @"Your Password Will be send to the registered Email";

        }
        else {
            
            _forgotTextField.hidden = YES;
            _forgot_user_icon.hidden = YES;
            _submitButton.hidden = YES;
            _forgot_status_text.hidden = NO;
            
            _forgot_status_text.text = @"Please Enter Correct Username";

        }
        
        _forgotTextField.text = @"";

        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        _forgotTextField.hidden = YES;
        _forgot_user_icon.hidden = YES;
        _submitButton.hidden = YES;
        _forgot_status_text.hidden = NO;
        
        _forgot_status_text.text = error.localizedDescription;

        _forgotTextField.text = @"";

    }];

    
}

-(BOOL) stringIsNumeric:(NSString *) str {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    return !!number; // If the string is not numeric, number will be nil
}
- (IBAction)savePassword:(id)sender {
    
    if (savePswdChecked) {
        
        [sender setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        
        savePswdChecked = NO;
    }
    
    else {
        
        [sender setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        
        savePswdChecked = YES;

    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
}*/


@end
