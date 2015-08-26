//
//  DownloadFileTableViewCell.h
//  Drupal8iOS
//
//  Created by Vivek Pandya on 8/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadFileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *lastChanged;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UILabel *fid;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@end
