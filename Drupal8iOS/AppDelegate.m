//
//  AppDelegate.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "DIOSSession.h"
#import "SGKeychain.h"
#import "Developer.h"  // MAS: for development only, see which
int d8FlagLevel = D8FLAGDEBUG; // MAS: highest level

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Reading the Drupal 8 web site if already specified in NSUserDefaults
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    DIOSSession *sharedSession  = [DIOSSession sharedSession];
    
    [sharedSession setBaseURL:[NSURL URLWithString:[defaults objectForKey:@"drupal8site"]?:@""]];
    
    NSError *error = nil;
    
    NSArray *credentials  = [SGKeychain usernamePasswordForServiceName:@"Drupal 8" accessGroup:nil error:&error];
    // First element of the array is user name
    // Second element is the password
    
    if (credentials !=nil && credentials[0] != nil) {
        
        // Here we perform a network call and verify the credentials --
        [sharedSession setBasicAuthCredsWithUsername:credentials[0] andPassword:credentials[1]];
        
    }
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    
    [self addSomeFilesForTesting]; // MAS: used to demo file uploads
    return YES;
}

/* MAS: used to list files in a directory 
 *      this code is not intended for production.
 */
-(void)addSomeFilesForTesting {
    /* MAS:
     * debug -  need to seed the Documents/ directory to test File Upload
     */
    NSError *error = nil;
    NSFileManager* theFM = [NSFileManager defaultManager];
    
    NSURL* documentsDirectory = [[theFM URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *destinationFile = [[NSURL alloc] initWithString:@"Testfile1.txt" relativeToURL:documentsDirectory];
    NSURL* urlFile1 = [[NSBundle mainBundle] URLForResource:@"Testfile1" withExtension:@"txt"];
    [theFM copyItemAtURL:urlFile1 toURL:destinationFile error:&error];
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
    NSURL *destinationFile2 = [[NSURL alloc] initWithString:@"Testfile2.txt" relativeToURL:documentsDirectory];
    NSURL* urlFile2 = [[NSBundle mainBundle] URLForResource:@"Testfile2" withExtension:@"txt"];
    [theFM copyItemAtURL:urlFile2 toURL:destinationFile2 error:&error];
    if (error.code == NSFileWriteFileExistsError) {
        D8E(@"Write file exists error to %@ - %@", destinationFile2, error);
        error = nil;
    }
    else if (error.code == 0) {
        D8D(@"copyItemAtURL thinks it worked again, HA!");
    }
    else {
        D8D(@"Copy failed %@", error.localizedDescription);
    }
    NSURL *destinationFile3 = [[NSURL alloc] initWithString:@"Testfile3.txt" relativeToURL:documentsDirectory];
    NSURL* urlFile3 = [[NSBundle mainBundle] URLForResource:@"Testfile3" withExtension:@"txt"];
    [theFM copyItemAtURL:urlFile3 toURL:destinationFile3 error:&error];
    if (error.code == NSFileWriteFileExistsError) {
        D8E(@"Write file exists error to %@ - %@", destinationFile3, error);
        error = nil;
    }
    else if (error.code == 0) {
        D8D(@"copyItemAtURL thinks it worked again and again, HA!");
    }
    else {
        D8D(@"Copy failed %@", error.localizedDescription);
    }
    NSURL *destinationFile4 = [[NSURL alloc] initWithString:@"Testfile4.txt" relativeToURL:documentsDirectory];
    NSURL* urlFile4 = [[NSBundle mainBundle] URLForResource:@"Testfile4" withExtension:@"txt"];
    [theFM copyItemAtURL:urlFile4 toURL:destinationFile4 error:&error];
    if (error.code == NSFileWriteFileExistsError) {
        D8E(@"Write file exists error to %@ - %@", destinationFile4, error);
        error = nil;
    }
    else if (error.code == 0) {
        D8D(@"copyItemAtURL thinks it worked again and again and again, HA!");
    }
    else {
        D8D(@"Copy failed %@", error.localizedDescription);
    }
    if ( d8FlagLevel == D8FLAGDEBUG) {
        [self listFilesInDirectory:documentsDirectory];
    }
    /* MAS end
     */
    
}

/* MAS: This generates some files for testing
 */
-(void)listFilesInDirectory:(NSURL *)directoryURL {
    D8D(@"listFilesInDirectory called for %@", directoryURL);
    
    NSError *error = nil;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryURL.path error:&error];
    if ( error == nil ) {
        D8D(@"Directory Contents count %d, %@", (int) directoryContents.count, directoryContents);
    }
    else {
        D8E(@"Directory error %@", error);
        error = nil;
    }

    /*
    NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey,
                           NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey, nil];

    NSArray *arrayOfFiles = [[NSFileManager defaultManager]
                      contentsOfDirectoryAtURL:directoryURL
                      includingPropertiesForKeys:properties
                      options:(NSDirectoryEnumerationSkipsHiddenFiles)
                      error:&error];
     */
    if ( !(error == nil) ) {
        D8E(@"Directory error %@", error);
    }
    
    if ( directoryContents.count == 0 ) {
        D8E(@"Directory Empty");
    }
    else {
        D8D(@"File: %@", directoryContents[0]);
    }

    // MAS: looking at it another way --
    
    NSArray *keys = [NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLLocalizedNameKey, nil];
    
    D8D(@"keys had %lu", (unsigned long)keys.count);
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                  NSDirectoryEnumerationSkipsHiddenFiles)
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             D8E(@"An enumerator error occure: %@", error);
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return NO;
                                         }];
    
    for ( NSURL *url in enumerator ) {
        
        D8D(@"URL is %@", url);
        
        NSNumber *isDirectory = nil;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if ( [isDirectory boolValue] ) {
            
            NSString *localizedName = nil;
            [url getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:NULL];
            
            NSNumber *isPackage = nil;
            [url getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
            
            if ([isPackage boolValue]) {
                D8D(@"Package at %@", localizedName);
            }
            else {
                D8D(@"Directory at %@", localizedName);
            }
        }
    }
}

-(void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

-(void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

@end
