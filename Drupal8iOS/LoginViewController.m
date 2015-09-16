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

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UILabel *username_status;
@property (weak, nonatomic) IBOutlet UILabel *roles_status;

@end

@implementation LoginViewController
- (IBAction)loginUser:(id)sender {
    // MAS: this code validates the user name and password and logs in the user
    
    [self.userName resignFirstResponder];
    [self.userPassword resignFirstResponder];
    
    //[self.activityIndicator startAnimating];
    
    NSString *username = self.userName.text;
    NSString *password = self.userPassword.text;
    
    [self loginWithUsername:username andPassword:password];
  
}
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password {
    
    
    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = @"Logging in";
    [hud show:YES];

   /* MAS:Vivek - how is this commented code useful?
   // Vivek:MAS - Again this is with plain AFNetworking. I have kept all these code as a reference just to learn how things can be done with out drupal-ios-sdk. The reason for this is as follows, drupal-ios-sdk currently has very premitive support but by learning following code we can even extend the drupal-ios-sdk if required.
    
    =============================
    Login with NSURLSessionTask
    =============================
    
    
    NSString *basicAuthString = [D8iOSHelper basicAuthStringforUsername:username Password:password];
    AFHTTPSessionManager *sessionManager =[AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [sessionManager.requestSerializer setValue:basicAuthString forHTTPHeaderField:@"Authorization"];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
   
    
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    NSString *baseURLString = [defaults objectForKey:DRUPAL8SITE];
    
    NSURLSessionDataTask *loginOperation = [sessionManager GET:[NSString stringWithFormat:@"%@/user/details",baseURLString]
                                                    parameters:nil
                                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                                         //  [self.activityIndicator stopAnimating];
                                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                                           int responseCode = httpResponse.statusCode;
                                                           if(responseCode == 200){
                                                               
                                                               NSMutableDictionary *userDictionary = [responseObject mutableCopy];
                                                               [userDictionary addEntriesFromDictionary:@{@"basicAuthString":basicAuthString}];
                                                               NSError *setPasswordError = nil;
                                                               [SGKeychain setPassword:password username:username serviceName:@"Drupal 8" accessGroup:nil updateExisting:YES error:&setPasswordError];
                                                               
                                                               DIOSSession * session =  [DIOSSession sharedSession];
                                                               [session setBasicAuthCredsWithUsername:username andPassword:password];
                                                               [hud hide:YES];
                                                               
                                                               if (userDictionary != nil) {
                                                                   NSLog(@"userDictionary %@", userDictionary );
                                                                   User *user = [User sharedInstance];
                                                                   [user fillUserWithUserJSONObject:userDictionary];
                                                                   
                                                                   [self.username_status setText:user.name];
                                                                   NSString * rolesString = [[user.roles valueForKey:@"description"] componentsJoinedByString:@" "];
                                                                   
                                                                   [self.roles_status setText:rolesString];
                                                                   
                                                                   
                                                               }
                                                               
                                                           }
                                                           
                                                           
                                                           
                                                           
                                                           
                                                           //                                                           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                           //
                                                           //                                                           // remove login view from stack and add userDetails view to stack
                                                           //                                                           [self.navigationController setViewControllers:[NSArray arrayWithObject:[storyboard instantiateViewControllerWithIdentifier:@"userDetails"]] animated:YES];
                                                           
                                                           
                                                       } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                           
                                                           //[self.activityIndicator stopAnimating];
                                                           [hud hide:YES];
                                                           NSLog(@"faliure %@",error.description);
                                                           
                                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                                           int responseCode = httpResponse.statusCode;
                                                           if (responseCode == 403){
                                                               NSLog(@"inside else if");
                                                               UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Credentials" message:@"Please check username and password." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                                               [alert show];
                                                               
                                                               
                                                           }
                                                           else{
                                                               
                                                               UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Error with code %d",responseCode] message:@"Please contact website admin." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                                               [alert show];
                                                               
                                                               
                                                           }
                                                           User *user = [User sharedInstance];
                                                           [user clearUserDetails];
                                                           [self.username_status setText:@"..."];
                                                           [self.roles_status setText:@"..."];
                                                           
                                                           
                                                       }];
    
    [loginOperation resume];
   // [self.activityIndicator startAnimating];
    
   */
    
    /*
     ==================================
            Login with Kyle's SDK
     ==================================
     
     */
    
    
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    [sharedSession setBasicAuthCredsWithUsername:username andPassword:password];
    NSString *basicAuthString = [D8iOSHelper basicAuthStringforUsername:username Password:password];
    
    
    [DIOSView getViewWithPath:@"user/details" params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *userDictionary = [responseObject mutableCopy];
        [userDictionary addEntriesFromDictionary:@{@"basicAuthString":basicAuthString}];
        NSError *setPasswordError = nil;
        [SGKeychain setPassword:password username:username serviceName:@"Drupal 8" accessGroup:nil updateExisting:YES error:&setPasswordError];
        
        DIOSSession * session =  [DIOSSession sharedSession];
        [session setBasicAuthCredsWithUsername:username andPassword:password];
        [hud hide:YES];
        
        if (userDictionary != nil) {
            NSLog(@"userDictionary %@", userDictionary );
            User *user = [User sharedInstance];
            [user fillUserWithUserJSONObject:userDictionary];
            
            [self.username_status setText:user.name];
            NSString * rolesString = [[user.roles valueForKey:@"description"] componentsJoinedByString:@" "];
            
            [self.roles_status setText:rolesString];
            
            
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSInteger statusCode  = operation.response.statusCode;
        [hud hide:YES];
        
        if (statusCode == 403){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Credentials" message:@"Please check username and password." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
            
            
        }
        else if( statusCode == 0){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"] message:@"Plese specify a Drupal 8 site first \n" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];

        }
        
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Error with code %ld",(long)statusCode] message:@"Please contact website admin." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
            

        
        }
        
        User *user = [User sharedInstance];
        [user clearUserDetails];
        [self.username_status setText:@"..."];
        [self.roles_status setText:@"..."];
        
    }];
    
    

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    User *user  = [User sharedInstance];
    if(user.name != nil){
        [self.username_status setText:user.name];
        NSString * rolesString = [[user.roles valueForKey:@"description"] componentsJoinedByString:@" "];
        
        [self.roles_status setText:rolesString];

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
