//
//  AAPLAssetViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/13/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
 A view controller displaying an asset full screen.
 
 */

#import "AAPLAssetViewController.h"
#import "Developer.h"  // MAS: for development only, see which


@implementation CIImage (Convenience)
- (NSData *)aapl_jpegRepresentationWithCompressionQuality:(CGFloat)compressionQuality {
    static CIContext *ciContext = nil;
    if (!ciContext) {
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        ciContext = [CIContext contextWithEAGLContext:eaglContext];
    }
    CGImageRef outputImageRef = [ciContext createCGImage:self fromRect:[self extent]];
    UIImage *uiImage = [[UIImage alloc] initWithCGImage:outputImageRef scale:1.0 orientation:UIImageOrientationUp];
    if (outputImageRef) {
        CGImageRelease(outputImageRef);
    }
    NSData *jpegRepresentation = UIImageJPEGRepresentation(uiImage, compressionQuality);
    return jpegRepresentation;
}
@end


@interface AAPLAssetViewController () <PHPhotoLibraryChangeObserver>
@property (weak) IBOutlet UIImageView *imageView;
@property (strong) IBOutlet UIBarButtonItem *playButton;
@property (strong) IBOutlet UIBarButtonItem *space;
@property (strong) IBOutlet UIBarButtonItem *trashButton;
@property (strong) IBOutlet UIBarButtonItem *editButton;
@property (strong) IBOutlet UIProgressView *progressView;
// RSR: add uploadPictureButton
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadPictureButton;
// RSR: end

@property (strong) AVPlayerLayer *playerLayer;
@property (assign) CGSize lastImageViewSize;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer; //MAS: for pinchMe zoom
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer; //MAS: for panMe
@property (nonatomic, strong) UIRotationGestureRecognizer *rotationGestureRecognizer; //MAS: for rotateMe zoom
// RSR:
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
// RS: end

@end


@implementation AAPLAssetViewController

static NSString * const AdjustmentFormatIdentifier = @"com.example.apple-samplecode.SamplePhotosApp";

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    /* MAS: Now that the still image can be bigger than the video framesize, we should be able to zoom in on it in the viewer.
     */
    if ( self.pinchGestureRecognizer == nil) {
        self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchMe:)];
        
        [self.imageView addGestureRecognizer:[self pinchGestureRecognizer]];
    }
    if ( self.panGestureRecognizer == nil) {
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMe:)];
        
        [self.imageView addGestureRecognizer:[self panGestureRecognizer]];
    }
    if ( self.rotationGestureRecognizer == nil) {
        self.rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateMe:)];
        [self.imageView addGestureRecognizer:[self rotationGestureRecognizer]];
    }
    
    // RSR: for doubleTap -
    if (self.doubleTapGestureRecognizer == nil) {
        self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapMe:)];
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self.imageView addGestureRecognizer:[self doubleTapGestureRecognizer]];
    }
    // RSR:end
    
    self.pinchGestureRecognizer.delegate = self;
    self.panGestureRecognizer.delegate = self;
    self.rotationGestureRecognizer.delegate = self;
    
    self.imageView.userInteractionEnabled = YES;
    /* MAS:
     */

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];  // MAS: added to expose buttons
    
    if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        self.toolbarItems = @[self.playButton, self.space, self.uploadPictureButton, self.space, self.trashButton]; // RSR: added code to put uploadButton in
    } else {
        self.toolbarItems = @[self.space, self.uploadPictureButton, self.space, self.trashButton]; // RSR: added code to put uploadButton in
    }
    
    BOOL isEditable = ([self.asset canPerformEditOperation:PHAssetEditOperationProperties] || [self.asset canPerformEditOperation:PHAssetEditOperationContent]);
    self.editButton.enabled = isEditable;
    
    BOOL isTrashable = NO;
    if (self.assetCollection) {
        isTrashable = [self.assetCollection canPerformEditOperation:PHCollectionEditOperationRemoveContent];
    } else {
        isTrashable = [self.asset canPerformEditOperation:PHAssetEditOperationDelete];
    }
    self.trashButton.enabled = isTrashable;
    
    [self.view layoutIfNeeded];
    [self updateImage];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!CGSizeEqualToSize(self.imageView.bounds.size, self.lastImageViewSize)) {
        [self updateImage];
    }
}

