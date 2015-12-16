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
#import "D8iOS.h"
#import "DeleteFileViewController.h"
#import "DIOSSession.h"
#import "User.h"
#import "DIOSView.h"
#import "DIOSEntity.h"
#import "FileJSON.h"
#import "FileDetailsTableViewCell.h"
#import "Developer.h" // MAS: for development only, see which
#import "NotifyViewController.h"

@interface DeleteFileViewController ()

@property (nonatomic,strong) NSMutableArray *listOfFiles;
@property (strong, atomic) MBProgressHUD  *hud;  // for activity indicator


@end

@implementation DeleteFileViewController

-(NSMutableArray *)listOfFiles {
    if ( !_listOfFiles ) {
        _listOfFiles = [[NSMutableArray alloc]init];
    }
    return _listOfFiles;
}

-(IBAction)getData {
    User *sharedUser = [User sharedInstance];
    
    if ( sharedUser.uid != nil && ![sharedUser.uid isEqualToString:@""] ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSURL *baseURL = [NSURL URLWithString:[defaults objectForKey:DRUPAL8SITE]];
        DIOSSession *sharedSession = [DIOSSession sharedSession];
        sharedSession.baseURL = baseURL;
        if ( sharedSession.baseURL != nil ) {
            [self toggleSpinner2:YES];
            [D8iOS getFileDatafromPath:@"files"
                               success:^(NSMutableArray *fileList) {
                                   [self toggleSpinner2:NO];
                                   if (fileList != nil) {
                                       self.listOfFiles = fileList;
                                       [self.tableView reloadData];
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   NSInteger statusCode = operation.response.statusCode;
                                   [self toggleSpinner2:NO];
                                   switch (statusCode) {
                                       case 401:{
                                           sharedSession.signRequests = NO;
                                           
                                           User *sharedUser = [User sharedInstance];
                                           // Credentials are not valid so remove it
                                           [sharedUser clearUserDetails];
                                           [self presentViewController:[NotifyViewController invalidCredentialNotify]
                                                              animated:YES
                                                            completion:nil];
                                           break;
                                       }
                                       case 403:{
                                           [self presentViewController:[NotifyViewController notAuthorisedNotifyError]
                                                              animated:YES
                                                            completion:nil];
                                           break;
                                       }
                                       default:{
                                           [self presentViewController:[NotifyViewController zeroStatusCodeNotifyError:error.localizedDescription]
                                                              animated:YES
                                                            completion:nil];
                                           break;
                                       }
                                   }
                                   
                               }];
            
        }
        else{
            [self presentViewController:[NotifyViewController noURLNotify]
                               animated:YES
                             completion:nil];
        }
    }
    else{
        [self presentViewController:[NotifyViewController loginRequiredNotify]
                           animated:YES
                         completion:nil];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getData];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Show the HUD while the provided method executes in a new thread
    
    // Do any additional setup after loading the view.
    // UIPickerView *deleteFilePicker = [UIPickerView alloc]; //MAS: initialize
    
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
    
    return [self.listOfFiles count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        FileJSON *fileJSONObj = [self.listOfFiles objectAtIndex:indexPath.row];
        [self toggleSpinner:YES isSuccess:NO];
        [D8iOS deleteFilewithFileID:fileJSONObj.fid
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                [self.listOfFiles removeObjectAtIndex:indexPath.row];
                                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                                 withRowAnimation:UITableViewRowAnimationFade];
                                [self toggleSpinner:NO isSuccess:YES];
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [self toggleSpinner:NO isSuccess:NO];
                                NSInteger statusCode = operation.response.statusCode;
                                switch (statusCode) {
                                    case 401:
                                        [self presentViewController:[NotifyViewController invalidCredentialNotify]
                                                           animated:YES
                                                         completion:nil];
                                        break;
                                    case 403:
                                        [self presentViewController:[NotifyViewController notAuthorisedNotifyError]
                                                           animated:YES
                                                         completion:nil];
                                        break;
                                    default:
                                        [self presentViewController:[NotifyViewController zeroStatusCodeNotifyError:error.localizedDescription]
                                                           animated:YES
                                                         completion:nil];
                                        break;
                                }
                                
                            }];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/** @function toggleSpinner: (bool) on isSuccess:(bool)flag
 *  @param on A bool indicating whether the activity indicator should be on or off.
 *  @param flag A bool indication whether the operation is successful or not. This param will be ignored if on is YES
 *  @abstract This implements MBProgressHUB as an alternative to UIActivityIndicatorView .
 *  @seealso https://github.com/jdg/MBProgressHUD
 *  @discussion This needs to be a Cocoapod and abstracted into its own class with specific objects
 *              for each use (more illustrative).
 *  @return N/A
 *  @throws N/A
 *  @updated
 *
 */
-(void)toggleSpinner:(bool) on isSuccess:(bool)flag{
    if ( on ) {
        _hud = [[MBProgressHUD alloc ] initWithView:super.view];
        [super.view addSubview:_hud];
        _hud.delegate = nil;
        _hud.labelText = @"Deleting file ...";
        [_hud show:YES];
    }
    else {
        if(flag){
        UIImageView *imageView;
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
        _hud.customView = imageView;
        _hud.mode = MBProgressHUDModeCustomView;
        _hud.labelText = @"Completed";
        dispatch_async(dispatch_get_main_queue(), ^{
            // Put main thread to sleep so that "Completed" HUD stays on for a second
            sleep(1);
            [_hud hide:YES];
        });
    }
        else{
            [_hud hide:YES];
        }
}
}

-(void)toggleSpinner2:(bool) on {
    if ( on ) {
        _hud = [[MBProgressHUD alloc ] initWithView:super.view];
        [super.view addSubview:_hud];
        _hud.delegate = nil;
        _hud.labelText = @"Loading the files ...";
        [_hud show:YES];
    }
    else {
        [_hud hide:YES];
    }
}

@end
