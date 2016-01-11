//
//  D8iOS.m
//  Drupal8iOS
//
//  Created by Michael Smith on 10/16/15.
//  Copyright © 2015 PikLips. All rights reserved.
//  Written by Vivek Pandya
//
/** MAS: This class isolates much of the DIOS Session activity into easily
 *  copyable methods.  Note that NSAppTransportSecurity / NSAllowsArbitraryLoads
 *  is set to 'YES' in the info.plist for development.  You will need a secure
 *  connection for production.
 *  Methods use AppleDocs.
 */
#import "Developer.h"
#import "D8iOS.h"
#import "Comment.h"
#import "Article.h"
#import "FileJSON.h"
#import "DIOSView.h"
#import "DIOSSession.h"
#import "DIOSEntity.h"
#import "DIOSUser.h"
#import "DIOSNode.h"
#import "DIOSComment.h"
#import "User.h"
#import "SGKeychain.h"

@implementation D8iOS

/** @function verifyDrupalSite
 *  @param drupalSiteURL a valid URL according to RFC 2396 RFCs 1738 and 1808
 *  @abstract This verifies the user input and tests to see if the URL points to a live host
 *  by validating the remote host with NSURLConnection.
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return N/A
 *  @throws N/A
 *  @updated
 */
+(void)verifyDrupalSite: (NSURL *)drupalSiteURL
             completion:(void (^)(NSError *))completion {

    DIOSSession *sharedSession = [DIOSSession sharedSession];
    sharedSession.baseURL = drupalSiteURL;
    
    /** Vivek: By default, DIOSSession has AFJSONResponseSerializer which causes a http-based response
     *  with status code 2XX to be an unacceptable response type.
     *  So, to execute the request we change ResponseSerializer temporarily.
     *
     */
    [sharedSession setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    sharedSession.signRequests = NO;
    
    [sharedSession GET:[drupalSiteURL absoluteString]
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   // Success block
                   // Currently this storage per user
                   // storing a validated D8 site to user preferences
                   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                   [defaults setObject:[drupalSiteURL absoluteString] forKey:DRUPAL8SITE];
                   sharedSession.signRequests = YES;

                   NSError *noError = [NSError errorWithDomain:NSURLErrorDomain
                                                          code:operation.response.statusCode
                                                      userInfo:nil];
                   D8D(@"verifyDrupalSite: sharedSession thinks it succeeded for %@, code %ld", drupalSiteURL, operation.response.statusCode);
                   completion(noError); // success
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   // Faliure block
                   D8D(@"verifyDrupalSite: sharedSession Failed for %@, code %@", drupalSiteURL, error);
                   completion(error);
               }];
    
    // Restore the ResponseSerializer to JSONSerializer
    [sharedSession setResponseSerializer:[AFJSONResponseSerializer serializer]];
}

