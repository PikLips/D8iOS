//
//  ManageUserAccountViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS:  This allows a registered user who is signed-in to change their
 *  user name.  It is limited to this one change as per a limitation 
 *  in the beta release of Drupal.  When Drupal is extended to allow other
 *  user profile changes, they will be added.
 */

#import "ManageUserAccountViewController.h"
#import "Developer.h"  // MAS: for development only, see which
#import "User.h"
#import "D8iOSHelper.h"
#import "DIOSUser.h"
#import "DIOSSession.h"
#import "SGKeychain.h"
#import "D8iOS.h"

@interface ManageUserAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *currentUserPassword;
@property (weak, nonatomic) IBOutlet UITextField *userEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *revisedUserPassword;

- (IBAction)submitUpdate:(id)sender;

@end

@implementation ManageUserAccountViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    User *sharedUser = [User sharedInstance];
    
    if ( sharedUser.name != nil && ![sharedUser.name  isEqual: @""] )
    {
        // Currently only able to change username for the user -- see bug 2552099
        [self.userName setText:sharedUser.name];
        [self.userEmailAddress setText:sharedUser.email];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitUpdate:(id)sender {
    
    [D8iOS updateUserAccoutwithUserName:self.userName.text
                        currentPassword:self.currentUserPassword.text
                                  email:self.userEmailAddress.text
                    revisedUserPassword:self.revisedUserPassword.text
                               withView:self.view];
}

@end
