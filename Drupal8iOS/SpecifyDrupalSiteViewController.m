//
//  SpecifyDrupalSiteViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS: *****************************************************************************
 *************        For Vivek to code here to END  ----       *********************
 *************  Code this as you see fit.                       *********************
 *************  We will tie the logic into the UI.              *********************/

#import "SpecifyDrupalSiteViewController.h"
#import "Developer.h"  // MAS: for development only, see which

@interface SpecifyDrupalSiteViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userSiteRequest; // MAS: user input that require local format validation and remote confirmation
@end

@implementation SpecifyDrupalSiteViewController
- (IBAction)checkDrupalSite:(id)sender {
    // check logic goes here
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