/** @function uploadImageToServer
 *  @param asset identifies image asset in PHPhotoLibrary
 *  @param assetImage a UIImageView to be Base64 encoded before sent
 *  @abstract This uploads an image file to the Drupal server
 *  after encoding Base64.  Server must be set to receive file.
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success/failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)uploadImageToServer:(PHAsset *)asset
                 withImage:(UIImageView *)assetImage
                   success:(void (^)(AFHTTPRequestOperation *, id))success
                   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    // This is the JSON body with required details to be sent
    NSDictionary *params = @{
                             @"filename":@[@{@"value":[asset valueForKey:@"filename"]}],
                             @"data":@[@{@"value":[self encodeToBase64String:assetImage.image]
                                         }]};
    // call to create Entity on drupal
    [DIOSEntity createEntityWithEntityName:@"file" type:@"file" andParams:params
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       // success block
                                       if(success){
                                           success(operation,responseObject);
                                       }
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       // Faliure block
                                       if (failure) {
                                           failure(operation,error);
                                       }
                                   }];

    
}

+(NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
/** @function getCommentDataforNodeID
 *  @param nodeID Drupal node containing comments
 *  @abstract This retrieves comments from a node on the Drupal server.
 *  Node must be identified .
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success returns array of comments
 *  @return failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)getCommentDataforNodeID:(NSString *)nodeID
                       success:(void (^)(NSMutableArray *))success
                       failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    [DIOSView getViewWithPath:[NSString stringWithFormat:@"comments/%@",nodeID]
                       params:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          // success block
                          NSMutableArray *commentList = [[NSMutableArray alloc]init];
                          for (NSMutableDictionary *comment in responseObject)
                          {
                              Comment *newComment = [[Comment alloc]initWithDictionary:comment];
                              [commentList addObject:newComment];
                          }
                          if (success) {
                              success(commentList);
                          }
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          // faliure block
                          if (failure) {
                              failure(operation,error);
                          }
                      }];


}

/** @function getFileDatafromPath
 *  @param path location of directory on Drupal server
 *  @param success list for file in directory
 *  @abstract This downloads directory listing from the Drupal server
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success  an array of filenames
 *  @return failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)getFileDatafromPath:(NSString *)path
                   success:(void (^)(NSMutableArray *))success
                   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    User *sharedUser = [User sharedInstance];

    [DIOSView getViewWithPath:[NSString stringWithFormat:@"%@/%@",path,sharedUser.uid]
                       params:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          // success block
                          NSMutableArray *listOfFiles = [[NSMutableArray alloc]init];
                          for ( NSMutableDictionary *fileJSONDict in responseObject )
                          {
                              FileJSON *fileJSONObj = [[FileJSON alloc]initWithDictionary:fileJSONDict];
                              [listOfFiles addObject:fileJSONObj];
                          }
                          if (success) {
                              success(listOfFiles);
                          }
                          
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          // faliure block
                          if (failure) {
                              failure(operation,error);
                          }
                      }];


}

/** @function getarticleData_success
 *  @param success array for articles
 *  @param failure response object
 *  @abstract This retrieves articles from a View on the Drupal server.
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success returns array of articles
 *  @return failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)getarticleData_success:(void (^)(NSMutableArray *))success
                      failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    
    // GET on view
    [DIOSView getViewWithPath:@"articles"
                       params:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          // success block
                          NSMutableArray * articleList = [[NSMutableArray alloc]init];
                          for ( NSMutableDictionary *article in responseObject )
                          {
                              Article *newTip = [[Article alloc]initWithDictionary:article];
                              [articleList addObject:newTip];
                              
                          }
                          if ( success ) {
                              success(articleList);
                          }
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          // faliure block
                          if (failure) {
                              failure(operation,error);
                          }
                          
                      }];

    
}

/** @function uploadFilewithFileName
 *  @param fileName identifies image asset in PHPhotoLibrary
 *  @param base64EncodedString a file to be Base64 encoded before sent
 *  @param success see return
 *  @param failure see return
 *  @abstract This uploads a file to the Drupal server
 *  after encoding Base64.  Server must be set to receive file.
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success/failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)uploadFilewithFileName:(NSString *)fileName
                andDataString:(NSString *)base64EncodedString
                      success:(void (^)(AFHTTPRequestOperation *, id))success
                      failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    // Request JSON
    NSDictionary *params = @{
                             @"filename":@[@{@"value":fileName}],
                             @"data":@[@{@"value":base64EncodedString}]};
    // Create file entity
    [DIOSEntity createEntityWithEntityName:@"file" type:@"file" andParams:params
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       // Success block
                                       if (success) {
                                           success(operation,responseObject);
                                       }
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       // faliure block
                                       if (failure) {
                                           failure(operation,error);
                                       }
                                   }];


}

/** @function createUserAccountwithUserName
 *  @param userName  name of user to be added
 *  @param password  user's password
 *  @param email  user's email address
 *  @param success see return
 *  @param failure see return
 *  @abstract This uploads data to the Drupal server to create a new user account.
 *  Response depends upon security setting.  Server must be set to allow annonymous creation.
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success/failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)createUserAccountwithUserName:(NSString *)userName
                            password:(NSString *)password
                            andEmail:(NSString *)email
                             success:(void (^)(AFHTTPRequestOperation *, id))success
                             failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    // Creating NSDictionary for JSON body on the fly
    NSDictionary *JSONBody =  @{
                                @"langcode": @[
                                        @{
                                            @"value": @"en"}
                                        ],
                                @"name": @[
                                        @{
                                            @"value": userName
                                            }
                                        ],
                                @"mail": @[
                                        @{
                                            @"value": email
                                            }
                                        ],
                                @"pass": @[
                                        @{
                                            @"value": password
                                            }
                                        ]
                                };
    
    [DIOSUser createUserWithParams:JSONBody
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               // Success block
                               if (success) {
                                   success(operation,responseObject);
                               }
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               // faliure block
                               if (failure) {
                                   failure(operation,error);
                               }
                               
                           }];


}

/** @function updateUserAccoutwithUserName
 *  @param userName  name of user to be added
 *  @param currentPass  user's current password
 *  @param email  user's email address
 *  @param currentPass  user's new password
 *  @param success see return
 *  @param failure see return
 *  @abstract This changes the passwork of a user's account.
 *  Response depends upon security setting.
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success/failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)updateUserAccoutwithUserName:(NSString *)userName
                    currentPassword:(NSString *)currentPass
                              email:(NSString *)email
                revisedUserPassword:(NSString *)revisedUserPassword
                            success:(void (^)(AFHTTPRequestOperation *, id))success
                            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    User *sharedUser = [User sharedInstance];
    NSDictionary *valueForName;
    NSArray *nameArray;
    NSDictionary *valueForMail;
    NSArray *mailArray;
    NSMutableDictionary *valueForPass = [[NSMutableDictionary alloc]initWithObjects: @[currentPass]
                                                                            forKeys:@[@"existing"]];
    NSArray *passArray;
    
    if ( userName !=nil && ![userName isEqualToString:@""] ) {
        // create dictionary   {"value":"somevalue"}
        valueForName = [[NSDictionary alloc]initWithObjects:@[userName] forKeys:@[@"value"]];
        // create array [{"value":"somevalue"}]
        nameArray = [[NSArray alloc]initWithObjects:valueForName, nil];
        
    }
    
    if ( email !=nil && ![email isEqualToString:@""] ) {
        
        //create dictionary {"value":"marthinal@drupalisawesome.com"}
        valueForMail = [[NSDictionary alloc]initWithObjects:@[email]
                                                    forKeys:@[@"value"]];
        
        // create mail array [{"value":"marthinal@drupalisawesome.com"}]
        mailArray = [[NSArray alloc]initWithObjects:valueForMail, nil];
        
    }
    
    if ( revisedUserPassword != nil && ![revisedUserPassword isEqualToString:@""] ) {
        // create dictionary {"existing":"existingSecretPass", "value": "myNewSuperSecretPass"}
        [valueForPass setObject:revisedUserPassword
                         forKey:@"value"];
        
        // create password array [{"existing":"existingSecretPass", "value": "myNewSuperSecretPass"}]
        passArray = [[NSArray alloc]initWithObjects:valueForPass, nil];
        
    }
    
    /* create dictionay {"name":[{"value":"somevalue"}],
     "mail":[{"value":"marthinal@drupalisawesome.com"}],
     "pass":[{"existing":"existingSecretPass", "value": "myNewSuperSecretPass"}]
     } */
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    
    [params setObject:nameArray forKey:@"name"];
    [params setObject:mailArray forKey:@"mail"];
    [params setObject:passArray forKey:@"pass"];
    
    [DIOSUser patchUserWithID:sharedUser.uid params:params
                         type:@"user"
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if (success) {
                              success(operation,responseObject);
                          }

                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          if (failure) {
                              failure(operation,error);
                          }

                      }];
}

