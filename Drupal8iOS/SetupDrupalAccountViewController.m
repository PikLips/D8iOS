//
//  SetupDrupalAccountViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS: *****************************************************************************
 *************        For Vivek to code here to END  ----       *********************
 *************  Code this as you see fit.                       *********************
 *************  We will tie the logic into the UI.              *********************/

#import "SetupDrupalAccountViewController.h"
#import "Developer.h"  // MAS: for development only, see which

@interface SetupDrupalAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *drupalUserName;
@property (weak, nonatomic) IBOutlet UITextField *drupalUserEmail;
@property (weak, nonatomic) IBOutlet UITextField *drupalUserPassword;

@end

@implementation SetupDrupalAccountViewController
- (IBAction)validateUserAccount:(id)sender {
    /* MAS: Vivek: validate format of userName, userEmail, and userPassword, then submit
     *      to Drupal site as new account.
     *      Report error alert for duplicate userName and allow retry.
     */

}

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

@end