- (void)updateImage
{
    self.lastImageViewSize = self.imageView.bounds.size;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.imageView.bounds) * scale, CGRectGetHeight(self.imageView.bounds) * scale);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    // Download from cloud if necessary
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
            self.progressView.hidden = (progress <= 0.0 || progress >= 1.0);
        });
    };
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result) {
            self.imageView.image = result;
        }
    }];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the album we're interested on (to its metadata, not to its collection of assets)
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.asset];
        if (changeDetails) {
            // it changed, we need to fetch a new one
            self.asset = [changeDetails objectAfterChanges];
            
            if ([changeDetails assetContentChanged]) {
                [self updateImage];
                
                if (self.playerLayer) {
                    [self.playerLayer removeFromSuperlayer];
                    self.playerLayer = nil;
                }
            }
        }
        
    });
}

#pragma mark - Actions

/* MAS: Gesture Recognizers
 *      Allow the still image to be zoomed --
 */
- (void) pinchMe: (UIPinchGestureRecognizer *) pinchGestureRecognizer {
    
    CGFloat scale = [pinchGestureRecognizer scale];
    
    //self.imageView.transform = CGAffineTransformScale(self.imageView.transform, scale, scale);
    [self.imageView setTransform:(CGAffineTransformScale(self.imageView.transform, scale, scale))];
    pinchGestureRecognizer.scale = 1.0;
    
}
/* MAS: and rotated --
 */
-(void)rotateMe:(UIRotationGestureRecognizer *)rotationGestureRecognizer{
    
    [self.imageView setTransform:(CGAffineTransformRotate(self.imageView.transform, rotationGestureRecognizer.rotation))];
    
    rotationGestureRecognizer.rotation = 0.0;
}
/* MAS: and panned
 */
-(void)panMe:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    CGPoint touchLocation = [panGestureRecognizer translationInView:self.view];
    CGPoint currentImageCenter = self.imageView.center;
    currentImageCenter.x += touchLocation.x;
    currentImageCenter.y += touchLocation.y;
    
    self.imageView.center = currentImageCenter;
    
    [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
}

/* RSR: handle doubleTap
 *      This resets the image in the viewer to its original position.
 */
- (void) doubleTapMe:(UITapGestureRecognizer *) doubleTapGestureRecognizer {
    
    [self.imageView setCenter:CGPointMake(CGRectGetMidX([self.view bounds]), CGRectGetMidX([self.view bounds]))];
    [self.imageView setTransform:CGAffineTransformIdentity];
    [self.imageView.superview addSubview:self.imageView];
}
/* RSR: do three things at once
 *      This allows the panMe, rotateME, and pinchME methods to work simultaneously.
 */
- (BOOL) gestureRecognizer:(nonnull UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
/* RSR
 */

- (void)applyFilterWithName:(NSString *)filterName
{
    
    PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
    [options setCanHandleAdjustmentData:^BOOL(PHAdjustmentData *adjustmentData) {
        return [adjustmentData.formatIdentifier isEqualToString:AdjustmentFormatIdentifier] && [adjustmentData.formatVersion isEqualToString:@"1.0"];
    }];
    [self.asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
        // Get full image
        NSURL *url = [contentEditingInput fullSizeImageURL];
        int orientation = [contentEditingInput fullSizeImageOrientation];
        CIImage *inputImage = [CIImage imageWithContentsOfURL:url options:nil];
        inputImage = [inputImage imageByApplyingOrientation:orientation];
        
        // Add filter
        CIFilter *filter = [CIFilter filterWithName:filterName];
        [filter setDefaults];
        [filter setValue:inputImage forKey:kCIInputImageKey];
        CIImage *outputImage = [filter outputImage];
        
        // Create editing output
        NSData *jpegData = [outputImage aapl_jpegRepresentationWithCompressionQuality:0.9f];
        PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:AdjustmentFormatIdentifier formatVersion:@"1.0" data:[filterName dataUsingEncoding:NSUTF8StringEncoding]];
        
        PHContentEditingOutput *contentEditingOutput = [[PHContentEditingOutput alloc] initWithContentEditingInput:contentEditingInput];
        [jpegData writeToURL:[contentEditingOutput renderedContentURL] atomically:YES];
        [contentEditingOutput setAdjustmentData:adjustmentData];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:self.asset];
            request.contentEditingOutput = contentEditingOutput;
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                D8E(@"Error: %@", error.localizedDescription);
            }
        }];
    }];
}

