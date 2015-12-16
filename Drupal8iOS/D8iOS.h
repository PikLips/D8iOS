//
//  D8iOS.h
//  Drupal8iOS
//
//  Created by Michael Smith on 10/16/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MBProgressHUD.h"
#import "AFNetworking/AFNetworking.h"


@interface D8iOS : NSObject <MBProgressHUDDelegate>

+(void)verifyDrupalSite: (NSURL *)drupalSiteURL
/* withView: (UIView *)view */
             completion:(void (^)(NSError *))completion;
// completion:(void (^)(BOOL verified))completion;

//+(void)uploadImageToServer: (PHAsset *) asset
//                  withImage: (UIImageView *) assetImage
//                 withinView: (UIViewController *) navController;

+(void)uploadImageToServer:(PHAsset *)asset
                 withImage:(UIImageView *)assetImage
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;

//+(void)getCommentDataforNodeID:(NSString *)nodeID
//                      withView:(UIView *)view
//                    completion:(void (^)(NSMutableArray *commentList))completion;

+(void)getCommentDataforNodeID:(NSString *)nodeID
                       success:(void (^)(NSMutableArray *commentList))success
                       failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;

//+(void)getFileDatafromPath: (NSString *)path
//                  withView:(UIView *)view
//                completion:(void (^)(NSMutableArray *fileList))completion;

+(void)getFileDatafromPath:(NSString *)path
                   success:(void (^)(NSMutableArray *fileList))success
                   failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;

//+(void)getArticleDatawithView:(UIView *)view
//                   completion:(void (^)(NSMutableArray *articleList))completion;

+(void)getarticleData_success:(void (^)(NSMutableArray *articleList))success
                      failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;

//+(void)uploadFilewithFileName: (NSString *)fileName
//                andDataString:(NSString *)base64EncodedString
//                     withView:(UIView *)view;

+(void)uploadFilewithFileName:(NSString *)fileName
                andDataString:(NSString *)base64EncodedString
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;

//+(void)createUserAccountwithUserName: (NSString *)userName
//                            password:(NSString *)password
//                            andEmail:(NSString *)email
//                            withView:(UIView *)view;

+(void)createUserAccountwithUserName:(NSString *)userName
                            password:(NSString *)password
                            andEmail:(NSString *)email
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;

//+(void)updateUserAccoutwithUserName: (NSString *)userName
//                    currentPassword:(NSString *)currentPass
//                              email:(NSString *)email
//                revisedUserPassword:(NSString *)revisedUserPassword
//                           withView:(UIView *)view;

+(void)updateUserAccoutwithUserName:(NSString *)userName
                    currentPassword:(NSString *)currentPass
                              email:(NSString *)email
                revisedUserPassword:(NSString *)revisedUserPassword
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;


+(void)loginwithUserName: (NSString *)userName
                password:(NSString *)password
                 success:(void (^)(NSMutableDictionary *userDetails))success
                 failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;


//+(void)deleteFilewithFileID: (NSString *)fileID
//                   withView: (UIView *)view
//                 completion:(void (^)(BOOL deleted))completion;

+(void)deleteFilewithFileID:(NSString *)fileID
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


//+(void)getArticlewithNodeID: (NSString *)nodeID
//                   withView: (UIView *)view
//                 completion:(void (^)(NSMutableDictionary *articleDetails))completion;

+(void)getArticlewithNodeID:(NSString *)nodeID
                    success:(void (^)(NSMutableDictionary *articleDetails))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//+(void)postComment: (NSString *)comment
//         withTitle: (NSString *)title
//          onNodeID: (NSString *)nodeID
//          withView: (UIView *)view
//        completion:(void (^)(BOOL success))completion;

+(void)postComment:(NSString *)comment
         withTitle:(NSString *)title
          onNodeID:(NSString *)nodeID
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
