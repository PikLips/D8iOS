//
//  DownloadPictureViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/15/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/*  MAS: This displays the image that was selected from the 
 *  DownloadPicturesViewController.
 */

#import "DownloadPictureViewController.h"
#import "UIImageView+AFNetworking.h"


@interface DownloadPictureViewController ()

@end

@implementation DownloadPictureViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = @"Downloading image...";
    [hud show:YES];
    
    // MAS:Vivek - Here you have coded three ways to load the image. have you chosen your preferred way?
    
    // Now code will load image from self.pictureURL
    
    /*=========================
     Download image with CoreNetworking
     With this option all thread managment is done by application developer
    ==========================
     
     // Create new thread
     dispatch_queue_t myqueue = dispatch_queue_create("myqueue", NULL);
     
     // execute a task on that queue asynchronously
     dispatch_async(myqueue, ^{
     NSURL *url = [NSURL URLWithString:[self.pictureURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];;
     NSData *data = [NSData dataWithContentsOfURL:url];
     dispatch_async(dispatch_get_main_queue(), ^{
     self.imageView.image = [UIImage imageWithData:data]; //UI updates should be done on the main thread
     });
     });
    
     
     */
    
    
    /*=================================
     Download and display Image with AFNetworking + UIImageView Category
     with this option all threading is done by AFNetworking library 
     ==============================================================
     */
   
    
    NSURL *url = [NSURL URLWithString:self.pictureURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       [hud hide:YES];
                                       [self.imageView setImage:image];
                                       [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
                                       self.navigationController.navigationBar.topItem.title = self.imageName;
                              
                          }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       [hud hide:YES];
                                       
                                       UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                                      message:[NSString stringWithFormat:@"Error with %@",error.localizedDescription]
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"Dismiss"
                                                                            otherButtonTitles: nil];
                                       [alert show];
                              
                          }];
    
    
    /*=============================================================
     Images can also be Downloaded with AFHTTPRequestOperation 
     Here in this option threading is done by AFNetworking library 
     ==============================================================
    
     NSURL *url = [NSURL URLWithString:self.pictureURL];
     NSURLRequest *request = [NSURLRequest requestWithURL:url];
     
     AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     operation.responseSerializer = [AFImageResponseSerializer serializer];
     
     [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
     NSLog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
     float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToRead));
     [(UIProgressView *)hud setProgress:percentDone];
     hud.labelText = [NSString stringWithFormat:@"%f",(100.0 * percentDone)];
     }];

     
     [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
     
     self.imageView.image = responseObject;
    
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
     NSLog(@"Error: %@", error);
     }];
     
     [operation start];
     
     */

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
