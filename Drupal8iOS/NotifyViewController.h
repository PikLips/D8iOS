//
//  NotifyViewController.h
//  Drupal8iOS
//
//  Created by Michael Smith on 11/16/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifyViewController : UIViewController
+(UIAlertController *)noURLNotify;
+(UIAlertController *)invalidURLNotify;
+(UIAlertController *)otherURLNotifyError:(NSString *)errmsg;
+(UIAlertController *)alreadySignedInNotifyError:(NSString *)errmsg;
+(UIAlertController *)invalidCredentialNotify;
+(UIAlertController *)contactAdminNotifyError:(NSString *)errmsg;
+(UIAlertController *)zeroStatusCodeNotifyError:(NSString *)errmsg;
+(UIAlertController *)notAuthorisedNotifyError;
+(UIAlertController *)loginRequiredNotify;
+(UIAlertController *)genericNotifyError:(NSString *)errmsg;
+(UIAlertController *)informationNotifywithMsg:(NSString *)msg;
@end