/**
 *  @function loginwithUserName
 *  @param userName a string
 *  @param password a string
 *  @param success a block to be executed on successful completion of operation
 *  @param failure a failure block to be executed on unsuccessful completion of operation
 *  @abstract this performs a login on drupal site with given username and password
 *  and on successful login saves the credentilas in DIOSSession for future requests.
 *  @see drupal-ios-sdk, AFNetworking
 *  @discussion
 *  @return N/A
 *  @throws N/A
 *  @updated
 */
+(void)loginwithUserName:(NSString *)userName
                password:(NSString *)password
                 success:(void (^)(NSMutableDictionary *))success
                 failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure {
    /**
     *  Login with Kyle's iOS-SDK
     */
    
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    [sharedSession setBasicAuthCredsWithUsername:userName
                                     andPassword:password];
    NSString *basicAuthString = [self basicAuthStringforUsername:userName
                                                        Password:password];
    // GET on view
    [DIOSView getViewWithPath:@"user/details"
                       params:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          // success block
                          NSMutableDictionary *userDictionary = [responseObject mutableCopy];
                          [userDictionary addEntriesFromDictionary:@{@"basicAuthString":basicAuthString}];
                          NSError *setPasswordError = nil;
                          [SGKeychain setPassword:password
                                         username:userName
                                      serviceName:@"Drupal 8"
                                      accessGroup:nil
                                   updateExisting:YES
                                            error:&setPasswordError];
                          
                          DIOSSession * session =  [DIOSSession sharedSession];
                          [session setBasicAuthCredsWithUsername:userName
                                                     andPassword:password];
                          
                          
                          if ( userDictionary != nil ) {
                              D8D(@"userDictionary %@", userDictionary );
                          }
                          if (success) {
                              success(userDictionary);
                          }
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          // faliure block
                          
                          if (failure) {
                              failure(operation,error);
                          }
                          
                      }];

}

/**
 *  @function basicAuthStringforUsername
 *  @param userName a string
 *  @param password a string
 *  @abstract this performs a Base64 encoding for a given username and password
 *  @see drupal-ios-sdk, AFNetworking
 *  @discussion
 *  @return string username/password in Base64 encoding
 *  @throws N/A
 *  @updated
 */
