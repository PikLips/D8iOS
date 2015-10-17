//
//  D8iOSHelper.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 8/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//
/*  MAS:
 *  These routines assist in authentication.
 *
 *  Vivek: 
 *  Only LoginViewController uses one method basicAuthStringforUsername and
 *  it can also be removed by some code. But I would suggest do not remove it for now. 
 *  I will remove it once I am done with image upload and comments.
 */


#import "D8iOSHelper.h"
#import "User.h"
#import "SGKeychain.h"
#import "Developer.h"

@implementation D8iOSHelper

+(NSURL *)baseURL{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *baseURL = nil;
    if ( [defaults objectForKey:DRUPAL8SITE] != nil ) {
        NSString *baseURLString = [defaults objectForKey:DRUPAL8SITE];
        
        /*NSString *baseURLString = [NSString stringWithFormat:@"http://localhost/dr8a11/"]; */
        
        baseURL = [NSURL URLWithString:baseURLString];
    }
    return baseURL;
}

+(NSURL *)createURLForPath:(NSString *)path{

    NSURL *baseURL = [self baseURL];
    NSURL *urlForPath = [baseURL URLByAppendingPathComponent:path]; // here base URL needs trailing slash
    return urlForPath;

}

+(NSURL *)createURLForNodeID:(NSString *)nid{

    NSURL *baseURL = [self baseURL];
    NSString *stringForNid = [NSString stringWithFormat:@"node/%@",nid]; // as REST service on Drupal 8 alpha 10 requires "entity" word in the URL
    NSURL *urlForNodeID = [baseURL URLByAppendingPathComponent:stringForNid];
    
    return urlForNodeID;
}

+(NSString *)basicAuthStringforUsername:(NSString *)username Password:(NSString *)password{
    
    NSString * userNamePasswordString = [NSString stringWithFormat:@"%@:%@",username,password]; // "username:password"
    NSData *userNamePasswordData = [userNamePasswordString dataUsingEncoding:NSUTF8StringEncoding]; // NSData object for base64encoding
    NSString *base64encodedDataString = [userNamePasswordData base64EncodedStringWithOptions:0]; // this will be something like "3n42hbwer34+="
    
    
    NSString * basicAuthString = [NSString stringWithFormat:@"Basic %@",base64encodedDataString]; // example set "Authorization header "Basic 3cv%54F0-34="
    
    return  basicAuthString;

}

+(void)performLoginWithUsername:(NSString *)username andPassword:(NSString *)password{

    NSString *basicAuthString = [self basicAuthStringforUsername:username Password:password];
    
    NSURL *loginRequestURL = [self createURLForPath:@"user/details"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:@{@"Authorization": basicAuthString}];
    
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginRequestURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *loginTask = [session dataTaskWithRequest:loginRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if ( !error ) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if( httpResponse.statusCode == 200 ) {
                
                // this is the case when
                NSDictionary *retrievedJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSMutableDictionary *userDictionary = [retrievedJSON mutableCopy];
                [userDictionary setObject:basicAuthString forKey:@"basicAuthString"];
                User *user = [User sharedInstance];
                [user fillUserWithUserJSONObject:userDictionary];
            }
            else if ( httpResponse.statusCode == 403 ) {
                
                // this is the case when user has changed credential details form the iste it self
                NSError *deleteError;
               
                [SGKeychain deletePasswordandUserNameForServiceName:@"Drupal 8" accessGroup:nil error:&deleteError];
                
            }
        }
        else {
            
            D8E(@"error -> %@",error.localizedDescription);
            
        }
    }];
    
    [loginTask resume];
}

@end
