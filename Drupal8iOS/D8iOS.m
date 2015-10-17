//
//  D8iOS.m
//  Drupal8iOS
//
//  Created by Michael Smith on 10/16/15.
//  Copyright © 2015 PikLips. All rights reserved.
//  Written by Vivek Pandya
//
#import "Developer.h"
#import "D8iOS.h"
#import "Comment.h"
#import "Article.h"
#import "FileJSON.h"
#import "DIOSView.h"
#import "DIOSSession.h"
#import "DIOSEntity.h"
#import "DIOSUser.h"
#import "DIOSNode.h"
#import "User.h"
#import "SGKeychain.h"

@implementation D8iOS

+ (void) uploadImageToServer: (PHAsset *) asset withImage: (UIImageView *) assetImage withinView: (UIViewController *)navController {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:navController.view];
    [navController.view addSubview:hud];
    
    hud.dimBackground = YES;
    hud.labelText = @"Uploading image ...";
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    hud.delegate = nil;  //MAS: problem: this is for an instance object instead of a class
    
    [hud show:YES];
    
    
    // This is the JSON body with required details to be sent
    NSDictionary *params = @{
                             @"filename":@[@{@"value":[asset valueForKey:@"filename"]}],
                             @"data":@[@{@"value":[self encodeToBase64String:assetImage.image]
                                         }]};
    
    [DIOSEntity createEntityWithEntityName:@"file" type:@"file" andParams:params
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       
                                       [hud hide:YES];
                                       
                                       long statusCode = operation.response.statusCode;
                                       // This can happen when POST is with out Authorization details or login fails
                                       if ( statusCode == 401 ) {
                                           DIOSSession *sharedSession = [DIOSSession sharedSession];
                                           
                                           sharedSession.signRequests = NO;
                                           
                                           User *sharedUser = [User sharedInstance];
                                           [sharedUser clearUserDetails];
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify the login credentials." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                           [alert show];
                                       }
                                       
                                       else if ( statusCode == 0 ) {
                                           
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"] message:@"Plese specify a Drupal 8 site first \n" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                           [alert show];
                                           
                                       }
                                       
                                       // Credentials are valid but user is not authorised for the operation.
                                       else if ( statusCode == 403 ) {
                                           
                                           
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"User is not authorised for the operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                           [alert show];
                                       }
                                       else {
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                           [alert show];
                                           
                                       }
                                   }];
}
+ (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


+(void)getCommentDataforNodeID:(NSString *)nodeID withView:(UIView *)view completion:(void (^)(NSMutableArray *commentList))completion {
    
    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    hud.delegate = nil;
    hud.labelText = @"Loading the comments";
    [hud show:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    sharedSession.baseURL = baseURL;
    sharedSession.signRequests = YES;
    if ( sharedSession.baseURL != nil ) {
        [DIOSView getViewWithPath:[NSString stringWithFormat:@"comments/%@",nodeID]
                           params:nil
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              NSMutableArray *commentList = [[NSMutableArray alloc]init];
                              for (NSMutableDictionary *comment in responseObject)
                              {
                                  Comment *newComment = [[Comment alloc]initWithDictionary:comment];
                                  [commentList addObject:newComment];
                              }
                              sharedSession.signRequests =YES;
                              [hud hide:YES];
                              if (completion) {
                                  completion(commentList);
                              }
                              
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              [hud hide:YES];
                              sharedSession.signRequests =YES;
                              
                              long statusCode = operation.response.statusCode;
                              // This can happen when GET is with out Authorization details
                              if ( statusCode == 401 ) {
                                  sharedSession.signRequests = NO;
                                  
                                  User *sharedUser = [User sharedInstance];
                                  [sharedUser clearUserDetails];
                                  
                                  UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                 message:@"Please verify the login credentials"
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"Dismiss"
                                                                       otherButtonTitles: nil];
                                  [alert show];
                              }
                              
                              // Credentials is correct but user is not authorised to do certain operation.
                              else if( statusCode == 403 ) {
                                  
                                  
                                  UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                 message:@"User is not authorised for this operation."
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"Dismiss"
                                                                       otherButtonTitles: nil];
                                  [alert show];
                                  
                              }
                              else{
                                  UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                 message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription]
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"Dismiss"
                                                                       otherButtonTitles: nil];
                                  [alert show];
                                  
                              }
                              completion(nil);
                          }];
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                       message:@"Please specify a drupal site first"
                                                      delegate:nil
                                             cancelButtonTitle:@"Dismiss"
                                             otherButtonTitles: nil];
        [alert show];
    }
}

