//
//  DeleteFileViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/*  MAS: This goes to the Drupal 8 server and retrieves a list of files that
 *  may be deleted, producing a table view that the user can select files and
 *  have them removed from the server.
 */

#import "DeleteFileViewController.h"
#import "DIOSSession.h"
#import "User.h"
#import "DIOSView.h"
#import "DIOSEntity.h"
#import "FileJSON.h"
#import "FileDetailsTableViewCell.h"
#import "Developer.h" // MAS: for development only, see which

@interface DeleteFileViewController ()
@property (nonatomic,strong) NSMutableArray *listOfFiles;

@end

@implementation DeleteFileViewController

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
                
                long statusCode = operation.response.statusCode;
                // This can happen when request is with out Authorization details or wrong credentials are specified 
                if ( statusCode == 401 ) {
                    
                    
                    sharedSession.signRequests = NO;
                    
                    User *sharedUser = [User sharedInstance];
                    [sharedUser clearUserDetails];
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify login credentilas." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                }
                
                // Request is in correct format but Drupal refuses to fulfil it as per  permissions set by admin
                else if( statusCode == 403 ){
                   
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"User is npot authorised for this operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Show the HUD while the provided method executes in a new thread
    
    // Do any additional setup after loading the view.
    // UIPickerView *deleteFilePicker = [UIPickerView alloc]; //MAS: initialize
    
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
    
    return [self.listOfFiles count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FileDetailsTableViewCell *cell = (FileDetailsTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:@"deleteFileCell" forIndexPath:indexPath];
    
    FileJSON *fileDetails = [self.listOfFiles objectAtIndex:indexPath.row];
    
    [cell.fileName setText:fileDetails.filename];
    [cell.fileSize setText:fileDetails.filesize];
    [cell.lastChanged setText:fileDetails.changed];
    [cell.fid setText:[NSString stringWithFormat:@"fid: %@",fileDetails.fid]];
    
    return cell;
    //
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        
        hud.dimBackground = YES;
        hud.labelText = @"Deleting file ...";
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        hud.delegate = self;
        
        [hud show:YES];
        
        FileJSON *fileJSONObj = [self.listOfFiles objectAtIndex:indexPath.row];
        
        [DIOSEntity deleteEntityWithEntityName:@"file" andID:fileJSONObj.fid
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           
                                           [self.listOfFiles removeObjectAtIndex:indexPath.row];
                                           [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                       
                                           UIImageView *imageView;
                                           UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
                                           imageView = [[UIImageView alloc] initWithImage:image];
                                           
                                           hud.customView = imageView;
                                           hud.mode = MBProgressHUDModeCustomView;
                                           
                                           hud.labelText = @"Completed";
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               // need to put main theread on sleep for 2 second so that "Completed" HUD stays on for 2 seconds
                                               sleep(1);
                                               [hud hide:YES];
                                           });
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           
                                           [hud hide:YES];
                                           
                                           long statusCode = operation.response.statusCode;
                                           // This can happen when GET is with out Authorization details
                                           if (statusCode == 401) {
                                               DIOSSession *sharedSession = [DIOSSession sharedSession];
                                               
                                               sharedSession.signRequests = NO;
                                               
                                               User *sharedUser = [User sharedInstance];
                                               [sharedUser clearUserDetails];
                                               UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify the login credentials." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                               [alert show];
                                           }
                                           
                                           // Credentials sent with request is invalid
                                           else if(statusCode == 403){
                                              
                                               
                                               UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"User is not authorised for this operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                               [alert show];
                                           }
                                           else{
                                               UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                               [alert show];
                                               
                                           }
                                       }];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

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

@end
