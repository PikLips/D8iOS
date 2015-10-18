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

@interface DeleteFileViewController ()

@property (nonatomic,strong) NSMutableArray *listOfFiles;

@end

@implementation DeleteFileViewController

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
        [D8iOS deleteFilewithFileID:fileJSONObj.fid withView:self.view completion:^(BOOL deleted) {
            if (deleted) {
                [self.listOfFiles removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
@end