+(void)getFileDatafromPath: (NSString *)path
                  withView:(UIView *)view
                completion:(void (^)(NSMutableArray *fileList))completion{
    User *sharedUser = [User sharedInstance];
    
    if ( sharedUser.uid != nil && ![sharedUser.uid isEqualToString:@""] ) {
        
        MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        
        hud.delegate = nil;
        hud.labelText = @"Loading the files";
        [hud show:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
        DIOSSession *sharedSession = [DIOSSession sharedSession];
        sharedSession.baseURL = baseURL;
        if ( sharedSession.baseURL != nil ) {
            [DIOSView getViewWithPath:[NSString stringWithFormat:@"%@/%@",path,sharedUser.uid]
                               params:nil
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSMutableArray *listOfFiles = [[NSMutableArray alloc]init];
                for ( NSMutableDictionary *fileJSONDict in responseObject )
                {
                    FileJSON *fileJSONObj = [[FileJSON alloc]initWithDictionary:fileJSONDict];
                    [listOfFiles addObject:fileJSONObj];
                }
                [hud hide:YES];
                                  if (completion) {
                                      completion(listOfFiles);
                                  }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [hud hide:YES];
                
                long statusCode = operation.response.statusCode;
                // This can happen when GET is with out Authorization details
                if ( statusCode == 401 ) {
                    sharedSession.signRequests = NO;
                    
                    User *sharedUser = [User sharedInstance];
                    [sharedUser clearUserDetails];
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                   message:@"Please verify the login credentials"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Dismiss"
                                                         otherButtonTitles: nil];
                    [alert show];
                }
                
                // Credentials are valid but user is not authorised to perform this operation.
                else if( statusCode == 403 ) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                   message:@"User is not authorised for this operation."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Dismiss"
                                                         otherButtonTitles: nil];
                    [alert show];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                   message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription]
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Dismiss"
                                                         otherButtonTitles: nil];
                    [alert show];
                    
                }
                completion(nil);
            }];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                           message:@"Please specify a drupal site first"
                                                          delegate:nil
                                                 cancelButtonTitle:@"Dismiss"
                                                 otherButtonTitles: nil];
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                       message:@"Please first login"
                                                      delegate:nil
                                             cancelButtonTitle:@"Dismiss"
                                             otherButtonTitles: nil];
        [alert show];
    }

}

+(void)getArticleDatawithView:(UIView *)view
                   completion:(void (^)(NSMutableArray *))completion{
    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    hud.delegate = nil;
    hud.labelText = @"Loading the articles";
    [hud show:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    sharedSession.baseURL = baseURL;
    if ( sharedSession.baseURL != nil ) {
        [DIOSView getViewWithPath:@"articles" params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSMutableArray * articleList = [[NSMutableArray alloc]init];
            for ( NSMutableDictionary *article in responseObject )
            {
                Article *newTip = [[Article alloc]initWithDictionary:article];
                [articleList addObject:newTip];
                
            }
            [hud hide:YES];
            if (completion) {
                completion(articleList);
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [hud hide:YES];
            long statusCode = operation.response.statusCode;
            // This can happen when GET is with out Authorization details or credentials are wrong
            if ( statusCode == 401 ) {
                
                sharedSession.signRequests = NO;
                
                User *sharedUser = [User sharedInstance];
                [sharedUser clearUserDetails];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                               message:@"Please verify login credentials. "
                                                              delegate:nil
                                                     cancelButtonTitle:@"Dismiss"
                                                     otherButtonTitles: nil];
                [alert show];
            }
            
            // Credentials are valid but user is not authorised to perform this operation.
            else if ( statusCode == 403 ) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                               message:@"User is not authorised for this operation."
                                                              delegate:nil
                                                     cancelButtonTitle:@"Dismiss"
                                                     otherButtonTitles: nil];
                [alert show];
                
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                               message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription]
                                                              delegate:nil
                                                     cancelButtonTitle:@"Dismiss"
                                                     otherButtonTitles: nil];
                [alert show];
                
            }
            completion(nil);
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                       message:@"Please specify a drupal site first"
                                                      delegate:nil
                                             cancelButtonTitle:@"Dismiss"
                                             otherButtonTitles: nil];
        [alert show];
    }

}

