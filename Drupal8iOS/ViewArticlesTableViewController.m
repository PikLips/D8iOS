//
//  ViewArticlesTableViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/15/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/*  MAS:
 *  This shows lists (table views) of articles from the Drupal 8 site.  There
 *  are two types of articles - ones that are public (for anonymous users, too) 
 *  and ones that are restricted via authentication such as signed-in users,
 *  signed-in users of a group, or just the signed-in user who authors the article.
 */

/* Vivek: Due to the bug 2228141, it was not possible to enforce permissions on view and thus on view based 
 *  REST export.  We use REST view to export the details of Article. So, we will need to enforce same permission 
 *  which is enforce on GET on nodes.  In this case, if the user is not allowed to GET a node ( Article ) 
 *  then the user should not access the list of Article details. 
 *  Once this bug is solved, we can supply authentication details to verify it.
 */

#import "ViewArticlesTableViewController.h"
#import "Article.h"
#import <AFNetworking/AFNetworking.h>
#import <UIAlertView+AFNetworking.h>
#import "ViewArticleViewController.h"
#import <DIOSSession.h>
#import <DIOSView.h>
#import "Developer.h"
#import "User.h"


@interface ViewArticlesTableViewController ()

@property (nonatomic,strong) NSMutableArray * articleList; // to hold NSDictionaries that are created with JSON Response and each NSDictionary represent article object i.e it will contain all the fields which you have enabled from RESTExport for the view

@end

@implementation ViewArticlesTableViewController

-(NSMutableArray *)articleList{
    if (!_articleList) {
        _articleList = [[NSMutableArray alloc]init];
        
    }
    return _articleList;

}

-(IBAction)getData{
    
    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = @"Loading the articles";
    [hud show:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
       sharedSession.baseURL = baseURL;
   
    // Remove line given below once bug 2228141 is solved
    // As currently RESTExport do not support authentication
    // When pushing this code to pantheon site set this to NO becuase it has not been patched with 2228141.patch 
    //sharedSession.signRequests = YES;
    
    if ( sharedSession.baseURL != nil ) {
        [DIOSView getViewWithPath:@"articles" params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.articleList removeAllObjects];
          
                    for ( NSMutableDictionary *article in responseObject )
                    {
                        Article *newTip = [[Article alloc]initWithDictionary:article];
                        [self.articleList addObject:newTip];
            
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
            // This can happen when GET is with out Authorization details or credentials are wrong
            if ( statusCode == 401 ) {
                
                sharedSession.signRequests = NO;
                
                User *sharedUser = [User sharedInstance];
                [sharedUser clearUserDetails];

                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify login credentials. " delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [alert show];
            }
            
            // Credentials are valid but user is not authorised to perform this operation.
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.refreshControl addTarget:self action:@selector(getData) forControlEvents:UIControlEventValueChanged];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.articleList count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"articleCell" forIndexPath:indexPath];
    Article *articleObj = nil;
    
        articleObj = [self.articleList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [articleObj valueForKeyPath:@"title"];
    cell.detailTextLabel.text = [articleObj valueForKeyPath:@"changed"];
    return cell;
    
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


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ( [sender isKindOfClass:[UITableViewCell class]] ) {
        
        if ( [segue.destinationViewController isKindOfClass:[ViewArticleViewController class]] ) {
            
            if ([segue.identifier isEqualToString:@"showArticle"]) {
                
                ViewArticleViewController *newVC = (ViewArticleViewController *)segue.destinationViewController;
                
                    newVC.article = [self.articleList objectAtIndex:[self.tableView indexPathForCell:sender].row];
                
            }
        }
    }
   
}

@end