+(NSString *)basicAuthStringforUsername:(NSString *)userName Password:(NSString *)password{
    
    NSString * userNamePasswordString = [NSString stringWithFormat:@"%@:%@",userName,password]; // "username:password"
    NSData *userNamePasswordData = [userNamePasswordString dataUsingEncoding:NSUTF8StringEncoding]; // NSData object for base64encoding
    NSString *base64encodedDataString = [userNamePasswordData base64EncodedStringWithOptions:0]; // this will be something like "3n42hbwer34+="
    NSString * basicAuthString = [NSString stringWithFormat:@"Basic %@",base64encodedDataString]; // example set "Authorization header "Basic 3cv%54F0-34="
    
    return  basicAuthString;
    
}

/** @function deleteFilewithFileID
 *  @param fileID  identifies the path/file on the Drupal server
 *  @param success see return
 *  @param failure see return
 *  @abstract This deletes a file on the Drupal server
 *  after encoding Base64.  Server must be set to permit file deletion.
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success/failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)deleteFilewithFileID:(NSString *)fileID
                    success:(void (^)(AFHTTPRequestOperation *, id))success
                    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    // DELETE on file entity
    [DIOSEntity deleteEntityWithEntityName:@"file" andID:fileID
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                       // success block
                                       if (success) {
                                           success(operation,responseObject);
                                       }
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       // Faliure block
                                       if (failure) {
                                           failure(operation,error);
                                       }
                                       
                                   }];
}

/** @function getArticlewithNodeID
 *  @param nodeID Drupal node containing article
 *  @param success object for article, see return
 *  @param failure see return
 *  @abstract This retrieves article from a node on the Drupal server.
 *  Node must be identified .
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success returns object containign article
 *  @return failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)getArticlewithNodeID:(NSString *)nodeID
                    success:(void (^)(NSMutableDictionary *))success
                    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    [DIOSNode getNodeWithID:nodeID
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        // Success block
                        NSMutableDictionary *articleDict = (NSMutableDictionary *)responseObject;
                        if (success) {
                            success(articleDict);
                        }
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        // Faliure block
                        if (failure) {
                            failure(operation,error);
                        }
                    }];

}

/** @function postComment
 *  @param comment string with comment data
 *  @param title  short string with title of comment
 *  @param nodeID  node ID on Drupal server
 *  @param success see return
 *  @param failure see return
 *  @abstract This uploads data to the Drupal server to create a new user account.
 *  Response depends upon security setting.  Server must be set to allow annonymous creation.
 *  @seealso drupal-ios-sdk, AFNetworking
 *  @discussion needs to validate the Drupal host, too (TBD)
 *  @return success/failure  see AFHTTPRequestOperation for details
 *  @throws N/A
 *  @updated
 */
+(void)postComment:(NSString *)comment
         withTitle:(NSString *)title
          onNodeID:(NSString *)nodeID
           success:(void (^)(AFHTTPRequestOperation *, id))success
           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    
    User *user = [User sharedInstance];
    
    // JSON for POST on comment resource
    NSDictionary *params =
    @{
      
      @"entity_id": @[
              @{
                  @"target_id": nodeID
                  }
              ],
      @"subject": @[
              @{
                  @"value": title
                  }],
      
      @"uid":@[
              @{
                  
                  @"target_id":user.uid
                  }
              ],
      @"status": @[
              @{
                  @"value": @"1"
                  }
              ],
      @"entity_type": @[
              @{
                  @"value": @"node"
                  }
              ],
      @"comment_type": @[
              @{
                  @"target_id": @"comment"
                  }
              ],
      @"field_name": @[
              @{
                  @"value": @"comment"
                  }
              ],
      @"comment_body": @[
              @{
                  @"value":comment,@"format":@"full_html"
                  }
              ]
      };
    
   
    // POST on comment
    [DIOSComment createCommentWithParams:params
                              relationID:nodeID
                                    type:@"comment"
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     // Success block
                                     if (success) {
                                         success(operation,responseObject);
                                     }
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     // faliure block
                                     if (failure) {
                                         failure(operation,error);
                                     }
                                 }];
    

}


/** Notify User Title with Notification, Response Text, and error (if applicable)
 *  This provides a warning to the user.
 * @param Title Text string of notification
 * @param Notification Text string to be used in notification
 * @param NotifyError NSError if applicable
 * @param Response Text string that goes with exiting the notification
 * @return bool Indication that message was sent (may not always be applicable)
 * @see UIAlertView or UIAlertController
 */
-(void)notifyUserWithTitle:(NSString *)title
                  withView:(UIViewController *)view
            onNotification:(NSString *)notification
              withResponse:(NSString *)response
             optionalError:(NSError *)notifyError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                message: (notifyError ? [NSString stringWithFormat:notification, notifyError.localizedDescription] :                                                               notification)
                                        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:response
                                                            style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [view presentViewController:alert animated:YES completion:nil];
}

@end
