//
//  UploadFileViewController.h
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UploadFileViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *uploadFilePicker;

@end
