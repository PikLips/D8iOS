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
    
    /* As per the RESTFul architecture server never stores the states of request or client.
     So every request is sent with proper credential details if it is required.
     It is client's responsiblity to maintain state information.
     So for log out we do not have to perform any network call, we just delete credential details from our app.
     */
    
    
    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = @"Erasing login data";
    [hud show:YES];

    
    User *user = [User sharedInstance];
    [user clearUserDetails]; // deleting details from User shared object
     NSError *deletePasswordError = nil;
    
    DIOSSession *session = [DIOSSession sharedSession];
    
    [session setSignRequests:NO]; // request from drupal-ios-sdk will not send credential information
    [session.requestSerializer clearAuthorizationHeader];
    // Also remove data form keychain storage
    [SGKeychain deletePasswordandUserNameForServiceName:@"Drupal 8" accessGroup:nil error:&deletePasswordError];
    
    UIImageView *imageView;
    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
    imageView = [[UIImageView alloc] initWithImage:image];
    
    hud.customView = imageView;
    hud.mode = MBProgressHUDModeCustomView;
    
    hud.labelText = @"Completed";
    dispatch_async(dispatch_get_main_queue(), ^{
        // need to put main theread on sleep for 2 second so that "Completed" HUD stays on for 2 seconds
        sleep(1);
        [hud hide:YES];
    });


}

@end
