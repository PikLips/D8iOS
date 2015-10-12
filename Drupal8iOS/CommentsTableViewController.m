//
//  CommentsTableViewController.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 9/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "DIOSSession.h"
#import "Developer.h"
#import "DIOSView.h"
#import "Comment.h"
#import "User.h"
#import "CommentTableViewCell.h"

@interface CommentsTableViewController ()

@property (nonatomic,strong) NSMutableArray * commentList;
@end

@implementation CommentsTableViewController
@synthesize nid;

-(NSMutableArray *)commentList{
    if ( !_commentList ) {
        _commentList = [[NSMutableArray alloc]init];
        
    }
    return _commentList;
    
}


-(IBAction)getData{

MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
[self.navigationController.view addSubview:hud];

hud.delegate = self;
hud.labelText = @"Loading the comments";
[hud show:YES];

NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];

DIOSSession *sharedSession = [DIOSSession sharedSession];
sharedSession.baseURL = baseURL;

// Remove line given below once bug 2228141 is solved
// As currently RESTExport do not support authentication
// When pushing this code to pantheon site set this to NO because it has not been patched with 2228141.patch
sharedSession.signRequests = YES;


if ( sharedSession.baseURL != nil ) {
    
    [DIOSView getViewWithPath:[NSString stringWithFormat:@"comments/%@",self.nid]  params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.commentList removeAllObjects];
        
        for (NSMutableDictionary *comment in responseObject)
        {
            Comment *newComment = [[Comment alloc]initWithDictionary:comment];
            [self.commentList addObject:newComment];
            
        }
        [self.tableView reloadData];
        
        //self.filteredTips  = [NSMutableArray arrayWithCapacity:[self.tipList count]];
        
        [self.refreshControl endRefreshing];
        sharedSession.signRequests =YES;
        [hud hide:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [hud hide:YES];
        sharedSession.signRequests =YES;
        
        long statusCode = operation.response.statusCode;
        // This can happen when GET is with out Authorization details
        if ( statusCode == 401 ) {
            sharedSession.signRequests = NO;
            
            User *sharedUser = [User sharedInstance];
            [sharedUser clearUserDetails];

            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify the login credentials" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }
        
        // Credentials is correct but user is not authorised to do certain operation.
        else if( statusCode == 403 ) {
            
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"User is not authorised for this operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            
        }
        
    }];
}
else {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please specify a drupal site first" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
}

}


-(void)viewWillAppear:(BOOL)animated{
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
    if (self.commentList.count !=0) {
    return self.commentList.count;
    }
    else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.commentList.count != 0 ){
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
    else{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noComments" forIndexPath:indexPath];
        
        return cell;
    }
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
