//
//  User.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 8/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

// MAS:Vivek - explain the roles of these objects

#import "User.h"
#import "D8iOSHelper.h" // this was added to support performLogin method


@interface User()

@property(nonatomic,strong) NSURLSession *sessoin;



@end

@implementation User

static User *sharedDataInstance = nil;
+(User *)sharedInstance{

    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
    
        sharedDataInstance = [[User alloc]init];
        [sharedDataInstance clearUserDetails];
    
    });
    
    return sharedDataInstance;

}

-(void)clearUserDetails{

    self.name = nil;
    self.roles = nil;
    self.basicAuthString = nil;
    self.email = nil;
    self.uid = nil;
    

}

-(void)fillUserWithUserJSONObject:(NSDictionary *)UserJSONObject{

// MAS:Vivek - would you comment on this commented code?
  /*  self.name = [UserJSONObject objectForKey:@"name"];
    self.roles = [UserJSONObject objectForKey:@"roles"];
    self.basicAuthString = [UserJSONObject objectForKey:@"basicAuthString"];
    self.uid = [UserJSONObject objectForKey:@"uid"];
    
    */
    [self setValuesForKeysWithDictionary:UserJSONObject];
    NSLog(@"initialized");
    

}


@end
