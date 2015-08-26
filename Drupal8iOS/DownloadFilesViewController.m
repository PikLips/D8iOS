//
//  DownloadFilesViewController.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 8/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import "DownloadFilesViewController.h"
#import "User.h"
#import "Developer.h"
#import "DIOSSession.h"
#import "DIOSView.h"
#import "FileJSON.h"
#import "DownloadFileTableViewCell.h"


@interface DownloadFilesViewController ()
@property (nonatomic,strong) NSMutableArray *listOfFiles;
@end

@implementation DownloadFilesViewController


-(NSMutableArray *)listOfFiles{
    if (!_listOfFiles) {
        _listOfFiles = [[NSMutableArray alloc]init];
        
    }
    return _listOfFiles;
    
}



-(IBAction)getData{
    
    User *sharedUser = [User sharedInstance];
    
    if (sharedUser.uid != nil && ![sharedUser.uid isEqualToString:@""] ) {
        
        
        
        MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        
        hud.delegate = self;
        hud.labelText = @"Loading the files";
        [hud show:YES];
        
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
        
        DIOSSession *sharedSession = [DIOSSession sharedSession];
        sharedSession.baseURL = baseURL;
        
        // Remove line given below once bug 2228141 is solved
        // As currently RESTExport do not support authentication
        //sharedSession.signRequests = NO;
        
        
        
        if (sharedSession.baseURL != nil) {
            [DIOSView getViewWithPath:[NSString stringWithFormat:@"files/%@",sharedUser.uid] params:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                
                int statusCode = operation.response.statusCode;
                // This can happen when GET is with out Authorization details
                if (statusCode == 401) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please login first" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                }
                
                // Credentials sent with request is invalid
                else if(statusCode == 403){
                    
                    sharedSession.signRequests = NO;
                    
                    User *sharedUser = [User sharedInstance];
                    [sharedUser clearUserDetails];
                    
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify the login credentials" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                    
                    
                    
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                    
                }
                
            }];
            
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please specify a drupal site first" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        }
        
        
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please first login" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
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
    return [self.listOfFiles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadFileTableViewCell *cell = (DownloadFileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"downloadFileCell" forIndexPath:indexPath];
    
    FileJSON *fileJSONObj = [self.listOfFiles objectAtIndex:indexPath.row];
    
    [cell.fileName setText:fileJSONObj.filename];
    [cell.fileSize setText:fileJSONObj.filesize];
    [cell.lastChanged setText:fileJSONObj.changed];
    [cell.fid setText:[NSString stringWithFormat:@"fid : %@",fileJSONObj.fid]];
    [cell.downloadButton setTag:indexPath.row];
    [cell.downloadButton addTarget:self action:@selector(downloadFile:) forControlEvents:UIControlEventTouchUpInside];
     
    
    return cell;
}

-(void)downloadFile:(id)sender{
    UIButton *senderButton = (UIButton *)sender;
   // NSLog(@"%ld",(long)senderButton.tag);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    // Set determinate bar mode
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    
    hud.delegate = self;
    [hud show:YES];
    // myProgressTask uses the HUD instance to update progress
    
    FileJSON *fileJSONObj = [self.listOfFiles objectAtIndex:senderButton.tag];
    NSURL *url = [NSURL URLWithString:fileJSONObj.uri];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileJSONObj.filename];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
        float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToRead));
        [(UIProgressView *)hud setProgress:percentDone];
        hud.labelText = [NSString stringWithFormat:@"%f",(100.0 * percentDone)];
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hide:YES];
        
        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        
        if (error) {
            NSLog(@"ERR: %@", [error description]);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            NSLog(@"%lld", fileSize);
            NSLog(@"File download completed !");
            NSLog(@"Successfully downloaded file to %@", path);
            
            //[[_downloadFile titleLabel] setText:[NSString stringWithFormat:@"%lld", fileSize]];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                       message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription]
                                                      delegate:nil
                                             cancelButtonTitle:@"Dismiss"
                                             otherButtonTitles: nil];
        [alert show];
        
    }];
    
    [operation start];
    
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
