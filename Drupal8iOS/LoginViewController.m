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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UILabel *username_status;
@property (weak, nonatomic) IBOutlet UILabel *roles_status;

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
    [D8iOS loginwithUserName:username
                    password:password
                    withView:self.view
                  completion:^(NSMutableDictionary *userDetails) {
                      if (userDetails != nil) {
                          User *user = [User sharedInstance];
                          [user fillUserWithUserJSONObject:userDetails];
                          [self.username_status setText:user.name];
                          NSString * rolesString = [[user.roles valueForKey:@"description"] componentsJoinedByString:@" "];
                          [self.roles_status setText:rolesString];

                      }
                      else{
                          User *user = [User sharedInstance];
                          [user clearUserDetails];
                          [self.username_status setText:@"..."];
                          [self.roles_status setText:@"..."];

                      }
        
    }];
    
//    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//    [self.navigationController.view addSubview:hud];
//    
//    hud.delegate = self;
//    hud.labelText = @"Logging in";
//    [hud show:YES];
//    
//    /*
//     *  Login with Kyle's iOS-SDK
//     */
//    
//    DIOSSession *sharedSession = [DIOSSession sharedSession];
//    [sharedSession setBasicAuthCredsWithUsername:username andPassword:password];
//    NSString *basicAuthString = [D8iOSHelper basicAuthStringforUsername:username Password:password];
//    
//    [DIOSView getViewWithPath:@"user/details" params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSMutableDictionary *userDictionary = [responseObject mutableCopy];
//        [userDictionary addEntriesFromDictionary:@{@"basicAuthString":basicAuthString}];
//        NSError *setPasswordError = nil;
//        [SGKeychain setPassword:password username:username serviceName:@"Drupal 8" accessGroup:nil updateExisting:YES error:&setPasswordError];
//        
//        DIOSSession * session =  [DIOSSession sharedSession];
//        [session setBasicAuthCredsWithUsername:username andPassword:password];
//        [hud hide:YES];
//        
//        if ( userDictionary != nil ) {
//            D8D(@"userDictionary %@", userDictionary );
//            User *user = [User sharedInstance];
//            [user fillUserWithUserJSONObject:userDictionary];
//            
//            [self.username_status setText:user.name];
//            NSString * rolesString = [[user.roles valueForKey:@"description"] componentsJoinedByString:@" "];
//            
//            [self.roles_status setText:rolesString];
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSInteger statusCode  = operation.response.statusCode;
//        [hud hide:YES];
//        
//        if ( statusCode == 403 ) {
//            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Credentials" message:@"Please check username and password." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//            [alert show];
//            
//        }
//        else if ( statusCode == 0 ) {
//            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"] message:@"Plese specify a Drupal 8 site first \n" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//            [alert show];
//        }
//        else {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Error with code %ld",(long)statusCode] message:@"Please contact website admin." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//            [alert show];
//        }
//        
//        User *user = [User sharedInstance];
//        [user clearUserDetails];
//        [self.username_status setText:@"..."];
//        [self.roles_status setText:@"..."];
//        
//    }];
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

@end
