//
//  ViewArticlesTableViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/15/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "ViewArticlesTableViewController.h"
#import "Article.h"
#import <AFNetworking/AFNetworking.h>
#import <UIAlertView+AFNetworking.h>
#import "ViewArticleViewController.h"
#import <DIOSSession.h>
#import <DIOSView.h>
#import "Developer.h"

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
    
    
  //Request with pure AFNetworking
//    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
//    
//    [sessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
//    [sessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
//    
//    NSURLSessionDataTask *getTipData = [sessionManager GET:@"http://localhost/dr8b1211/articles" parameters:@{@"_format":@"json"} success:^(NSURLSessionDataTask *task, id responseObject) {
//        
//        
//        
//        
//        
//        
//        [self.articleList removeAllObjects];
//        for (NSMutableDictionary *article in responseObject)
//        {
//            Article *newTip = [[Article alloc]initWithDictionary:article];
//            [self.articleList addObject:newTip];
//            
//        }
//        [self.tableView reloadData];
//        
//        
//        //self.filteredTips  = [NSMutableArray arrayWithCapacity:[self.tipList count]];
//        
//        
//        
//        
//        
//        
//        [self.refreshControl endRefreshing];
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        
//        [self.refreshControl endRefreshing];
//        NSLog(@"%@",error.description);
//        
//        
//        
//    }];
//    [ UIAlertView showAlertViewForTaskWithErrorOnCompletion:getTipData delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
       sharedSession.baseURL = baseURL;
    if (sharedSession.baseURL != nil) {
        [DIOSView getViewWithPath:@"articles" params:@{@"_format":@"json"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.articleList removeAllObjects];
          
                    for (NSMutableDictionary *article in responseObject)
                    {
                        Article *newTip = [[Article alloc]initWithDictionary:article];
                        [self.articleList addObject:newTip];
            
                    }
                    [self.tableView reloadData];
            
            
                    //self.filteredTips  = [NSMutableArray arrayWithCapacity:[self.tipList count]];
                    
                    
                    
                    
                    
                    
                    [self.refreshControl endRefreshing];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        
        }];
    
        
    }
    else{
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
    
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        if ([segue.destinationViewController isKindOfClass:[ViewArticleViewController class]]) {
            
            if ([segue.identifier isEqualToString:@"showArticle"]) {
                
                ViewArticleViewController *newVC = (ViewArticleViewController *)segue.destinationViewController;
                
                
                    newVC.article = [self.articleList objectAtIndex:[self.tableView indexPathForCell:sender].row];
                
                
            }
        }
    }
   
}


@end
