//
//  LogoutViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "LogoutViewController.h"
#import "Developer.h"  // MAS: for development only, see which
#import "User.h"
#import "SGKeychain.h"
#import <DIOSSession.h>

@interface LogoutViewController ()

@end

@implementation LogoutViewController
- (IBAction)logoutUser:(id)sender {
    /* MAS: Log user out of Drupal site
     *      This code should also be invoked when application terminates.
     */
    
    [self performLogout];
    
    
    
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

-(void)performLogout{
    
    User *user = [User sharedInstance];
    [user clearUserDetails];
     NSError *deletePasswordError = nil;
    
    DIOSSession *session = [DIOSSession sharedSession];
    
    [session setSignRequests:NO];

    [SGKeychain deletePasswordandUserNameForServiceName:@"Drupal 8" accessGroup:nil error:&deletePasswordError];
    

}

@end
