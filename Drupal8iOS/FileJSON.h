//
//  FileJSON.h
//  Drupal8iOS
//
//  Created by Vivek Pandya on 8/19/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

/* Vivek: 
 *  this class maps to dictionary returned by /files/{uid}
 *  This is just for convenience. For some complex applicaiton this may be modified
 *  It is sub class of JSONModel.
 */

#import "JSONModel.h"

@interface FileJSON : JSONModel

@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *changed;
@property (nonatomic, strong) NSString *fid;
@property (nonatomic, strong) NSString *filesize;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *uid;

@end
