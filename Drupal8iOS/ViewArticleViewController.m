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
 *  to display it. But this will be little tricky as it supports multiple level in terms of
 *  reply.  Also here, I am thinking to use / create code that can be reused for such situaltions,
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
#import "D8iOS.h"
#import "MBProgressHUD.h"
#import "NotifyViewController.h"

@interface ViewArticleViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;
@property (nonatomic,strong) MBProgressHUD *hud;

@end

@implementation ViewArticleViewController
-(IBAction)addComment:(id)sender {
    
    UIAlertView *commentInputAlertView = [[UIAlertView alloc]initWithTitle:@"Add Comment" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [commentInputAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [commentInputAlertView show];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    if (self.article != nil) {
        
    }
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    /**  Vivek: I have used NSUserDefaults to store DRUPAL8SITE because it is not sensitive data
     *  such as the password. So, according to Apple it is OK to use, but in the future for some professional app.
     *  If it is required to store Drupal site information per User than it would be better to use a
     *  simple framework based on Keychain access to sperate each user's data.
     */
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
    sharedSession.baseURL = baseURL;
    
    if ( sharedSession.baseURL != nil ) {
    // GET on node
        [self toggleSpinner:YES];
        [D8iOS getArticlewithNodeID:self.article.nid
                            success:^(NSMutableDictionary *articleDetails) {
                                [self toggleSpinner:NO];
                                if (articleDetails != nil) {
                                    [self.titleLabel setText:self.article.title];
                                    [self.lastUpdatedLabel  setText:self.article.changed];
                                    [self.contentWebView loadHTMLString:[[[articleDetails objectForKey:@"body"]  objectAtIndex:0] objectForKey:@"value"] baseURL:[sharedSession.baseURL URLByDeletingLastPathComponent]];
                                }
            
        }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [self toggleSpinner:NO];
                                [self presentViewController:[NotifyViewController zeroStatusCodeNotifyError:error.localizedDescription]
                                                   animated:YES
                                                 completion:nil];
            
        }];
        
    }
    
    
//    DIOSSession *sharedSession = [DIOSSession sharedSession];
//
//    [D8iOS getArticlewithNodeID:self.article.nid withView:self.view completion:^(NSMutableDictionary *articleDetails) {
//        if (articleDetails != nil) {
//            [self.titleLabel setText:self.article.title];
//            [self.lastUpdatedLabel  setText:self.article.changed];
//            [self.contentWebView loadHTMLString:[[[articleDetails objectForKey:@"body"]  objectAtIndex:0] objectForKey:@"value"] baseURL:[sharedSession.baseURL URLByDeletingLastPathComponent]];
//        }
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** @function toggleSpinner: (bool) on
 *  @param on A bool indicating whether the activity indicator should be on or off.
 *  @abstract This implements MBProgressHUB as an alternative to UIActivityIndicatorView .
 *  @seealso https://github.com/jdg/MBProgressHUD
 *  @discussion This needs to be a Cocoapod and abstracted into its own class with specific objects
 *              for each use (more illustrative).
 *  @return N/A
 *  @throws N/A
 *  @updated
 *
 */

-(void)toggleSpinner:(bool) on {
    if ( on ) {
        _hud = [[MBProgressHUD alloc ] initWithView:super.view];
        [super.view addSubview:_hud];
        _hud.delegate = nil;
        _hud.labelText = @"Loading the article";
        [_hud show:YES];
    }
    else {
        [_hud hide:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
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
@end
