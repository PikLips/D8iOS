//
//  SpecifyDrupalSiteViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS: 
 *  This provides a way for the user to specify the URL of the Drupal 8
 *  website that will act as this apps back-end.
 */

#import "SpecifyDrupalSiteViewController.h"
#import "Developer.h"// MAS: for development only, see which
#import "DIOSSession.h"
#import "DIOSView.h"


@interface SpecifyDrupalSiteViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userSiteRequest; // MAS: user input that require local format validation and remote confirmation

@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *statusInfoLabel;

@end

@implementation SpecifyDrupalSiteViewController

- (IBAction)checkDrupalSite:(id)sender {
    // If required this code can be dispatch on a separate thread to get more performance
    // check logic goes here
    NSURL *url = [NSURL URLWithString:self.userSiteRequest.text];
    if (url != nil) {
        if(url && url.scheme && url.host){
/* Vivek: Actually there is no such provision in this code to determine if this is a valid D8 site.
 *  It just checks if device is able to connect (i.e 200 OK http status) to web site specified. 
 *  Ideally a Drupal 8 REST module's responsibility is to enable one publically accisible end point, 
 *  and its URL pattern should be some standard documented on drupal.org for example /node/verify . 
 *  So then app can call GET on this specific URL, and the the PHP code on the server will verify 
 *  that REST and related modules are enabled and based on that it will return some status code 
 *  in response. By using this endpoint we can verify that this is Drupal 8 or not.
 *  There may be better way, perhaps based on response headers. This point may require
 *  discussion with some very experienced, D8 community people.
 */
            
         MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:hud];
            
            hud.delegate = self;
            hud.labelText = @"Verifying Drupal 8 site";
            [hud show:YES];
        // a valid URL according to RFC 2396 RFCs 1738 and 1808
            
        // store the URL String to user's default settings
            
        // Validate the remote host with NSURLConnection
        /*
            NSURLResponse *response=nil;
            NSError *error=nil;
            NSData *data = nil;
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if( error == nil ){
            
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                
                if (httpResponse.statusCode == 200) {
                    
                    // Currently this storage per user
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:self.userSiteRequest.text forKey:DRUPAL8SITE];
                    [self.statusInfoLabel setText:self.userSiteRequest.text];
                    NSAttributedString *attributeStatus = [[NSAttributedString alloc] initWithString:@"OK" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.1 green:2.0 blue:0.0 alpha:1.000]}];
                    [self.connectionStatusLabel setAttributedText:attributeStatus];

                    
                }
                else{
                
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS" message:[NSString  stringWithFormat:@"An attempt to connect the URL failed with %i status code",httpResponse.statusCode] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                    NSAttributedString *attributeStatus = [[NSAttributedString alloc] initWithString:@"FAILED" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.000]}];
                    [self.connectionStatusLabel setAttributedText:attributeStatus];
                    
                }
                
            }
            else{
            
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS" message:@"An error occured while connecting to the URL"  delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [alert show];
                NSAttributedString *attributeStatus = [[NSAttributedString alloc] initWithString:@"FAILED" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.000]}];
                [self.connectionStatusLabel setAttributedText:attributeStatus];
            }

         */
         
         // Validating URL with drupal-ios-sdk
            
            DIOSSession *sharedSession = [DIOSSession sharedSession];
            sharedSession.baseURL = url;
            
            /* Vivek: By default, DIOSSession has AFJSONResponseSerializer which causes a http-based response
             *  with status code 2XX to be an unacceptable response type.
             *  So to execute the request we change ResponseSerializer temporarely
             *
             */
            [sharedSession setResponseSerializer:[AFHTTPResponseSerializer serializer]];
           
            sharedSession.signRequests = NO;
            
            
            [sharedSession GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                    // Currently this storage per user
                    // storing a validated D8 site to user preferences
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:self.userSiteRequest.text forKey:DRUPAL8SITE];
                    [self.statusInfoLabel setText:self.userSiteRequest.text];
                
                    NSAttributedString *attributeStatus = [[NSAttributedString alloc] initWithString:@"OK" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.1 green:2.0 blue:0.0 alpha:1.000]}];
                    [self.connectionStatusLabel setAttributedText:attributeStatus];
              
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
                });
            
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [hud hide:YES];
                // Display alert on faliure
                long statusCode = operation.response.statusCode;
                
                if ( statusCode == 403 ) {
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS" message:[NSString stringWithFormat:@"Error with %@ . It seems that you are already logged in to other site.",error.localizedDescription]  delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];

                }
                else {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS" message:[NSString stringWithFormat:@"An error occured while connecting to the URL with %@",error.localizedDescription]  delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [alert show];
                }
                NSAttributedString *attributeStatus = [[NSAttributedString alloc] initWithString:@"FAILED" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.000]}];
                [self.connectionStatusLabel setAttributedText:attributeStatus];
                
            }];
           
            // Restore the ResponseSerializer to JSONSerializer
            [sharedSession setResponseSerializer:[AFJSONResponseSerializer serializer]];
            
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS" message:@"Please enter a valid URL hostname, scheme etc. " delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            NSAttributedString *attributeStatus = [[NSAttributedString alloc] initWithString:@"..." attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.000]}];
            [self.connectionStatusLabel setAttributedText:attributeStatus];

            
        }
    }
    else {
    
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS" message:@"BAD URL" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.statusInfoLabel setText:[defaults objectForKey:@"drupal8site"] ?:@"None" ];
    [self.userSiteRequest setText:[defaults objectForKey:@"drupal8site"]?:@""];
    
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
