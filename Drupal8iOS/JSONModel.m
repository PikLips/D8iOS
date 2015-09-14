//
//  JSONModel.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 7/19/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "JSONModel.h"

@implementation JSONModel

-(instancetype)init{
    
    if (self = [super init]) {
        return  self;
    }
    else return nil;
}

-(instancetype)initWithDictionary:(NSMutableDictionary *)jsonObject{
    
    if ( self = [super init] ) {
        [self setValuesForKeysWithDictionary:jsonObject];
    }
    return self;
    
}


@end
