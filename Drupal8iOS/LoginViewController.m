//
//  LoginViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS: This signs in a registered user
 */

#import "LoginViewController.h"
#import "Developer.h"  // MAS: for development only, see which
#import "D8iOSHelper.h"
#import "SGKeychain.h"
#import "User.h"
#import <AFNetworking/AFNetworking.h>
#import "DIOSSession.h"
#import "DIOSView.h"
#import "D8iOS.h"
#import "NotifyViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UILabel *username_status;
@property (weak, nonatomic) IBOutlet UILabel *roles_status;
@property (strong, atomic) MBProgressHUD  *hud;  // for activity indicator


@end

@implementation LoginViewController
-(IBAction)loginUser:(id)sender {
    // MAS: this code validates the user name and password and logs in the user
    
    [self.userName resignFirstResponder];
    [self.userPassword resignFirstResponder];
    
    //[self.activityIndicator startAnimating];
    
    NSString *username = self.userName.text;
    NSString *password = self.userPassword.text;
    
    [self loginWithUsername:username andPassword:password];
  
}
-(void)loginWithUsername:(NSString *)username andPassword:(NSString *)password {    
    [self toggleSpinner:YES];
    [D8iOS loginwithUserName:username
                    password:password
                     success:^(NSMutableDictionary *userDetails) {
                         [self toggleSpinner:NO];
                                User *user = [User sharedInstance];
                                [user fillUserWithUserJSONObject:userDetails];
                                [self.username_status setText:user.name];
                                NSString * rolesString = [[user.roles valueForKey:@"description"] componentsJoinedByString:@" "];
                                [self.roles_status setText:rolesString];
                         
                     }
                     failure:^(AFHTTPRequestOperation *operation,NSError *error) {
                         [self toggleSpinner:NO];
                         User *user = [User sharedInstance];
                         [user clearUserDetails];
                         [self.username_status setText:@"..."];
                         [self.roles_status setText:@"..."];
                         
                         NSInteger statusCode  = operation.response.statusCode ;
                         
                         if ( statusCode == 403 ) {
                             [self presentViewController:[NotifyViewController invalidCredentialNotify]
                                                animated:YES
                                              completion:nil];
                                                         
                         }
                         else if ( statusCode == 0 ) {
                             [self presentViewController:[NotifyViewController zeroStatusCodeNotifyError:error.localizedDescription]
                                                animated:YES
                                              completion:nil];
                                                      }
                         else {
                             NSString *errmsg  = [NSString stringWithFormat:@"Error with status code %d",statusCode];

                             [self presentViewController:[NotifyViewController contactAdminNotifyError:errmsg]
                                                animated:YES
                                              completion:nil];
                         }

                         
                     }];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    User *user  = [User sharedInstance];
    if(user.name != nil){
        [self.username_status setText:user.name];
        NSString * rolesString = [[user.roles valueForKey:@"description"] componentsJoinedByString:@" "];
        
        [self.roles_status setText:rolesString];

    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/** @function toggleSpinner: (bool) on
*  @param on A bool indicating whether the activity indicator should be on or off.
*  @abstract This implements MBProgressHUB as an alternative to UIActivityIndicatorView .
*  @seealso https://github.com/jdg/MBProgressHUD
*  @discussion This needs to be a Cocoapod and abstracted into its own class with specific objects
*              for each use (more illustrative).
*  @return N/A
*  @throws N/A
*  @updated
*
*/

-(void)toggleSpinner:(bool) on {
    if ( on ) {
        _hud = [[MBProgressHUD alloc ] initWithView:super.view];
        [super.view addSubview:_hud];
        _hud.delegate = nil;
        _hud.labelText = @"Logging in";
        [_hud show:YES];
    }
    else {
            [_hud hide:YES];
    }
}

@end
