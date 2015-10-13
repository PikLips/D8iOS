//
//  AddCommentViewController.h
//  Drupal8iOS
//
//  Created by Vivek Pandya on 7/19/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AddCommentViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIWebViewDelegate,MBProgressHUDDelegate>


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (nonatomic,strong) NSString *nid;
@end
