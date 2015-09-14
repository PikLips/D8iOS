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
