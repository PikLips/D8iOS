//
//  DeleteFileViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "DeleteFileViewController.h"
#import "Developer.h"  // MAS: for development only, see which

@interface DeleteFileViewController ()
{
    NSArray *pickerDataArray; // MAS: this stores the array of local filenames for the UIPickerView widget
    NSInteger selectedRow; // MAS: this is the row selected
    NSURL *selectedFilename; // MAS: this is the filename selected to be uploaded to Drupal
}
@property (weak, nonatomic) IBOutlet UIPickerView *deleteFilePicker;

@end

@implementation DeleteFileViewController
@synthesize deleteFilePicker;

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
    pickerDataArray = [self deleteFiles]; // MAS: needs filenames to reveal widget in UIPickerView IB
    D8D(@"First filename is %@", [pickerDataArray objectAtIndex: 0]);
    
    /* MAS:
     */
    
}
/* MAS: This will retrieve array of filenames of certain type from local directory
 *      provides the option to expose filtering to user (optional feature).
 */
/* MAS: *****************************************************************************
 *************        For Vivek to code here ----               *********************
 *************  Code this as you see fit.                       *********************
 *************                                                  *********************/
- (NSArray *)deleteFiles {
    
    return NULL;
}
/* MAS: *****************************************************************************/
/* MAS: *****************************************************************************/

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1; // MAS: just the filenames
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return pickerDataArray.count;  // MAS: as many as are in the directory
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
    if (![self saveSelectedFile:selectedFilename toName:@"Vivek names this"]) {
        D8D(@"Delete failed");
    }
}

/* MAS:
 *     This save the remoteFilename (full URL) to the local /Documents directory
 *     with the appropriate local filename.
 */
- (bool)saveSelectedFile:(NSURL*)remoteFilename toName:(NSString*)localName {
    // MAS: save and verify
    NSError *error = nil;
    NSFileManager* theFM = [NSFileManager defaultManager];
    
    NSURL* documentsDirectory = [[theFM URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *destinationFile = [[NSURL alloc] initWithString:localName relativeToURL:documentsDirectory];
    [theFM copyItemAtURL:remoteFilename toURL:destinationFile error:&error];
    if (error.code == NSFileWriteFileExistsError) {
        D8E(@"Write file exists error to %@ - %@", destinationFile, error);
        error = nil;
    }
    else if (error.code == 0) {
        D8D(@"copyItemAtURL thinks it worked, HA!");
    }
    else {
        D8D(@"Copy failed %@", error.localizedDescription);
    }
    /* MAS end
     */
    
    return error;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
