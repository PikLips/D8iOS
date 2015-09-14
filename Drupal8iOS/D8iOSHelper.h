//
//  D8iOSHelper.h
//  Drupal8iOS
//
//  Created by Vivek Pandya on 8/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

/* Vivek:
 *  This class provides class methods to create NSURL for the site created
 *  with Drupal to which the application will connect.
 *  It will also contain authorization related stuffs.
 */

#import <Foundation/Foundation.h>

@interface D8iOSHelper : NSObject


// URL helper methods

+(NSURL *)baseURL;
+(NSURL *)createURLForPath:(NSString *)path;
+(NSURL *)createURLForNodeID:(NSString *)nid;
+(NSString *)basicAuthStringforUsername:(NSString *)username Password:(NSString *)password;

// login helper method 
+(void)performLoginWithUsername:(NSString *)username andPassword:(NSString *)password;

@end
