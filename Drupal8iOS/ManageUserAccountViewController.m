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
    
    User *sharedUser = [User sharedInstance];
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    
    if ( [self.revisedUserPassword.text isEqualToString:@""] && [self.userName.text isEqualToString:@""] && [self.userEmailAddress.text isEqualToString:@""] ) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Information" message:@"Please provide value for atleast one filed to be change." delegate:nil cancelButtonTitle:@"Dissmiss" otherButtonTitles:nil];
        [alert show];
        
    }
    else {
        
        if ( sharedUser.name != nil && ![sharedUser.name  isEqual: @""] ) {
            
            if ( self.currentUserPassword.text != nil && ![self.currentUserPassword.text isEqualToString:@""] ) {
                
                NSError __block *sgKeyChainError = nil;
                
                // [0] = username
                // [1] = password
                NSMutableArray __block *credentials = [[SGKeychain usernamePasswordForServiceName:@"Drupal 8" accessGroup:nil error:&sgKeyChainError] mutableCopy];
                
                if ( [credentials[1] isEqualToString:self.currentUserPassword.text] ) {
                    
                    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    [self.navigationController.view addSubview:hud];
                    
                    hud.delegate = self;
                    hud.labelText = @"Updating user details";
                    [hud show:YES];
                    
                    // Currently only able to change username for the user -- see bug 2552099
                    
                    /* Build JSON body to be sent with request
                     
                     {"_links":{"type":{"href":"http://localhost/dr8b14/rest/type/user/user"}},
                     "name":[
                     {"value":"somevalue"}
                     ]
                     }
                     
                     
                     {
                     "_links":
                     {"type":{"href":"http://d8/rest/type/user/user"}},
                     "mail":[{"value":"marthinal@drupalisawesome.com"}],
                     "pass":[{"existing":"existingSecretPass", "value": "myNewSuperSecretPass"}]
                     }
                     
                     "_links" part will be taken care by drupal-ios-sdk
                     [] in JSON maps to NSArray
                     "" in JSON maps to NSString
                     {} in JSON maps to NSDictionary
                     
                     
                     */
                    NSDictionary *valueForName;
                    NSArray *nameArray;
                    NSDictionary *valueForMail;
                    NSArray *mailArray;
                    NSMutableDictionary *valueForPass = [[NSMutableDictionary alloc]initWithObjects: @[self.currentUserPassword.text] forKeys:@[@"existing"]];
                    NSArray *passArray;
                    
                    
                    if ( self.userName.text !=nil && ![self.userName.text isEqualToString:@""] ) {
                        // create dictionary   {"value":"somevalue"}
                        valueForName = [[NSDictionary alloc]initWithObjects:@[self.userName.text] forKeys:@[@"value"]];
                        // create array [{"value":"somevalue"}]
                        nameArray = [[NSArray alloc]initWithObjects:valueForName, nil];
                        
                    }
                    
                    if ( self.userEmailAddress.text !=nil && ![self.userEmailAddress.text isEqualToString:@""] ) {
                        
                        //create dictionary {"value":"marthinal@drupalisawesome.com"}
                        valueForMail = [[NSDictionary alloc]initWithObjects:@[self.userEmailAddress.text] forKeys:@[@"value"]];
                        
                        // create mail array [{"value":"marthinal@drupalisawesome.com"}]
                        mailArray = [[NSArray alloc]initWithObjects:valueForMail, nil];

                    }
                    
                    if ( self.revisedUserPassword.text != nil && ![self.revisedUserPassword.text isEqualToString:@""] ) {
                        // create dictionary {"existing":"existingSecretPass", "value": "myNewSuperSecretPass"}
                        [valueForPass setObject:self.revisedUserPassword.text forKey:@"value"];
                        
                        // create password array [{"existing":"existingSecretPass", "value": "myNewSuperSecretPass"}]
                        passArray = [[NSArray alloc]initWithObjects:valueForPass, nil];
   
                    }
                    
                    /* create dictionay {"name":[{"value":"somevalue"}],
                     "mail":[{"value":"marthinal@drupalisawesome.com"}],
                     "pass":[{"existing":"existingSecretPass", "value": "myNewSuperSecretPass"}]
                     } */
                    
                    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
                    
                    [params setObject:nameArray forKey:@"name"];
                    [params setObject:mailArray forKey:@"mail"];
                    [params setObject:passArray forKey:@"pass"];
                    
                    [DIOSUser patchUserWithID:sharedUser.uid params:params type:@"user" success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        /* Vivek: If PATCH is successfull then we may have changed any combinations of 
                         *  username, password, email. So, we need to update sharedUser and credentials on
                         *  sharedSession accordingly.
                         */
                        
                        [SGKeychain deletePasswordandUserNameForServiceName:@"Drupal 8" accessGroup:nil error:&sgKeyChainError];
                        
                        sharedUser.email = (self.userEmailAddress.text != nil && ![self.userEmailAddress.text isEqualToString:@""]) ? self.userEmailAddress.text : sharedUser.email ;
                        
                        if ( self.userName.text != nil && ![self.userName.text isEqualToString:@""] ) {
                            
                            credentials[0] = self.userName.text;
                            sharedUser.name = self.userName.text;
                            
                        }
                        
                        /* uncomment this portion when bug 2552099 is solved
                         if (self.revisedUserPassword.text != nil && ![self.revisedUserPassword.text isEqualToString:@""]) {
                         
                         credentials[1] = self.revisedUserPassword.text;
                         
                         }
                         
                         */
                        
                        [SGKeychain setPassword:credentials[1] username:credentials[0] serviceName:@"Drupal 8" accessGroup:nil updateExisting:NO error:&sgKeyChainError];
                        
                        [sharedSession setBasicAuthCredsWithUsername:credentials[0] andPassword:credentials[1]];
                        
                        UIImageView *imageView;
                        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
                        imageView = [[UIImageView alloc] initWithImage:image];
                        
                        hud.customView = imageView;
                        hud.mode = MBProgressHUDModeCustomView;
                        /* Vivek: This can be changed.  I tried 1 - 3 secs and I found 2 sufficient.
                         *  And this will show "Completed" label for 1 sec after the operation completes. 
                         *  If user's attention is specifically required than it would be better to
                         *  use UIAlertView, so that user will have to respond to it.
                         */
                        hud.labelText = @"Completed";
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // need to put main theread on sleep for 2 second so that "Completed" HUD stays on for 2 seconds
                            sleep(1);
                            [hud hide:YES];
                        });
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [hud hide:YES];
                        
                        NSInteger statusCode  = operation.response.statusCode;
                        
                        if ( statusCode == 403 ) {
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"User is not authorised for this operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                            [alert show];
                        }
                        else if (statusCode == 401) {
                            User *user = [User sharedInstance];
                            [user clearUserDetails];
                            DIOSSession *sharedSession = [DIOSSession sharedSession];
                            sharedSession.signRequests = NO;
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify login credentials first." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                            [alert show];
                            
                        }
                        else if ( statusCode == 0 ) {
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"] message:@"Plese specify a Drupal 8 site first \n" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                            [alert show];
                            
                        }
                        
                        else {
                            /* Vivek: Email and Password change requires existing password to be specified.
                             *  The code above tries to capture those requirements, but if some how it is
                             *  missed then Drupal REST will provide propper error, reflected by this alert.
                             */
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                           message:[NSString stringWithFormat:@"Error while updating user with %@",error.localizedDescription]
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                            
                            [alert show];
                        }
                    }];
                }
                
                else {
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Entered current password didn't matched with one stored in application!" delegate:nil cancelButtonTitle:@"Dissmiss" otherButtonTitles:nil];
                    [alert show];
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Information" message:@"Please provide your current password." delegate:nil cancelButtonTitle:@"Dissmiss" otherButtonTitles:nil];
                [alert show];
                
            }
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Information" message:@"Please first login to your account." delegate:nil cancelButtonTitle:@"Dissmiss" otherButtonTitles:nil];
            [alert show];
            
        }
    }
}

@end
