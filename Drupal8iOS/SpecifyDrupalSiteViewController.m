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
/* Vivek: Actually there is no such provision in this code to determine if this is a valid D8 site.
 *  It just checks if device is able to connect (i.e 200 OK http status) to web site specified.
 *  Ideally a Drupal 8 REST module's responsibility is to enable one publically accesible end point,
 *  and its URL pattern should be some standard documented on drupal.org for example /node/verify .
 *  So then app can call GET on this specific URL, and the the PHP code on the server will verify
 *  that REST and related modules are enabled and based on that it will return some status code
 *  in response. By using this endpoint we can verify that this is Drupal 8 or not.
 *  There may be better way, perhaps based on response headers. This point may require
 *  discussion with some very experienced, D8 community people.
 */

#import "SpecifyDrupalSiteViewController.h"
#import "Developer.h"// MAS: for development only, see which
#import "DIOSSession.h"
#import "DIOSView.h"
#import "D8iOS.h"


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
    if ( url != nil ) {
        if( url && url.scheme && url.host ) {
            [D8iOS verifyDrupalSite:url withView:self.view completion:^(BOOL verified) {
                if (verified) {
                    [self.statusInfoLabel setText:self.userSiteRequest.text];
                    NSAttributedString *attributeStatus = [[NSAttributedString alloc]
                                                           initWithString:@"OK"
                                                           attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.1
                                                                                                                       green:2.0
                                                                                                                        blue:0.0
                                                                                                                       alpha:1.000]}];
                    [self.connectionStatusLabel setAttributedText:attributeStatus];

                }
                else{
                    NSAttributedString *attributeStatus = [[NSAttributedString alloc]
                                                           initWithString:@"FAILED"
                                                           attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:1.0
                                                                                                                       green:0.0
                                                                                                                        blue:0.0
                                                                                                                       alpha:1.000]}];
                    [self.connectionStatusLabel setAttributedText:attributeStatus];
                
                }
            }];
            
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS"
                                                           message:@"Please enter a valid URL hostname, scheme etc. "
                                                          delegate:self
                                                 cancelButtonTitle:@"Dismiss"
                                                 otherButtonTitles: nil];
            [alert show];
            NSAttributedString *attributeStatus = [[NSAttributedString alloc] initWithString:@"..."
                                                                                  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.0
                                                                                                                                              green:0.0
                                                                                                                                               blue:0.0
                                                                                                                                              alpha:1.000]}];
            [self.connectionStatusLabel setAttributedText:attributeStatus];

        }
    }
    else {
    
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Drupal8iOS"
                                                       message:@"BAD URL"
                                                      delegate:self
                                             cancelButtonTitle:@"Dismiss"
                                             otherButtonTitles: nil];
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

@end
