# D8iOS
Template iOS Application for Drupal 8 ReSTful Interface

This is a template application for all iOS devices that exercises all the non-admin ReStful interfaces to Drupal 8.  
It uses Kyle Brownings iOS SDK, with uses the AFNetworking library.  It also uses Apple source code from the Apple 
Developer library.

This project provides a very basic iOS application for using the core ReSTful interface of Drupal 8.  Features include —

1) Connect to a Drupal 8 host
2) Request creation of an account (to be approved by admin)
3) Login
4) Logout
5) Download an image
6) Download a file
7) Upload and image
8) Upload a file
9) Delete a file
10) Collect a view (i.e., articles)
11) Comment on an article


Dependencies

This project uses Kyle Browning’s iOS SDK, which uses the AFNetworking library.  These required dependencies are managed by CocoaPods.  This project also uses MBProgressHUD, SGKeyChain, and Navajo, also via CocoaPods.   However, these are UI related and are optional depending upon your application.

Development began around the time of Drupal beta 12, and there were several security-related issues that had to be worked around.  Several of these exist today with Drupal 8.0.2.  We hope these to be resolved by 8.1.  However, they seem to be architectural issues rather than bugs.

Meanwhile, to use this code four Drupal 8 core modules need to be enabled, and two modules need to be added & enable to use Drupal’s ReSTful interface and administration.  Also, several patches need to be applied to core.  These patches sometimes change between minor releases, and they are not coordinated.  Therefore, some may overlap and need to be rerolled for this app.  Also, there seems to be no convenient way to integrate change control (e.g., CocoaPods or Vagrant) for these patches.

We call this version 0.8 because we are not sure if Drupal 8.1 will resolve all of these issues.  Authentication is a particularly thorny problem, as the File and Views modules refactored into D8 core were not designed with integrated ReST security in mind.  The complexity of the problem is exacerbated by the way that Drupal uses the underlying SQL and OS security, which can vary by implementation.


Enable These Modules

Be sure that HAL, HTTP Basic Authentication, ReSTful Web Services, and Serialization are enabled in ~admin/modules.  


Add These Modules

Rest UI - https://www.drupal.org/project/restui 

This module, written by Juampy NR (https://www.drupal.org/u/juampynr), provides a “very basic user interface” for ReST admin.  It is needed to set up responses for file handling and Views.

uauth-master - https://github.com/vivekvpandya/uauth 

Vivek has written a auth helper, uauth-master that creates a response from the host to authorize a user. 


Add These Patches

These patches address the corresponding issues, all related to security (access control, authentication).  —

2291055 - https://www.drupal.org/node/2291055

This addresses an issue where unauthenticated users who send a POST to a site that allows creation of an account without admin permission get a 403.  

2310307 - https://www.drupal.org/node/2310307

This addresses the issue that File Entity does not seem to be tied to CRUD permission, perhaps because it does not implement access control. 

1927648 - https://www.drupal.org/node/1927648

This works around a related File Entity CRUD issue.

2228141 - https://www.drupal.org/node/2228141

Like the File Entity issue, this addresses and authentication issue for Views.


TDB

This app is intended to be repurposed, and most of the ReST functionality is in D8iOS.m/h .  The split view controller was used to show the native menus in the Master view while also having a web view of the site in the Detail view.  The web view will be added when we can test to ensure the URL is a Drupal 8 site.  As of this writing, the app only discovers that when logging in.
