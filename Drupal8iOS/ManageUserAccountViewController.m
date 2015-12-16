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
#import "MBProgressHUD.h"
#import "NotifyViewController.h"

@interface ManageUserAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *currentUserPassword;
@property (weak, nonatomic) IBOutlet UITextField *userEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *revisedUserPassword;
@property (strong,nonatomic) MBProgressHUD *hud;


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
    
    User *sharedUser = [User sharedInstance];
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    
    if ( [self.revisedUserPassword.text isEqualToString:@""] && [self.userName.text isEqualToString:@""] && [self.userEmailAddress.text isEqualToString:@""] ) {
        
        [self presentViewController:[NotifyViewController informationNotifywithMsg:@"Please provide value for atleast one filed to be change."]
                           animated:YES
                         completion:nil];
        
        
    }
    else {
        
        if ( sharedUser.name != nil && ![sharedUser.name  isEqual: @""] ) {
            
            if ( self.currentUserPassword.text != nil && ![self.currentUserPassword.text isEqualToString:@""] ) {
                
                NSError __block *sgKeyChainError = nil;
                
                // [0] = username
                // [1] = password
                NSMutableArray __block *credentials = [[SGKeychain usernamePasswordForServiceName:@"Drupal 8"
                                                                                      accessGroup:nil
                                                                                            error:&sgKeyChainError] mutableCopy];
                
                if ( [credentials[1] isEqualToString:self.currentUserPassword.text] ) {
                    
                    [self toggleSpinner:YES];
                    [D8iOS updateUserAccoutwithUserName:self.userName.text
                                        currentPassword:self.currentUserPassword.text
                                                  email:self.userEmailAddress.text
                                    revisedUserPassword:self.revisedUserPassword.text
                                               withView:self.view];
                    
                    [D8iOS updateUserAccoutwithUserName:self.userName.text
                                        currentPassword:self.currentUserPassword.text
                                                  email:self.userEmailAddress.text
                                    revisedUserPassword:self.revisedUserPassword.text
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        /* Vivek: If PATCH is successfull then we may have changed any combinations of
                         *  username, password, email. So, we need to update sharedUser and credentials on
                         *  sharedSession accordingly.
                         */
                        
                        [SGKeychain deletePasswordandUserNameForServiceName:@"Drupal 8"
                                                                accessGroup:nil
                                                                      error:&sgKeyChainError];
                        
                        sharedUser.email = (self.userEmailAddress.text != nil && ![self.userEmailAddress.text isEqualToString:@""]) ? self.userEmailAddress.text : sharedUser.email ;
                        
                        if ( self.userName.text != nil && ![self.userName.text isEqualToString:@""] ) {
                            
                            credentials[0] = self.userName.text;
                            sharedUser.name = self.userName.text;
                            
                        }
                        
                        
                        if (self.revisedUserPassword.text != nil && ![self.revisedUserPassword.text isEqualToString:@""]) {
                            
                            credentials[1] = self.revisedUserPassword.text;
                            
                        }
                        
                        
                        
                        [SGKeychain setPassword:credentials[1]
                                       username:credentials[0]
                                    serviceName:@"Drupal 8"
                                    accessGroup:nil
                                 updateExisting:NO
                                          error:&sgKeyChainError];
                        
                        [sharedSession setBasicAuthCredsWithUsername:credentials[0]
                                                         andPassword:credentials[1]];
                        [self toggleSpinner:NO];
                        
                    }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [self toggleSpinner:NO];
                        
                        NSInteger statusCode  = operation.response.statusCode;
                        
                        if ( statusCode == 403 ) {
                            
                            [self presentViewController:[NotifyViewController notAuthorisedNotifyError]
                                               animated:YES
                                             completion:nil];
                        }
                        else if (statusCode == 401) {
                            User *user = [User sharedInstance];
                            // Credentials are not valid so remove it
                            [user clearUserDetails];
                            DIOSSession *sharedSession = [DIOSSession sharedSession];
                            sharedSession.signRequests = NO;
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
                            /** Vivek: Email and Password change requires existing password to be specified.
                             *  The code above tries to capture those requirements, but if some how it is
                             *  missed then Drupal REST will provide propper error, reflected by this alert.
                             */
                            
                            NSMutableDictionary *errorResponse = (NSMutableDictionary *)operation.responseObject;
                            
                            [self presentViewController:[NotifyViewController genericNotifyError:[errorResponse objectForKey:@"error"]]
                                               animated:YES
                                             completion:nil];
                        }

                    }];
                }
                
                else {
                    [self presentViewController:[NotifyViewController genericNotifyError:@"Entered current password didn't matched with one stored in application!"]
                                       animated:YES
                                     completion:nil];
                    
                }
            }
            else {
                
                [self presentViewController:[NotifyViewController informationNotifywithMsg:@"Please provide your current password."]
                                   animated:YES
                                 completion:nil];
            }
        }
        else {
            [self presentViewController:[NotifyViewController informationNotifywithMsg:@"Please first login to your account."]
                               animated:YES
                             completion:nil];
        }
    }

    
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
        _hud.labelText = @"Updating user details";
        [_hud show:YES];
    }
    else {
        UIImageView *imageView;
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
        _hud.customView = imageView;
        _hud.mode = MBProgressHUDModeCustomView;
        _hud.labelText = @"Completed";
        dispatch_async(dispatch_get_main_queue(), ^{
            // Put main thread to sleep so that "Completed" HUD stays on for a second
            sleep(1);
            [_hud hide:YES];
        });
    }
}


@end
