//
//  FileDetailsTableViewCell.h
//  Drupal8iOS
//
//  Created by Vivek Pandya on 8/19/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *lastChanged;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UILabel *fid;

@end
