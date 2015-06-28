//
//  MaxDictateSelectViewController.m
//  Dictastar
//
//  Created by mohamed on 28/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "MaxDictateSelectViewController.h"
#import "ProfileTableViewCell.h"

@interface MaxDictateSelectViewController ()<UITableViewDataSource,UITableViewDelegate> {
    
    NSIndexPath *selectedIndexPath;

}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;


@end

@implementation MaxDictateSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dataArray = @[@"5",@"10",@"15",@"20",@"25",@"30"];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    selectedIndexPath = nil;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else {
        return _dataArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopCell" forIndexPath:indexPath];
        
        // Configure the cell...
        
        return cell;
        
    }
    
    else {
        
        ProfileTableViewCell *cell = (ProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
        
        cell.title.text = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:indexPath.row]];
        [cell.selectRadioButton addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectRadioButton.tag = indexPath.row;


        if (indexPath.row == selectedIndexPath.row) {
            [cell.selectRadioButton setImage:[UIImage imageNamed:@"radio_on"] forState:UIControlStateNormal];
            ;
        }
        else {
            [cell.selectRadioButton setImage:[UIImage imageNamed:@"radio_off"] forState:UIControlStateNormal];            
        }

        
        return cell;
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 100.0;
    }
    else {
        
        return 50.0;
    }
}

#pragma mark - Action

-(void)selectType:(id)sender {
    
    NSInteger tag = [sender tag];
    
    selectedIndexPath = [NSIndexPath indexPathForRow:tag inSection:1];
    
    [self.tableView reloadData];
}

- (IBAction)cancelTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)OkTapped:(id)sender {
    
    if (selectedIndexPath != nil) {
        
        NSString *str = [_dataArray objectAtIndex:selectedIndexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"max_dict"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    
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
