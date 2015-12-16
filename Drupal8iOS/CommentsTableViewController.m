//
//  CommentsTableViewController.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 9/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "D8iOS.h"
#import "Developer.h"
#import "Comment.h"
#import "CommentTableViewCell.h"
#import "NotifyViewController.h"
#import "DIOSSession.h"
#import "User.h"



@interface CommentsTableViewController ()
@property (nonatomic,strong) NSMutableArray * commentList;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation CommentsTableViewController
@synthesize nid;

-(NSMutableArray *)commentList {
    if ( !_commentList ) {
        _commentList = [[NSMutableArray alloc]init];
    }
    return _commentList;
}

-(IBAction)getData{
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    [self toggleSpinner:YES];
    [D8iOS getCommentDataforNodeID:self.nid
                           success:^(NSMutableArray *commentList) {
                               [self toggleSpinner:NO];
                               if (commentList != nil) {
                                   self.commentList = commentList;
                                   [self.tableView reloadData];
                               }
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               [self toggleSpinner:NO];
                               long statusCode = operation.response.statusCode;
                               // This can happen when GET is with out Authorization details
                               if ( statusCode == 401 ) {
                                   sharedSession.signRequests = NO;
                                   
                                   User *sharedUser = [User sharedInstance];
                                   // Credentials are not valid so remove it
                                   [sharedUser clearUserDetails];
                                   
                                   [self presentViewController:[NotifyViewController invalidCredentialNotify]
                                                      animated:YES
                                                    completion:nil];
                               }
                               
                               // Credentials is correct but user is not authorised to do certain operation.
                               else if( statusCode == 403 ) {
                                   [self presentViewController:[NotifyViewController notAuthorisedNotifyError]
                                                      animated:YES
                                                    completion:nil];
                                   
                               }
                               else{
                                   NSMutableDictionary *errorRes = (NSMutableDictionary *) operation.responseObject;
                                   [self presentViewController:[NotifyViewController genericNotifyError:[errorRes objectForKey:@"error"]]
                                                      animated:YES
                                                    completion:nil];
                               }

        
                           }];
   
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( self.commentList.count !=0 ) {
        return self.commentList.count;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( self.commentList.count != 0 ) {
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
        
        Comment *comment = [self.commentList objectAtIndex:indexPath.row];
        cell.userName.text = comment.name;
        cell.lastUpdated.text = comment.changed;
        cell.commentSubject.text = comment.subject;
        [cell.commentBody loadHTMLString:comment.comment_body baseURL:[NSURL URLWithString:DRUPAL8SITE]];
        cell.indentationLevel = [comment.thread intValue];
        D8D(@"%ld",(long)cell.indentationLevel);
        cell.indentationWidth = 10.0f;
    
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noComments" forIndexPath:indexPath];
        
        return cell;
    }
}

-(void)toggleSpinner:(bool) on {
    if ( on ) {
        _hud = [[MBProgressHUD alloc ] initWithView:super.view];
        [super.view addSubview:_hud];
        _hud.delegate = nil;
        _hud.labelText = @"Loading the comments ...";
        [_hud show:YES];
    }
    else {
        [_hud hide:YES];
    }
}
@end
