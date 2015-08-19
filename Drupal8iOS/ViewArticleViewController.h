//
//  ViewArticleViewController.h
//  Drupal8iOS
//
//  Created by Michael Smith on 7/15/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import "MBProgressHUD.h"

@interface ViewArticleViewController : UIViewController <MBProgressHUDDelegate>
@property (nonatomic,strong) Article* article;

@end
