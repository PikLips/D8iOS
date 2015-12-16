//
//  UploadFileViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "UploadFileViewController.h"
#import "Developer.h"  // MAS: for development only, see which
#import "DIOSEntity.h"
#import "DIOSSession.h"
#import "User.h"
#import "D8iOS.h"
#import "NotifyViewController.h"

@interface UploadFileViewController ()
{
    NSArray *pickerDataArray; // MAS: this stores the array of local filenames for the UIPickerView widget
    NSInteger selectedRow; // MAS: this is the row selected
    NSString *selectedFilename; // MAS: this is the filename selected to be uploaded to Drupal
}
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation UploadFileViewController
@synthesize uploadFilePicker;  // MAS:


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configurePickerView];
    D8D(@"Picker data has %lu", (unsigned long)pickerDataArray.count);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configurePickerView {
    // Set the default selected rows (the desired rows to initially select will vary by use case).
    /* MAS:
     */
    pickerDataArray = [self getLocalFilesWithExtension:@"txt"];
    D8D(@"First filename is %@", [pickerDataArray objectAtIndex: 0]);
    
    /* MAS:
     */
    
}
/* MAS: This will retrieve array of filenames of certain type from local directory
 *      provides the option to expose filtering to user (optional feature).
 */
- (NSArray *)getLocalFilesWithExtension: (NSString *)fileExtension {
    /* MAS: fileExtension could be 'jpeg' 'caf' 'text' etc., and selectedDirectory is likely user-specific
     *    Both need validating before use!
     */
    NSError *error = nil;
    // MAS: this gets the filenames from the sandboxed "~/Directory" --
    NSFileManager *theFM = [NSFileManager defaultManager]; // MAS: intialize for directory/file management
    NSURL *documentsDirectory = [[theFM URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSArray *directoryContents = [theFM contentsOfDirectoryAtPath:documentsDirectory.path  error:&error];
    
    if ( error ) {
        D8E(@"Directory error %@", [error localizedDescription]);
    }
    if ( directoryContents.count == 0 ) {
        D8E(@"Directory empty: %d  (%@)", (int) [directoryContents count], [error localizedDescription]);
    }
    else {
        D8D(@"Directory not empty: %@", directoryContents.firstObject);
    }
    
    NSIndexSet *localFileNameIndexes = [directoryContents indexesOfObjectsPassingTest:^BOOL(NSString *fileName, NSUInteger idx, BOOL *stop) {
        return [[fileName pathExtension] isEqualToString:fileExtension];
    }];
    
    if ( localFileNameIndexes.count > 0 ) {
        NSArray *localFileNames = [directoryContents objectsAtIndexes:localFileNameIndexes]; // MAS's code
        return localFileNames;
    }
    else {
        D8D(@"no files found");
        return nil;
    }
}
#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1; // MAS: just the filenames
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return pickerDataArray.count;  // MAS: as manu as are in the directory
}


#pragma mark - UIPickerViewDelegate

// The data to return for the row and component (column) that's being passed in
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerDataArray  objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    selectedRow = row;
    selectedFilename = [pickerDataArray objectAtIndex: row];
    if (![self uploadSelectedFile:selectedFilename]) {
        D8D(@"Upload failed");
    }
}

- (bool)uploadSelectedFile:(NSString*)localFilename {
    // MAS: upload and verify
    return NO;
}

- (IBAction)uploadFile:(id)sender {
    
    NSFileManager *theFM = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[theFM URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *filePath =  [NSString stringWithFormat:@"%@/%@",documentsDirectory.path,selectedFilename];
    D8D("Filepath: %@", filePath);
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] )
    {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath]; //NSData is required to get base64 encoding string of file
        NSString *base64EncodedFile = [data base64EncodedStringWithOptions:0];
        [self toggleSpinner:YES isSuccess:NO];
        DIOSSession *sharedSession = [DIOSSession sharedSession];
        [sharedSession.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [D8iOS uploadFilewithFileName:selectedFilename
                        andDataString:base64EncodedFile
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self toggleSpinner:NO isSuccess:YES];
                                  [sharedSession.requestSerializer setValue:nil forHTTPHeaderField:@"Accept"];
                        }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self toggleSpinner:NO isSuccess:NO];
                                  [sharedSession.requestSerializer setValue:nil forHTTPHeaderField:@"Accept"];
                                  long statusCode = operation.response.statusCode;
                                  // This can happen when POST is with out Authorization details
                                  if (statusCode == 401) {
                                      DIOSSession *sharedSession = [DIOSSession sharedSession];
                                      
                                      sharedSession.signRequests = NO;
                                      
                                      User *sharedUser = [User sharedInstance];
                                      // Credentials are not valid so remove it
                                      [sharedUser clearUserDetails];
                                      [self presentViewController:[NotifyViewController invalidCredentialNotify]
                                                         animated:YES
                                                       completion:nil];
                                  }
                                  
                                  else if( statusCode == 0 ) {
                                      [self presentViewController:[NotifyViewController zeroStatusCodeNotifyError:error.localizedDescription]
                                                         animated:YES
                                                       completion:nil];
                                      
                                  }
                                  
                                  // Credentials are valid but user is not permitted to certain operation.
                                  else if(statusCode == 403){
                                      [self presentViewController:[NotifyViewController notAuthorisedNotifyError]
                                                         animated:YES
                                                       completion:nil];
                                  }
                                  else{
                                      NSMutableDictionary *errorRes = (NSMutableDictionary *) operation.responseObject;
                                      [self presentViewController:[NotifyViewController genericNotifyError:[errorRes objectForKey:@"error"]]
                                                         animated:YES
                                                       completion:nil];

                                  }

                              }];
    }
    else {
        
        D8D(@"File to be uploaded does not exit");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"File does not exist on device" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        
    }
}

/** @function toggleSpinner: (bool) on isSuccess:(bool)flag
 *  @param on A bool indicating whether the activity indicator should be on or off.
 *  @param flag A bool indication whether the operation is successful or not. This param will be ignored if on is YES
 *  @abstract This implements MBProgressHUB as an alternative to UIActivityIndicatorView .
 *  @seealso https://github.com/jdg/MBProgressHUD
 *  @discussion This needs to be a Cocoapod and abstracted into its own class with specific objects
 *              for each use (more illustrative).
 *  @return N/A
 *  @throws N/A
 *  @updated
 *
 */

-(void)toggleSpinner:(bool) on isSuccess:(bool)flag{
    if ( on ) {
        _hud = [[MBProgressHUD alloc ] initWithView:super.view];
        [super.view addSubview:_hud];
        _hud.delegate = nil;
        _hud.labelText = @"Uploading image ...";
        [_hud show:YES];
    }
    else {
        if (!flag) {
            [_hud hide:YES];
        }
        else{
        UIImageView *imageView;
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
        
        _hud.customView = imageView;
        _hud.mode = MBProgressHUDModeCustomView;
        
        _hud.labelText = @"Completed";
        dispatch_async(dispatch_get_main_queue(), ^{
            // need to put main theread on sleep for 2 second so that "Completed" HUD stays on for 2 seconds
            sleep(1);
            [_hud hide:YES];
        });
        }
        
    }
}

@end
