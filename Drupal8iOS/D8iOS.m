//
//  D8iOS.m
//  Drupal8iOS
//
//  Created by Michael Smith on 10/16/15.
//  Copyright © 2015 PikLips. All rights reserved.
//  Written by Vivek Pandya
//

#import "D8iOS.h"
#import "DIOSSession.h"
#import "DIOSEntity.h"
#import "User.h"

@implementation D8iOS

+ (void) uploadImageToServer: (PHAsset *) asset withImage: (UIImageView *) assetImage withinView: (UIViewController *)navController {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:navController.view];
    [navController.view addSubview:hud];
    
    hud.dimBackground = YES;
    hud.labelText = @"Uploading image ...";
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    hud.delegate = self;  //MAS: problem: this is for an instance object instead of a class
    
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


@end
