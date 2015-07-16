//
//  ManageUserAccountViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS: *****************************************************************************
 *************        For Vivek to code here to END  ----       *********************
 *************  Code this as you see fit.                       *********************
 *************  We will tie the logic into the UI.              *********************/

#import "ManageUserAccountViewController.h"
#import "Developer.h"  // MAS: for development only, see which

@interface ManageUserAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *currentUserPassword;
@property (weak, nonatomic) IBOutlet UITextField *userEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *revisedUserPassword;

- (IBAction)submitUpdate:(id)sender;

@end

@implementation ManageUserAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitUpdate:(id)sender {
}

@end
