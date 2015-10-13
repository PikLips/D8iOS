//
//  User.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 8/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//
/* Vivek: This is a singleton class that holds user information around the app after login. 
 *  Currenly, it holds username, roles assigned to user, basicAuthentication string for the 
 *  username:password combination ( but this is not required, as drupal-ios-sdk directly 
 *  requires username and password in string format ), email address of user associated with account, 
 *  and user id to get more information ( if required ).
 */

#import "User.h"
#import "D8iOSHelper.h" // this was added to support performLogin method
#import "Developer.h"

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

/*  self.name = [UserJSONObject objectForKey:@"name"];
 *  self.roles = [UserJSONObject objectForKey:@"roles"];
 *  self.basicAuthString = [UserJSONObject objectForKey:@"basicAuthString"];
 *  self.uid = [UserJSONObject objectForKey:@"uid"];
 */
    [self setValuesForKeysWithDictionary:UserJSONObject];
    D8D(@"UserJSONObject initialized");
    
}


@end
