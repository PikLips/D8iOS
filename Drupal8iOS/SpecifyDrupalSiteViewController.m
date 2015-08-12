//
//  SpecifyDrupalSiteViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS: *****************************************************************************
 *************        For Vivek to code here to END  ----       *********************
 *************  Code this as you see fit.                       *********************
 *************  We will tie the logic into the UI.              *********************/

#import "SpecifyDrupalSiteViewController.h"
#import "Developer.h"  // MAS: for development only, see which

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
        // a valid URL according to RFC 2396 RFCs 1738 and 1808
        // store the URL String to user's default settings
            
        // Validate the remote host
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

            
            
            
        }
        else{
            
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS" message:@"Please enter a valid URL hostname, scheme etc. " delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            NSAttributedString *attributeStatus = [[NSAttributedString alloc] initWithString:@"..." attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.000]}];
            [self.connectionStatusLabel setAttributedText:attributeStatus];

            
        }
        
        
        
    }
    else{
    
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS" message:@"BAD URL" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.statusInfoLabel setText:[defaults objectForKey:@"drupal8site"] ?:@"None" ];
    
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
