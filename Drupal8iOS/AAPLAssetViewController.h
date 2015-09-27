//
//  AAPLAssetViewController.h
//  Drupal8iOS
//
//  Created by Michael Smith on 7/13/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import  "MBProgressHUD.h"

@interface AAPLAssetViewController : UIViewController <MBProgressHUDDelegate>

@property (strong) PHAsset *asset;
@property (strong) PHAssetCollection *assetCollection;


@end
