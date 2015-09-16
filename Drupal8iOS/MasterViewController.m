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


/* MAS: 
 */

// MAS:Vivek - If we use this code to control the menu, we can eliminate checking for site, login, etc, in the other scenes.
//  For example, if the site is not specified, the specify site view would be the
//  only menu item.  If the site was specified but user not signed-in then only
//  the specify site view and login menu items would be visible, etc.

//Vivek:MAS - Yes, I think we can do these checks here with viewWillAppear method as this is the view which gets loaded first. This will also make application Launch screen to be hold untill we are done with checks and then configure our view and show it to the user. But as this may take some time due to network call so it is required to intimate the user that what is going on . Similar to Facebook app loading screen. To do so we can add one loading view controller that performs all these tasks and also shows some status of all operation to user. We can code this thing but I think I will be running short of time for next days as my mid semester exam is approaching. Still I will try to do this after 8 Oct, 2015 

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
/* MAS: end
 */

- (void) loadMenus {

    /*  MAS:
     *  This creates an array of menu items for the Master Navigation.  This
     *  allows the detail view to retain its position in the split view while
     *  keeping the menu item views in code for easier refactoring (see
     *  DetailViewController).  It also allows the methods above to alter
     *  the table if certain menu items are unnecessary, such as when the Drupal
     *  site has been previously entered or the user signed in.
     */

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
    /* MAS:  Pass the menu item to the Detail View Controller --
     */
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *object = self.d8MenuItems[indexPath.row];
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
