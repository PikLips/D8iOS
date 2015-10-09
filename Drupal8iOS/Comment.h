//
//  Comment.h
//  Drupal8iOS
//
//  Created by Vivek Pandya on 9/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import "JSONModel.h"

@interface Comment : JSONModel
@property (nonatomic,strong) NSString *subject;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *comment_body;
@property (nonatomic,strong) NSString *thread;
@property (nonatomic,strong) NSString *changed;
@property (nonatomic,strong) NSString *cid;
@property (nonatomic,strong) NSString *comment_type;

@end
