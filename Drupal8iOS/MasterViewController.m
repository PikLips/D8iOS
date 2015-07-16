//
//  MasterViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Developer.h"  // MAS: for development only, see which
#import "SpecifyDrupalSiteViewController.h"

@interface MasterViewController ()

@property NSMutableArray *d8MenuItems;
@property NSMutableArray *d8MenuLinks;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}
/* MAS: *****************************************************************************
 *************        For Vivek to code here to END  ----       *********************
 *************  You only need to make the bool work correctly.  *********************
 *************  We will tie the logic into the UI.              *********************/

- (BOOL) checkDrupalURL {
    /* MAS: Check to see if Drupal site was previously set
     *      This logic chould determine whether the app has store the Drupal URL and it is still valid
     */
    
    // logic here
    
    return NO;

}

- (BOOL) checkUserLogin {
    /* MAS: Check to see if Drupal login information was previously set
     *      This logic chould determine whether the app has store the Drupal user and it is still valid
     */
    
    // logic here
    
    return NO;
    
}
/* MAS:
 *********************        ---   END                 *****************************
 ************************************************************************************/


/* MAS: Load Menus
 *      This creates two arrays of menu items for the Master Navigation.
 */

- (void) loadMenus {
    if ( !self.d8MenuItems ) {
        self.d8MenuItems = [[NSMutableArray alloc] init];
    }
    [self.d8MenuItems insertObject:@"View Articles" atIndex: 0];
    [self.d8MenuItems insertObject:@"Upload Picture" atIndex: 0];
    [self.d8MenuItems insertObject:@"Download Picture" atIndex: 0];
    [self.d8MenuItems insertObject:@"Delete File" atIndex: 0];
    [self.d8MenuItems insertObject:@"Upload File" atIndex: 0];
    [self.d8MenuItems insertObject:@"Download File" atIndex: 0];
    [self.d8MenuItems insertObject:@"Manage User Account" atIndex: 0];
    [self.d8MenuItems insertObject:@"Logout" atIndex: 0];
    [self.d8MenuItems insertObject:@"Login" atIndex: 0];
    [self.d8MenuItems insertObject:@"Setup Drupal Account" atIndex: 0];
    [self.d8MenuItems insertObject:@"Specify Drupal Site" atIndex: 0];
    
    if ( !self.d8MenuLinks ) {
        self.d8MenuLinks = [[NSMutableArray alloc] init];
    }
    [self.d8MenuLinks insertObject:@"ViewArticles" atIndex: 0];
    [self.d8MenuLinks insertObject:@"UploadPicture" atIndex: 0];
    [self.d8MenuLinks insertObject:@"DownloadPicture" atIndex: 0];
    [self.d8MenuLinks insertObject:@"DeleteFile" atIndex: 0];
    [self.d8MenuLinks insertObject:@"UploadFile" atIndex: 0];
    [self.d8MenuLinks insertObject:@"DownloadFile" atIndex: 0];
    [self.d8MenuLinks insertObject:@"ManageUserAccount" atIndex: 0];
    [self.d8MenuLinks insertObject:@"Logout" atIndex: 0];
    [self.d8MenuLinks insertObject:@"Login" atIndex: 0];
    [self.d8MenuLinks insertObject:@"SetupDrupalAccount" atIndex: 0];
    [self.d8MenuLinks insertObject:@"SpecifyDrupalSite" atIndex: 0];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self loadMenus]; // MAS: set up the table titles and the corresponding links
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender {
    if (!self.d8MenuItems) {
        self.d8MenuItems = [[NSMutableArray alloc] init];
    }
    [self.d8MenuItems insertObject:[NSDate date] atIndex:0]; // MAS: add date as cell text
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /* MAS:  This is being used to identify View Controllers other than DetailViewController
     */
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *object = self.d8MenuLinks[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    /* MAS end
     */
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.d8MenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.d8MenuItems[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.d8MenuItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
