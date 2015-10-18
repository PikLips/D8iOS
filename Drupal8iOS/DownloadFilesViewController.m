//
//  DownloadFilesViewController.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 8/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//
/*  MAS:
 *  This allows the user to download files from the Drupal 8 site to local
 *  storage, depending upon permissions.  These files may be uploaded (which see) 
 *  depending upon permissions.
 */

/*  Vivek: Due to the bug 2228141, it is not possible to enforce permissions on view and thus on view-based 
 *  REST export. To support this code we are using REST view to export the details of Files.
 *  So, we will need to enforce same permission which is enforce on GET on Files.  In this case, if the user 
 *  is not allowed to GET a File, then user should not access the list of Files detials. 
 *  Once this bug is solved we can supply authentication details to verify it.
 */

#import "DownloadFilesViewController.h"
#import "D8iOS.h"
#import "Developer.h"
#import "DIOSSession.h"
#import "FileJSON.h"
#import "DownloadFileTableViewCell.h"


@interface DownloadFilesViewController ()

@property (nonatomic,strong) NSMutableArray *listOfFiles;

@end

@implementation DownloadFilesViewController


-(NSMutableArray *)listOfFiles {
    if ( !_listOfFiles ) {
        _listOfFiles = [[NSMutableArray alloc]init];
        
    }
    return _listOfFiles;
}

-(IBAction)getData {
    [D8iOS getFileDatafromPath:@"files" withView:self.view completion:^(NSMutableArray *fileList) {
        if (fileList != nil) {
            self.listOfFiles = fileList;
            [self.tableView reloadData];
        }
    }];
}
-(void)viewWillAppear:(BOOL)animated {
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

-(void)downloadFile:(id)sender {
    UIButton *senderButton = (UIButton *)sender;
    // D8D(@"%ld",(long)senderButton.tag);
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
        D8D(@"bytesRead: %lu, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
        float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToRead));
        [(UIProgressView *)hud setProgress:percentDone];
        hud.labelText = [NSString stringWithFormat:@"%f",(100.0 * percentDone)];
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hide:YES];
        
        D8D(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        
        if ( error) {
            D8E(@"ERR: %@", [error description]);
        }
        else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            D8D(@"%lld", fileSize);
            D8D(@"File download completed !");
            D8D(@"Successfully downloaded file to %@", path);
            
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

@end
