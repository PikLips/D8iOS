//
//  SpecifyDrupalSiteViewController.h
//  Drupal8iOS
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SpecifyDrupalSiteViewController : UIViewController <UIAlertViewDelegate,MBProgressHUDDelegate>

@property (nonatomic) NSURL *drupalSite; // MAS: used for session, may be changed to a different type, e.g., NSURLConnection, NSURLCredential, if necessary

@end
