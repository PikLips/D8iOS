//
//  D8iOS.h
//  Drupal8iOS
//
//  Created by Michael Smith on 10/16/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MBProgressHUD.h"

@interface D8iOS : NSObject <MBProgressHUDDelegate>
+ (void) uploadImageToServer: (PHAsset *) asset withImage: (UIImageView *) assetImage withinView: (UIViewController *) navController;
@end