+(void)uploadFilewithFileName:(NSString *)fileName
                andDataString:(NSString *)base64EncodedString
                     withView:(UIView *)view{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    hud.dimBackground = YES;
    hud.labelText = @"Uploading file ...";
    hud.delegate = nil;
    [hud show:YES];
    NSDictionary *params = @{
                             @"filename":@[@{@"value":fileName}],
                             @"data":@[@{@"value":base64EncodedString}]};
    // This is temporary work around for 200 response code instead of 201 , the drupal responds with text/html format here we explicitly ask for JSON so that AFNwteorking will not report error
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    [sharedSession.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [DIOSEntity createEntityWithEntityName:@"file" type:@"file" andParams:params
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       // This is temporary work around for 200 response code instead of 201
                                       [sharedSession.requestSerializer setValue:nil forHTTPHeaderField:@"Accept"];
                                       
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
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       
                                       // This is temporary work around for 200 response code instead of 201
                                       [sharedSession.requestSerializer setValue:nil forHTTPHeaderField:@"Accept"];
                                       
                                       [hud hide:YES];
                                       
                                       long statusCode = operation.response.statusCode;
                                       // This can happen when POST is with out Authorization details
                                       if (statusCode == 401) {
                                           DIOSSession *sharedSession = [DIOSSession sharedSession];
                                           
                                           sharedSession.signRequests = NO;
                                           
                                           User *sharedUser = [User sharedInstance];
                                           [sharedUser clearUserDetails];
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                          message:@"Please verify login credentials." delegate:nil
                                                                                cancelButtonTitle:@"Dismiss"
                                                                                otherButtonTitles: nil];
                                           [alert show];
                                       }
                                       
                                       else if( statusCode == 0 ) {
                                           
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"]
                                                                                          message:@"Plese specify a Drupal 8 site first \n"
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"Dismiss"
                                                                                otherButtonTitles:nil];
                                           [alert show];
                                           
                                       }
                                       
                                       // Credentials are valid but user is not permitted to certain operation.
                                       else if(statusCode == 403){
                                           
                                           
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                          message:@"User is not authorised for this operation."
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"Dismiss"
                                                                                otherButtonTitles: nil];
                                           [alert show];
                                       }
                                       else{
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                          message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription]
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"Dismiss"
                                                                                otherButtonTitles: nil];
                                           [alert show];
                                           
                                       }
                                   }];
}

+(void)verifyDrupalSite: (NSURL *)drupalSiteURL
               withView: (UIView *)view
             completion:(void (^)(BOOL verified))completion{
    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    
    hud.delegate = nil;
    hud.labelText = @"Verifying Drupal 8 site";
    [hud show:YES];
    // a valid URL according to RFC 2396 RFCs 1738 and 1808
    
    // store the URL String to user's default settings
    
    // Validate the remote host with NSURLConnection
    
    // Validating URL with drupal-ios-sdk
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    sharedSession.baseURL = drupalSiteURL;
    
    /* Vivek: By default, DIOSSession has AFJSONResponseSerializer which causes a http-based response
     *  with status code 2XX to be an unacceptable response type.
     *  So to execute the request we change ResponseSerializer temporarely
     *
     */
    [sharedSession setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    sharedSession.signRequests = NO;
    
    [sharedSession GET:[drupalSiteURL absoluteString]
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Currently this storage per user
        // storing a validated D8 site to user preferences
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[drupalSiteURL absoluteString] forKey:DRUPAL8SITE];
        sharedSession.signRequests = YES;
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
            if (completion) {
                completion(YES);
            }
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [hud hide:YES];
        // Display alert on faliure
        long statusCode = operation.response.statusCode;
        
        if ( statusCode == 403 ) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS"
                                                           message:[NSString stringWithFormat:@"Error with %@ . It seems that you are already logged in to other site.",error.localizedDescription]
                                                          delegate:self
                                                 cancelButtonTitle:@"Dismiss"
                                                 otherButtonTitles: nil];
            [alert show];
            
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS"
                                                           message:[NSString stringWithFormat:@"An error occured while connecting to the URL with %@",error.localizedDescription]
                                                          delegate:self
                                                 cancelButtonTitle:@"Dismiss"
                                                 otherButtonTitles: nil];
            [alert show];
        }
        completion(NO);
        
    }];
    
    // Restore the ResponseSerializer to JSONSerializer
    [sharedSession setResponseSerializer:[AFJSONResponseSerializer serializer]];

    
}

