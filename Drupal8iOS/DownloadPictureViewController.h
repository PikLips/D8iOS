//
//  DownloadPictureViewController.h
//  Drupal8iOS
//
//  Created by Michael Smith on 7/15/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface DownloadPictureViewController : UIViewController <MBProgressHUDDelegate>
@property (nonatomic,strong) NSString *pictureURL;
@property (nonatomic,strong) NSString *imageName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end
