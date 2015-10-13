//
//  ViewArticleViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/15/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/*  MAS:
 *  This displays the details of an article selected from the referencing 
 *  table cell in the VeiwArticleTableVeiwController.  This is where the user
 *  can submit comments if permissions are granted.
 */

/* Vivek: Drupal comments can have full HTML content so we have to use UIWebView
 *  to display it. But this will be little tricky as it supports multiple level in trems of 
 *  reply.  Also here I am thinking to use / create a code that can be reused for such situaltions, 
 *  probably creating a class or categoty on UIWebView that can hold, fetch comments for a node. 
 */

#import "ViewArticleViewController.h"
#import <AFNetworking.h>
#import <UIAlertView+AFNetworking.h>
#import <DIOSSession.h>
#import <DIOSNode.h>
#import <DIOSComment.h>
#import "Developer.h"
#import "CommentsTableViewController.h"
#import "User.h"
#import "AddCommentViewController.h"

@interface ViewArticleViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;


@end

@implementation ViewArticleViewController
- (IBAction)addComment:(id)sender {
    
    UIAlertView *commentInputAlertView = [[UIAlertView alloc]initWithTitle:@"Add Comment" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [commentInputAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [commentInputAlertView show];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.article != nil) {
        
    }
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    /*  Vivek: I have used NSUserDefaults to store DRUPAL8SITE because it is not sensitive data
     *  like password. So according to Apple it is OK to use. But, in future for some professional app.
     *  If it is required to store drupal site information per User than it would be better to use a 
     *  simple framework based on Keychain access to sperate each user's data.
     */
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
    sharedSession.baseURL = baseURL;
    
    if( sharedSession.baseURL != nil ){
        
        MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        
        hud.delegate = self;
        hud.labelText = @"Loading article";
        [hud show:YES];
        
        [DIOSNode getNodeWithID:self.article.nid success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSMutableDictionary *articleDict = (NSMutableDictionary *)responseObject;
            
            [self.titleLabel setText:self.article.title];
            [self.lastUpdatedLabel  setText:self.article.changed];
            [self.contentWebView loadHTMLString:[[[articleDict objectForKey:@"body"]  objectAtIndex:0] objectForKey:@"value"] baseURL:[baseURL URLByDeletingLastPathComponent]];
            // need to check on specifying base URL
            [hud hide:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [hud hide:YES];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error while loading article with %@ ",error.localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if( [segue.identifier isEqualToString:@"showComments"] ) {
        
        CommentsTableViewController *destinationViewController = (CommentsTableViewController *) segue.destinationViewController;
        
        destinationViewController.nid = self.article.nid;
        
    
    }
    else if( [segue.identifier isEqualToString:@"postComment"] ) {
        
        UINavigationController *destinationViewController = (UINavigationController *) segue.destinationViewController;
        NSArray *viewControllers = destinationViewController.viewControllers;
        AddCommentViewController *rootViewController = (AddCommentViewController *)[viewControllers objectAtIndex:0];
        rootViewController.nid = self.article.nid;
        
    }
}


//-(void)alertView:(nonnull UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//
//    [self postComment:[[alertView textFieldAtIndex:0] text]];
//
//
//
//}
//
//-(void)postComment:(NSString *)comment{
//    
//    User *user = [User sharedInstance];
//    
//    
// /* Vivek: <#Note#> This JSON request works fine with my 8.0.x branch but this does not currently work on beta14
//  *              I am looking into this. But I sespect that this code will not require change. It must be some patch required on Drupal side.
//  */
//    
//  NSDictionary *params=
//      @{
//          
//          @"entity_id": @[
//                        @{
//                            @"target_id": self.article.nid
//                        }
//                        ],
//          @"subject": @[
//                     @{
//                          @"value": comment
//                      }],
//          
//          @"uid":@[
//                @{
//                     
//                     @"target_id":user.uid
//                 }
//                 ],
//          @"status": @[
//                     @{
//                         @"value": @"1"
//                     }
//                     ],
//          @"entity_type": @[
//                          @{
//                              @"value": @"node"
//                          }
//                          ],
//          @"comment_type": @[
//                           @{
//                               @"target_id": @"comment"
//                           }
//                           ],
//          @"field_name": @[
//                         @{
//                             @"value": @"comment"
//                         }
//                         ],
//          @"comment_body": @[
//                           @{
//                               @"value":comment
//                           }
//                           ]
//          };
//    
//    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//    [self.navigationController.view addSubview:hud];
//    
//    hud.delegate = self;
//    hud.labelText = @"Posting comment...";
//    [hud show:YES];
//    [DIOSComment createCommentWithParams:params relationID:self.article.nid type:@"comment" success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        
//        UIImageView *imageView;
//        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
//        imageView = [[UIImageView alloc] initWithImage:image];
//        
//        hud.customView = imageView;
//        hud.mode = MBProgressHUDModeCustomView;
//        
//        hud.labelText = @"Completed";
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // need to put main theread on sleep for 2 second so that "Completed" HUD stays on for 1 seconds
//            sleep(1);
//            [hud hide:YES];
//        });
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [hud hide:YES];
//        
//        NSInteger statusCode  = operation.response.statusCode;
//        
//        if ( statusCode == 403 ){
//            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"User is not authorised for this operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//            [alert show];
//            
//            
//            
//        }
//        else if(statusCode == 401){
//            User *user = [User sharedInstance];
//            [user clearUserDetails];
//            DIOSSession *sharedSession = [DIOSSession sharedSession];
//            sharedSession.signRequests = NO;
//            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify login credentials first." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//            [alert show];
//            
//        }
//        else if( statusCode == 0 ){
//            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"] message:@"Plese specify a Drupal 8 site first \n" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//            [alert show];
//            
//        }
//        
//        else {
//           
//            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
//                                                           message:[NSString stringWithFormat:@"Error while posting the comment with error code %@",error.localizedDescription]
//                                                          delegate:nil
//                                                 cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
//            
//            [alert show];
//        }
//
//        
//    }];
//    
//    
//}

@end
