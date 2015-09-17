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

// MAS:Vivek - how will you incorporate comments here?  Will it be a modal view?
// Vivek:MAS - Well, Drupal comments can have full HTML content so we have to use UIWebView to display it. But this will be little tricky as it supports multiple level in trems of reply. I tried to connect some people on IRC about meximum depth supported by comment but no good reply. I am trying on this. Also here I am thinking to use / create a code that can be reused for such situaltions, probably creating a class or categoty on UIWebView that can hold, fetch comments for a node. I will let you know when I will have some concrete work on this.

#import "ViewArticleViewController.h"
#import <AFNetworking.h>
#import <UIAlertView+AFNetworking.h>
#import <DIOSSession.h>
#import <DIOSNode.h>
#import "Developer.h"

@interface ViewArticleViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;


@end

@implementation ViewArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.article != nil) {
// MAS:Vivek - will this code be used?
// Vivek:MAS - I was just testing If Is it better to fetch Article details after view has been loaded or fetch it before view is loaded.
//             And with viewWillAppear it works fine. You may remove this code. I have kept it just for reference.
 
        
        
// ***************** <#This code can fetch node details with plain AFNetworking, it does not require drupal-ios-sdk #> *******************

        
//        AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
//        
//        [sessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
//        [sessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
//        
//        NSString *nodeURL = [NSString stringWithFormat:@"%@%@", @"http://localhost/dr8b12/node/", self.article.nid];
//        
//        
//        NSURLSessionDataTask *getNodeData = [sessionManager GET:nodeURL parameters:@{@"_format":@"hal_json"} success:^(NSURLSessionDataTask *task, id responseObject) {
//            
//            NSMutableDictionary *articleDict = (NSMutableDictionary *)responseObject;
//            
//            [self.titleLabel setText:self.article.title];
//            [self.lastUpdatedLabel  setText:self.article.changed];
//            [self.contentWebView loadHTMLString:[[[articleDict objectForKey:@"body"]  objectAtIndex:0] objectForKey:@"value"] baseURL:[NSURL URLWithString:@"http://localhost"]];
//            
//        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            NSLog(@"%@",error.description);
//        }];
//        
//        
//        [UIAlertView showAlertViewForTaskWithErrorOnCompletion:getNodeData delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        
  // ***************** <# This code uses drupal-io-sdk #> *******************
        
//        DIOSSession *sharedSession = [DIOSSession sharedSession];
//        
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:@DRUPAL8SITE]];
//        
//        sharedSession.baseURL = baseURL;
//        if(sharedSession.baseURL != nil){
//        
//           [DIOSNode getNodeWithID:self.article.nid success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                NSMutableDictionary *articleDict = (NSMutableDictionary *)responseObject;
//                
//                            [self.titleLabel setText:self.article.title];
//                            [self.lastUpdatedLabel  setText:self.article.changed];
//                            [self.contentWebView loadHTMLString:[[[articleDict objectForKey:@"body"]  objectAtIndex:0] objectForKey:@"value"] baseURL:[NSURL URLWithString:@"http://localhost"]];
//
//                
//                
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                
//            }];
//            
//            
//            
//                                                 }
        

        
    }

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    // MAS:Vivek - would DRUPAL8SITE be better managed as a stored value?
    // Vivek:MAS - I have used NSUserDefaults to store DRUPAL8SITE because it is not sensitive data like password. So according to Apple it is OK to use. But, in future for some professional App If it is required to store drupal site information per User than it would be better to use a simple framework based on Keychain  access to sperate each user's data.
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
    sharedSession.baseURL = baseURL;
    
    if(sharedSession.baseURL != nil){
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