+(void)createUserAccountwithUserName:(NSString *)userName
                            password:(NSString *)password
                            andEmail:(NSString *)email
                            withView:(UIView *)view{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    
    hud.delegate = nil;
    hud.labelText = @"Creating Account";
    [hud show:YES];
    
    User *sharedUser = [User sharedInstance];
    if ( sharedUser.name !=nil && ![sharedUser.name isEqualToString:@""] ) {
        // A user is already logged in
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Information"
                                                       message:@"You are already logged in."
                                                      delegate:nil
                                             cancelButtonTitle:@"Dissmiss"
                                             otherButtonTitles:nil];
        [alert show];
    }
    else {
        // Creating NSDictionary for JSON body on the fly
        NSDictionary *JSONBody =  @{
                                    @"langcode": @[
                                            @{
                                                @"value": @"en"}
                                            ],
                                    @"name": @[
                                            @{
                                                @"value": userName
                                                }
                                            ],
                                    @"mail": @[
                                            @{
                                                @"value": email
                                                }
                                            ],
                                    @"pass": @[
                                            @{
                                                @"value": password
                                                }
                                            ]
                                    };
        
        [DIOSUser createUserWithParams:JSONBody
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Congratulations!"
                                                           message:@"Your account has been created. Further details will be mailed by application server."
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
            [hud hide:YES];
        }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [hud hide:YES];
            
            NSInteger statusCode  = operation.response.statusCode;
            
            if ( statusCode == 403 ) {
                
                // After https://www.drupal.org/node/2291055 is solved we do not need this block of code
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Credentials"
                                                               message:@"User is not authorised for this operation."
                                                              delegate:nil
                                                     cancelButtonTitle:@"Dismiss"
                                                     otherButtonTitles:nil];
                [alert show];
            }
            else if( statusCode == 0 ) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"]
                                                               message:@"Plese specify a Drupal 8 site first \n"
                                                              delegate:nil
                                                     cancelButtonTitle:@"Dismiss"
                                                     otherButtonTitles:nil];
                [alert show];
                
            }
            else {
                // Email and Password change requires existing password to be specified.
                // The code above tries to capture those requirements.  If it is missed then
                // Drupal REST will provide propper error and that will be reflected by this alert
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                               message:[NSString stringWithFormat:@"Error while creating user with %@",error.localizedDescription]
                                                              delegate:nil
                                                     cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
    
}

