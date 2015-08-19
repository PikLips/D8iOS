//
//  Article.h
//  Drupal8iOS
//
//  Created by Vivek Pandya on 7/19/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface Article : JSONModel

@property (nonatomic,strong) NSString *title;

@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) NSString *changed;

@property (nonatomic,strong) NSString *nid;


@end
