//
//  SetUpForDemo.m
//  Drupal8iOS
//
//  Created by Michael Smith on 10/18/15.
//  Copyright © 2015 PikLips. All rights reserved.
//
/*  MAS: This helper allows for demos without the need for server-side content download
 */
#import "SetUpForDemo.h"
#import "Developer.h"

@implementation SetUpForDemo
/* MAS: used to list files in a directory
 *      this code is not intended for production.
 */
+(void)addSomeFilesForTesting {
    /* MAS:
     * debug -  need to seed the Documents/ directory to test File Upload
     */
    NSError *error = nil;
    NSFileManager* theFM = [NSFileManager defaultManager];
    
    NSURL* documentsDirectory = [[theFM URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *destinationFile = [[NSURL alloc] initWithString:@"Testfile1.txt" relativeToURL:documentsDirectory];
    NSURL* urlFile1 = [[NSBundle mainBundle] URLForResource:@"Testfile1" withExtension:@"txt"];
    [theFM copyItemAtURL:urlFile1 toURL:destinationFile error:&error];
    if ( error.code == NSFileWriteFileExistsError ) {
        D8E(@"Write file exists error to %@ - %@", destinationFile, error);
        error = nil;
    }
    else if ( error.code == 0 ) {
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
    else if ( error.code == 0 ) {
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
    if ( error.code == NSFileWriteFileExistsError ) {
        D8E(@"Write file exists error to %@ - %@", destinationFile4, error);
        error = nil;
    }
    else if ( error.code == 0 ) {
        D8D(@"copyItemAtURL thinks it worked again and again and again, HA!");
    }
    else {
        D8D(@"Copy failed %@", error.localizedDescription);
    }
    if ( d8FlagLevel == D8FLAGDEBUG ) {
        [self listFilesInDirectory:documentsDirectory];
    }
    /* MAS end
     */
    
}

/* MAS: This generates some files for testing
 */
+(void)listFilesInDirectory:(NSURL *)directoryURL {
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
            
            if ( [isPackage boolValue] ) {
                D8D(@"Package at %@", localizedName);
            }
            else {
                D8D(@"Directory at %@", localizedName);
            }
        }
    }
}

@end
