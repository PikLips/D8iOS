//
//  AAPLAssetViewController.h
//  Drupal8iOS
//
//  Created by Michael Smith on 7/13/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface AAPLAssetViewController : UIViewController

@property (strong) PHAsset *asset;
@property (strong) PHAssetCollection *assetCollection;


@end
