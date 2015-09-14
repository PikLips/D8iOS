//
//  DetailViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "DetailViewController.h"
#import "MasterViewController.h"
#import "Developer.h"  // MAS: for development only, see which

/* MAS:
 *  The following are here in order to manage the views that are not
 *  handled by the Master Controller Segue.
 */
#import "SpecifyDrupalSiteViewController.h"
#import "SetupDrupalAccountViewController.h"
#import "LoginViewController.h"
#import "LogoutViewController.h"
#import "ManageUserAccountViewController.h"
#import "DownloadFilesViewController.h"
#import "UploadFileViewController.h"
#import "DeleteFileViewController.h"
#import "DownloadPicturesViewController.h"
#import "AAPLRootListViewController.h"
#import "ViewArticlesTableViewController.h"
/*  MAS: end
 */

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
        D8D(@"if, %@, %@", [self.detailItem description], self.detailDescriptionLabel.text);
    }
    /* MAS:
     *  This is driven by the selection in the master Controller's table.
     *  We show the view instead of a segue to make it easier for others
     *  to refactor the code by not having to dig into IB.  This
     *  code will probably morph again.  Maybe not.
     */
    UIStoryboard *storyboard = self.storyboard;
    SpecifyDrupalSiteViewController *controller = [storyboard instantiateViewControllerWithIdentifier:[[self.detailItem description]stringByReplacingOccurrencesOfString:@" " withString:@""]];  // MAS: the label is the name with spaces, this removes the spaces
    [self.navigationController showViewController:controller sender:self];
    /* MAS: end
     */    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
