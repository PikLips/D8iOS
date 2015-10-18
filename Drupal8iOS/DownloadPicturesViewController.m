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
#import "D8iOS.h"
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
    [D8iOS getFileDatafromPath:@"images" withView:self.view completion:^(NSMutableArray *fileList) {
        if (fileList != nil) {
            self.listOfFiles = fileList;
            [self.tableView reloadData];
        }
    }];
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
