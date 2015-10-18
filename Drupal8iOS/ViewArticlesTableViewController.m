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
#import "D8iOS.h"
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
    
    [D8iOS getArticleDatawithView:self.view completion:^(NSMutableArray *articleList) {
        if (articleList != nil) {
            self.articleList = articleList;
            [self.tableView reloadData];
        }
    }];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ( [sender isKindOfClass:[UITableViewCell class]] ) {
        
        if ( [segue.destinationViewController isKindOfClass:[ViewArticleViewController class]] ) {
            
            if ( [segue.identifier isEqualToString:@"showArticle"]  ) {
                
                ViewArticleViewController *newVC = (ViewArticleViewController *)segue.destinationViewController;
                
                    newVC.article = [self.articleList objectAtIndex:[self.tableView indexPathForCell:sender].row];
                
            }
        }
    }
   
}

@end
