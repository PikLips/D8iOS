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

@interface UploadFileViewController ()
{
    NSArray *pickerDataArray; // MAS: this stores the array of local filenames for the UIPickerView widget
    NSInteger selectedRow; // MAS: this is the row selected
    NSString *selectedFilename; // MAS: this is the filename selected to be uploaded to Drupal
}
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

- (void) configurePickerView {
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
    if (error) {
        D8E(@"Directory error %@", [error localizedDescription]);
    }
    if (directoryContents.count == 0) {
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
    
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath]; //NSData is required to get base64 encoding string of file
            NSString *base64EncodedFile = [data base64EncodedStringWithOptions:0];
            
            
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:hud];
            
            hud.dimBackground = YES;
            hud.labelText = @"Uploading file ...";
            // Regiser for HUD callbacks so we can remove it from the window at the right time
            hud.delegate = self;
            
            [hud show:YES];
            
            NSDictionary *params = @{
                                     @"filename":@[@{@"value":selectedFilename}],
                                     @"data":@[@{@"value":base64EncodedFile}]};
            
            [DIOSEntity createEntityWithEntityName:@"file" type:@"file" andParams:params
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               
                                               
                                               UIImageView *imageView;
                                               UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
                                               imageView = [[UIImageView alloc] initWithImage:image];
                                               
                                               hud.customView = imageView;
                                               hud.mode = MBProgressHUDModeCustomView;
                                               
                                               hud.labelText = @"Completed";
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   // need to put main theread on sleep for 2 second so that "Completed" HUD stays on for 2 seconds
                                                   sleep(1);
                                                   [hud hide:YES];
                                               });
                                           }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               
                                               [hud hide:YES];
                                               
                                               long statusCode = operation.response.statusCode;
                                               // This can happen when POST is with out Authorization details
                                               if (statusCode == 401) {
                                                   DIOSSession *sharedSession = [DIOSSession sharedSession];
                                                   
                                                   sharedSession.signRequests = NO;
                                                   
                                                   User *sharedUser = [User sharedInstance];
                                                   [sharedUser clearUserDetails];
                                                   UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify login credentials." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                                   [alert show];
                                               }
                                               
                                               else if( statusCode == 0 ) {
                                                   
                                                   UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"] message:@"Plese specify a Drupal 8 site first \n" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                                   [alert show];
                                                   
                                               }
                                               
                                               // Credentials are valid but user is not permitted to certain operation.
                                               else if(statusCode == 403){
                                                 
                                                   
                                                   UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"User is not authorised for this operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                                   [alert show];
                                               }
                                               else{
                                                   UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                                   [alert show];
                                                   
                                               }
                                           }];
        }
            else {
                
            D8D(@"File to be uploaded does not exit");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"File does not exist on device" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];

        }
}


#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
