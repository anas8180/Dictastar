//
//  SettingsViewController.m
//  Dictastar
//
//  Created by mohamed on 28/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "SettingsViewController.h"
#import "LoginViewController.h"

@interface SettingsViewController ()<UITabBarDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.tableView.backgroundColor = [UIColor clearColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopCell" forIndexPath:indexPath];
        
        // Configure the cell...
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {  // Safety check for below iOS 7
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        return cell;
        
    }
    
    else if (indexPath.row == 1) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
        
        // Configure the cell...
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {  // Safety check for below iOS 7
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        return cell;
        
        
    }
    
    else if (indexPath.row == 2) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DictateCell" forIndexPath:indexPath];
        
        // Configure the cell...
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {  // Safety check for below iOS 7
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        return cell;
        
    }
    
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExitCell" forIndexPath:indexPath];
        
        // Configure the cell...
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {  // Safety check for below iOS 7
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 100.0;
    }
    else {
        
        return 50.0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 3) {
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"user_info"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

        LoginViewController *mainVu = [storyBoard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self presentViewController:mainVu animated:NO completion:nil];

    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Action

- (IBAction)closeSettings:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