- (IBAction)handleEditButtonItem:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
    
    if ([self.asset canPerformEditOperation:PHAssetEditOperationProperties]) {
        NSString *favoriteActionTitle = !self.asset.favorite ? NSLocalizedString(@"Favorite", @"") : NSLocalizedString(@"Unfavorite", @"");
        [alertController addAction:[UIAlertAction actionWithTitle:favoriteActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:self.asset];
                [request setFavorite:![self.asset isFavorite]];
            } completionHandler:^(BOOL success, NSError *error) {
                if (!success) {
                    D8E(@"Error: %@", error.localizedDescription);
                }
            }];
        }]];
    }
    if ([self.asset canPerformEditOperation:PHAssetEditOperationContent]) {
        if (self.asset.mediaType == PHAssetMediaTypeImage) {
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Sepia", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self applyFilterWithName:@"CISepiaTone"];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Chrome", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self applyFilterWithName:@"CIPhotoEffectChrome"];
            }]];
        }
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Revert", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:self.asset];
                [request revertAssetContentToOriginal];
            } completionHandler:^(BOOL success, NSError *error) {
                if (!success) {
                    D8E(@"Error: %@", error.localizedDescription);
                }
            }];
        }]];
    }
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:alertController animated:YES completion:NULL];
    alertController.popoverPresentationController.barButtonItem = sender;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
}

- (IBAction)handleTrashButtonItem:(id)sender
{
    void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self navigationController] popViewControllerAnimated:YES];
            });
        } else {
            D8E(@"Error: %@", error.localizedDescription);
        }
    };
    
    if (self.assetCollection) {
        // Remove asset from album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [changeRequest removeAssets:@[self.asset]];
        } completionHandler:completionHandler];
        
    } else {
        // Delete asset from library
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:@[self.asset]];
        } completionHandler:completionHandler];
        
    }
}

- (IBAction)handlePlayButtonItem:(id)sender
{
    if (!self.playerLayer) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.playerLayer) {
                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
                    playerItem.audioMix = audioMix;
                    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                    
                    CALayer *layer = self.view.layer;
                    [layer addSublayer:playerLayer];
                    [playerLayer setFrame:layer.bounds];
                    [player play];
                }
            });
        }];
        
    } else {
        [self.playerLayer.player play];
    }
    
}

// RSR: method to handle upload button pressed
- (IBAction)handleUploadPictureButton:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm upload" message:@"Vivek - use alertView delegate method to upload picture to Drupal" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

- (void)alertView:(nonnull UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
 
    // RSR: request image from library
        __block UIImage *uploadImage = nil;
        
        [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:NULL resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                uploadImage = result;
            }
        }];
        
        // RSR: save image to file to test
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        if (basePath == nil) {
            D8E(@"Path not found");
        }

        NSError *err = nil;
        NSData * binaryImageData = UIImagePNGRepresentation(uploadImage);
        
        [binaryImageData writeToFile:[basePath stringByAppendingPathComponent:@"myfile.png"] options:NSDataWritingAtomic error:&err];
        
        D8D(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
        
        // end copy
        
        /******* Vivek! *******/
        /* put code here to   */
        /* upload file named: */
        /*  uploadImage       */
        /**********************/
        
        
    }
    
}
// RSR: end

@end


