//
//  AAPLGridViewCell.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/13/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
 A collection view cell that displays a thumbnail image.
 
 */

#import "AAPLGridViewCell.h"
#import "Developer.h"  // MAS: for development only, see which

@interface AAPLGridViewCell ()
@property (strong) IBOutlet UIImageView *imageView;
@end

@implementation AAPLGridViewCell

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

@end
