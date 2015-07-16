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
 *      The following are here in order to manage the views that are not handled by the Master 
 *      Controller Segue.  There are other ways to do this, but none appear to be 'standard'.
 */
#import "SpecifyDrupalSiteViewController.h"
#import "SetupDrupalAccountViewController.h"
#import "LoginViewController.h"
#import "LogoutViewController.h"
#import "ManageUserAccountViewController.h"
#import "DownloadFileViewController.h"
#import "UploadFileViewController.h"
#import "DeleteFileViewController.h"
#import "DownloadPicturesViewController.h"
#import "AAPLRootListViewController.h"
#import "ViewArticlesTableViewController.h"


@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        // NSLog([self.detailItem description]);
        // [self configureView];
        
        // Update the view.
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
     *      This long-winded spew of code is to load the menu items, which the Master Controller
     *      does not seem well suited using segues.  It is driven by the selection in the
     *      master Controller's table, which is designed to be loaded from a JSON object
     *      containing a Drupal menu list.  That feature is a 'future', and this code will 
     *      probably morph before it is added.  maybe not.
     */
    // NSLog(@"well, %@", self.detailDescriptionLabel.text);
    if ( [[self.detailItem description] isEqualToString: @"SpecifyDrupalSite"] ) {
        UIStoryboard *storyboard = self.storyboard;
        SpecifyDrupalSiteViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"SpecifyDrupalSite" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"SetupDrupalAccount"] ) {
        UIStoryboard *storyboard = self.storyboard;
        SetupDrupalAccountViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"SetupDrupalAccount" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"Login"] ) {
        UIStoryboard *storyboard = self.storyboard;
        LoginViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Login" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"Logout"] ) {
        UIStoryboard *storyboard = self.storyboard;
        LogoutViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Logout" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"ManageUserAccount"] ) {
        UIStoryboard *storyboard = self.storyboard;
        ManageUserAccountViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ManageUserAccount" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"DownloadFile"] ) {
        UIStoryboard *storyboard = self.storyboard;
        DownloadFileViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"DownloadFile" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"UploadFile"] ) {
        UIStoryboard *storyboard = self.storyboard;
        UploadFileViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UploadFile" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"DeleteFile"] ) {
        UIStoryboard *storyboard = self.storyboard;
        DeleteFileViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"DeleteFile" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"UploadPicture"] ) {
        UIStoryboard *storyboard = self.storyboard;
        AAPLRootListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UploadPicture" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"DownloadPicture"] ) {
        UIStoryboard *storyboard = self.storyboard;
        ViewArticlesTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"DownloadPicture" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    else if ( [[self.detailItem description] isEqualToString: @"ViewArticles"] ) {
        UIStoryboard *storyboard = self.storyboard;
        DownloadPicturesViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ViewArticles" ];  // MAS: see identifier in IB
        [self.navigationController showViewController:controller sender:self];
    }
    /* MAS:
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
#pragma mark - Segues

/* MAS:  This is being used to identify View Controllers other than DetailViewController
 *
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue attempted via segue ID: %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"showView"]) {
        UIViewController *controller = (UIViewController *)[segue destinationViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}
 * MAS end
 */
@end
