//
//  DownloadPicturesViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/15/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS:  This reaches out to the Drupal 8 server to get a list of images
 *  that are avaialable for viewing/download.  If the user selects a cell
 *  another viewer will be pushed, displaying the image.
 */

#import "DownloadPicturesViewController.h"
#import "Developer.h"  // MAS: for development only, see which
#import "User.h"
#import "DIOSSession.h"
#import "DIOSView.h"
#import "FileJSON.h"
#import "FileDetailsTableViewCell.h"
#import "DownloadPictureViewController.h"

@interface DownloadPicturesViewController ()
@property (nonatomic,strong) NSMutableArray * listOfFiles;
@end

@implementation DownloadPicturesViewController

-(NSMutableArray *)listOfFiles{
    if (!_listOfFiles) {
        _listOfFiles = [[NSMutableArray alloc]init];
        
    }
    return _listOfFiles;
}

-(IBAction)getData {
    
    User *sharedUser = [User sharedInstance];
    
    if ( sharedUser.uid != nil && ![sharedUser.uid isEqualToString:@""] ) {
        
        MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        
        hud.delegate = self;
        hud.labelText = @"Loading the images";
        [hud show:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
        
        DIOSSession *sharedSession = [DIOSSession sharedSession];
        sharedSession.baseURL = baseURL;
        
        // Remove line given below once bug 2228141 is solved
        // As currently RESTExport do not support authentication
        //sharedSession.signRequests = NO;
        
        if ( sharedSession.baseURL != nil ) {
            [DIOSView getViewWithPath:[NSString stringWithFormat:@"images/%@",sharedUser.uid] params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.listOfFiles removeAllObjects];
                
                for (NSMutableDictionary *fileJSONDict in responseObject)
                {
                    FileJSON *fileJSONObj = [[FileJSON alloc]initWithDictionary:fileJSONDict];
                    [self.listOfFiles addObject:fileJSONObj];
                
                }
                
                [self.tableView reloadData];
                
                [self.refreshControl endRefreshing];
                //  sharedSession.signRequests =YES;
                [hud hide:YES];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.refreshControl endRefreshing];
                [hud hide:YES];
                //  sharedSession.signRequests =YES;
                
                long statusCode = operation.response.statusCode;
                // This can happen when GET is with out Authorization details or login failed.
                if ( statusCode == 401 ) {
                    sharedSession.signRequests = NO;
                    
                    User *sharedUser = [User sharedInstance];
                    [sharedUser clearUserDetails];

                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify the login credentials" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                }
                
                // Credentials sent with request is invalid
                else if ( statusCode == 403 ) {
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"User is not authorised for the operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                    
                }
                else {
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
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please first login" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.listOfFiles count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileDetailsTableViewCell *cell = (FileDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"downloadPictureCell" forIndexPath:indexPath];
    
    FileJSON *fileDetails = [self.listOfFiles objectAtIndex:indexPath.row];
    
    [cell.fileName setText:fileDetails.filename];
    [cell.fileSize setText:fileDetails.filesize];
    [cell.lastChanged setText:fileDetails.changed];
    [cell.fid setText:[NSString stringWithFormat:@"fid: %@",fileDetails.fid]];

    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ( [sender isKindOfClass:[UITableViewCell class]] ) {
        
        if ( [segue.destinationViewController isKindOfClass:[DownloadPictureViewController class]] ) {
            
            if ( [segue.identifier isEqualToString:@"downloadPicture"] ) {
                
                DownloadPictureViewController *newVC = (DownloadPictureViewController *)segue.destinationViewController;
                
                FileJSON *fileJSONObj = (FileJSON *)[self.listOfFiles objectAtIndex:[self.tableView indexPathForCell:sender].row];
                
                newVC.pictureURL = fileJSONObj.uri;
                newVC.imageName = fileJSONObj.filename;
                
            }
        }
    }
}

@end