+(void)updateUserAccoutwithUserName: (NSString *)userName
                    currentPassword:(NSString *)currentPass
                              email:(NSString *)email
                revisedUserPassword:(NSString *)revisedUserPassword
                           withView:(UIView *)view{
    User *sharedUser = [User sharedInstance];
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    
    if ( [revisedUserPassword isEqualToString:@""] && [userName isEqualToString:@""] && [email isEqualToString:@""] ) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Information"
                                                       message:@"Please provide value for atleast one filed to be change."
                                                      delegate:nil
                                             cancelButtonTitle:@"Dissmiss"
                                             otherButtonTitles:nil];
        [alert show];
        
    }
    else {
        
        if ( sharedUser.name != nil && ![sharedUser.name  isEqual: @""] ) {
            
            if ( currentPass != nil && ![currentPass isEqualToString:@""] ) {
                
                NSError __block *sgKeyChainError = nil;
                
                // [0] = username
                // [1] = password
                NSMutableArray __block *credentials = [[SGKeychain usernamePasswordForServiceName:@"Drupal 8"
                                                                                      accessGroup:nil
                                                                                            error:&sgKeyChainError] mutableCopy];
                
                if ( [credentials[1] isEqualToString:currentPass] ) {
                    
                    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:view];
                    [view addSubview:hud];
                    
                    hud.delegate = nil;
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
                    NSMutableDictionary *valueForPass = [[NSMutableDictionary alloc]initWithObjects: @[currentPass]
                                                                                            forKeys:@[@"existing"]];
                    NSArray *passArray;
                    
                    
                    if ( userName !=nil && ![userName isEqualToString:@""] ) {
                        // create dictionary   {"value":"somevalue"}
                        valueForName = [[NSDictionary alloc]initWithObjects:@[userName] forKeys:@[@"value"]];
                        // create array [{"value":"somevalue"}]
                        nameArray = [[NSArray alloc]initWithObjects:valueForName, nil];
                        
                    }
                    
                    if ( email !=nil && ![email isEqualToString:@""] ) {
                        
                        //create dictionary {"value":"marthinal@drupalisawesome.com"}
                        valueForMail = [[NSDictionary alloc]initWithObjects:@[email]
                                                                    forKeys:@[@"value"]];
                        
                        // create mail array [{"value":"marthinal@drupalisawesome.com"}]
                        mailArray = [[NSArray alloc]initWithObjects:valueForMail, nil];
                        
                    }
                    
                    if ( revisedUserPassword != nil && ![revisedUserPassword isEqualToString:@""] ) {
                        // create dictionary {"existing":"existingSecretPass", "value": "myNewSuperSecretPass"}
                        [valueForPass setObject:revisedUserPassword
                                         forKey:@"value"];
                        
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
                    
                    [DIOSUser patchUserWithID:sharedUser.uid params:params
                                         type:@"user"
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        /* Vivek: If PATCH is successfull then we may have changed any combinations of
                         *  username, password, email. So, we need to update sharedUser and credentials on
                         *  sharedSession accordingly.
                         */
                        
                        [SGKeychain deletePasswordandUserNameForServiceName:@"Drupal 8"
                                                                accessGroup:nil
                                                                      error:&sgKeyChainError];
                        
                        sharedUser.email = (email != nil && ![email isEqualToString:@""]) ? email : sharedUser.email ;
                        
                        if ( userName != nil && ![userName isEqualToString:@""] ) {
                            
                            credentials[0] = userName;
                            sharedUser.name = userName;
                            
                        }
                        
                        /* uncomment this portion when bug 2552099 is solved
                         if (revisedUserPassword != nil && ![revisedUserPassword isEqualToString:@""]) {
                         
                         credentials[1] = revisedUserPassword;
                         
                         }
                         
                         */
                        
                        [SGKeychain setPassword:credentials[1]
                                       username:credentials[0]
                                    serviceName:@"Drupal 8"
                                    accessGroup:nil
                                 updateExisting:NO
                                          error:&sgKeyChainError];
                        
                        [sharedSession setBasicAuthCredsWithUsername:credentials[0]
                                                         andPassword:credentials[1]];
                        
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
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                           message:@"User is not authorised for this operation."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"Dismiss"
                                                                 otherButtonTitles:nil];
                            [alert show];
                        }
                        else if (statusCode == 401) {
                            User *user = [User sharedInstance];
                            [user clearUserDetails];
                            DIOSSession *sharedSession = [DIOSSession sharedSession];
                            sharedSession.signRequests = NO;
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                           message:@"Please verify login credentials first."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"Dismiss"
                                                                 otherButtonTitles:nil];
                            [alert show];
                            
                        }
                        else if ( statusCode == 0 ) {
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"]
                                                                           message:@"Plese specify a Drupal 8 site first \n"
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"Dismiss"
                                                                 otherButtonTitles:nil];
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
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                   message:@"Entered current password didn't matched with one stored in application!"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Dissmiss"
                                                         otherButtonTitles:nil];
                    [alert show];
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Information"
                                                               message:@"Please provide your current password."
                                                              delegate:nil
                                                     cancelButtonTitle:@"Dissmiss"
                                                     otherButtonTitles:nil];
                [alert show];
                
            }
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Information"
                                                           message:@"Please first login to your account."
                                                          delegate:nil
                                                 cancelButtonTitle:@"Dissmiss"
                                                 otherButtonTitles:nil];
            [alert show];
            
        }
    }


}

+(void)loginwithUserName:(NSString *)userName
                password:(NSString *)password
                withView:(UIView *)view
              completion:(void (^)(NSMutableDictionary *))completion{
    
    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    
    hud.delegate = nil;
    hud.labelText = @"Logging in";
    [hud show:YES];
    
    /*
     *  Login with Kyle's iOS-SDK
     */
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    [sharedSession setBasicAuthCredsWithUsername:userName andPassword:password];
    NSString *basicAuthString = [self basicAuthStringforUsername:userName Password:password];
    
    [DIOSView getViewWithPath:@"user/details"
                       params:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *userDictionary = [responseObject mutableCopy];
        [userDictionary addEntriesFromDictionary:@{@"basicAuthString":basicAuthString}];
        NSError *setPasswordError = nil;
        [SGKeychain setPassword:password
                       username:userName
                    serviceName:@"Drupal 8"
                    accessGroup:nil
                 updateExisting:YES
                          error:&setPasswordError];
        
        DIOSSession * session =  [DIOSSession sharedSession];
        [session setBasicAuthCredsWithUsername:userName
                                   andPassword:password];
        [hud hide:YES];
        
        if ( userDictionary != nil ) {
            D8D(@"userDictionary %@", userDictionary );
            }
                          if (completion) {
                              completion(userDictionary);
                          }
    }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSInteger statusCode  = operation.response.statusCode;
        [hud hide:YES];
        
        if ( statusCode == 403 ) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Credentials"
                                                           message:@"Please check username and password."
                                                          delegate:nil
                                                 cancelButtonTitle:@"Dismiss"
                                                 otherButtonTitles:nil];
            [alert show];
            
        }
        else if ( statusCode == 0 ) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"]
                                                           message:@"Plese specify a Drupal 8 site first \n"
                                                          delegate:nil
                                                 cancelButtonTitle:@"Dismiss"
                                                 otherButtonTitles:nil];
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Error with code %ld",(long)statusCode]
                                                           message:@"Please contact website admin."
                                                          delegate:nil
                                                 cancelButtonTitle:@"Dismiss"
                                                 otherButtonTitles:nil];
            [alert show];
        }
        
                          if (completion) {
                              completion(nil);
                          }
                
    }];


}

