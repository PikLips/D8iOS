//
//  CommentsTableViewController.h
//  Drupal8iOS
//
//  Created by Vivek Pandya on 9/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CommentsTableViewController : UITableViewController <MBProgressHUDDelegate>

@property (nonatomic,strong) NSString *nid;

@end
