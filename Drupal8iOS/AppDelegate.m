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
#import "SetUpForDemo.h" // MAS: give us some content for demo (development only)
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
    
    [SetUpForDemo addSomeFilesForTesting]; // MAS: used to demo file uploads
    return YES;
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
