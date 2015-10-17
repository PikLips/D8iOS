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
    
   /* Vivek:
    * Download and display Image with AFNetworking + UIImageView Category
    * with this option all threading is done by AFNetworking library
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
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