+(NSString *)basicAuthStringforUsername:(NSString *)username Password:(NSString *)password{
    
    NSString * userNamePasswordString = [NSString stringWithFormat:@"%@:%@",username,password]; // "username:password"
    NSData *userNamePasswordData = [userNamePasswordString dataUsingEncoding:NSUTF8StringEncoding]; // NSData object for base64encoding
    NSString *base64encodedDataString = [userNamePasswordData base64EncodedStringWithOptions:0]; // this will be something like "3n42hbwer34+="
    
    
    NSString * basicAuthString = [NSString stringWithFormat:@"Basic %@",base64encodedDataString]; // example set "Authorization header "Basic 3cv%54F0-34="
    
    return  basicAuthString;
    
}

+(void)deleteFilewithFileID:(NSString *)fileID
                   withView:(UIView *)view
                 completion:(void (^)(BOOL))completion{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    
    hud.dimBackground = YES;
    hud.labelText = @"Deleting file ...";
    hud.delegate = nil;
    [hud show:YES];
    [DIOSEntity deleteEntityWithEntityName:@"file" andID:fileID
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
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
                                       if (completion) {
                                           completion(YES);
                                       }
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       
                                       [hud hide:YES];
                                       
                                       long statusCode = operation.response.statusCode;
                                       // This can happen when GET is with out Authorization details
                                       if (statusCode == 401) {
                                           DIOSSession *sharedSession = [DIOSSession sharedSession];
                                           
                                           sharedSession.signRequests = NO;
                                           
                                           User *sharedUser = [User sharedInstance];
                                           [sharedUser clearUserDetails];
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                          message:@"Please verify the login credentials."
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"Dismiss"
                                                                                otherButtonTitles: nil];
                                           [alert show];
                                       }
                                       
                                       // Credentials sent with request is invalid
                                       else if ( statusCode == 403 ){
                                           
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                          message:@"User is not authorised for this operation."
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"Dismiss"
                                                                                otherButtonTitles: nil];
                                           [alert show];
                                       }
                                       else {
                                           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                          message:[NSString
                                                                                                   stringWithFormat:@"Error with %@",error.localizedDescription]
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"Dismiss"
                                                                                otherButtonTitles: nil];
                                           [alert show];
                                           
                                       }
                                       if (completion) {
                                            completion(NO);
                                       }
                                       
                                   }];

}

+(void)getArticlewithNodeID:(NSString *)nodeID
                   withView:(UIView *)view
                 completion:(void (^)(NSMutableDictionary *))completion{
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    /*  Vivek: I have used NSUserDefaults to store DRUPAL8SITE because it is not sensitive data
     *  like password. So, according to Apple it is OK to use, but in the future for some professional app.
     *  If it is required to store Drupal site information per User than it would be better to use a
     *  simple framework based on Keychain access to sperate each user's data.
     */
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
    sharedSession.baseURL = baseURL;
    
    if ( sharedSession.baseURL != nil ) {
        
        MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        
        hud.delegate = nil;
        hud.labelText = @"Loading article";
        [hud show:YES];
        
        [DIOSNode getNodeWithID:nodeID
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSMutableDictionary *articleDict = (NSMutableDictionary *)responseObject;
            [hud hide:YES];
            if (completion) {
                completion(articleDict);
            }
            
        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [hud hide:YES];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                           message:[NSString stringWithFormat:@"Error while loading article with %@ ",error.localizedDescription]
                                                          delegate:nil
                                                 cancelButtonTitle:@"Dismiss"
                                                 otherButtonTitles: nil];
            [alert show];
            if (completion) {
                completion(nil);
            }
        }];
    }


}


@end
