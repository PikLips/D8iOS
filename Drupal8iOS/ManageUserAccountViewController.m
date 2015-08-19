//
//  ManageUserAccountViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS: *****************************************************************************
 *************        For Vivek to code here to END  ----       *********************
 *************  Code this as you see fit.                       *********************
 *************  We will tie the logic into the UI.              *********************/

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
    
if (sharedUser.name != nil && ![sharedUser.name  isEqual: @""])
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)submitUpdate:(id)sender {
    
    User *sharedUser = [User sharedInstance];
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    
    
    if (sharedUser.name != nil && ![sharedUser.name  isEqual: @""])
    {  NSError __block *sgKeyChainError = nil;
        
        // [0] = username
        // [1] = password
        NSMutableArray __block *credentials = [[SGKeychain usernamePasswordForServiceName:@"Drupal 8" accessGroup:nil error:&sgKeyChainError] mutableCopy];
        
       // enable this if and corresponding else block once bug 2552099 is fixed
        
      //  if([credentials[1] isEqualToString:self.currentUserPassword.text]) {
            
            
            
            
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
             
             "_links" part will be taken care by drupal-ios-sdk
             [] in JSON maps to NSArray
             "" in JSON maps to NSString
             {} in JSON maps to NSDictionary
             
             
             */
            
            
            // create dictionary   {"value":"somevalue"}
            NSDictionary *valueForName = [[NSDictionary alloc]initWithObjects:@[self.userName.text] forKeys:@[@"value"]];
            
            // create array [{"value":"somevalue"}]
            NSArray *nameArray = [[NSArray alloc]initWithObjects:valueForName, nil];
            
            // create dictionay {"name":[{"value":"somevalue"}]}
            NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
            
            [params setObject:nameArray forKey:@"name"];
            
            // For email and password fields will be added after bug 2552099 is resolved
            
            
            
            
            [DIOSUser patchUserWithID:sharedUser.uid params:params type:@"user" success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                // If PATCH is successfull then it may have changed any combinations of username, password, email so we need to update sharedUser and credentials on sharedSession accordingly
                
                
                
                [SGKeychain deletePasswordandUserNameForServiceName:@"Drupal 8" accessGroup:nil error:&sgKeyChainError];
                
                
                
                
                sharedUser.email = (self.userEmailAddress.text != nil && ![self.userEmailAddress.text isEqualToString:@""]) ? self.userEmailAddress.text : sharedUser.email ;
                
                
                if (self.userName.text != nil && ![self.userName.text isEqualToString:@""]  ) {
                    
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
                
                hud.labelText = @"Completed";
                dispatch_async(dispatch_get_main_queue(), ^{
                    // need to put main theread on sleep for 2 second so that "Completed" HUD stays on for 2 seconds
                    sleep(1);
                    [hud hide:YES];
                });
                
                
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [hud hide:YES];
                
                
                
                NSInteger statusCode  = operation.response.statusCode;
                
                if (statusCode == 403){
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Credentials" message:@"Please check username and password." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [alert show];
                    
                    
                    User *user = [User sharedInstance];
                    [user clearUserDetails];
                    DIOSSession *sharedSession = [DIOSSession sharedSession];
                    sharedSession.signRequests = NO;
                    
                    
                    
                    
                }
                else if( statusCode == 0){
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"] message:@"Plese specify a Drupal 8 site first \n" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [alert show];
                    
                }
                
                else{
                    
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                   message:[NSString stringWithFormat:@"Error while updating user with %@",error.localizedDescription]
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    
                    [alert show];
                }
                
                
                
            }];
            
            
     //   }
        
//        else{
//            
//            
//            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Entered current password didn't matched with one stored in application!" delegate:nil cancelButtonTitle:@"Dissmiss" otherButtonTitles:nil];
//            [alert show];
//            
//            
//            
//            
//        }
    
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Information" message:@"Please first login to your account." delegate:nil cancelButtonTitle:@"Dissmiss" otherButtonTitles:nil];
        [alert show];
        
    }
    
    
}

@end
