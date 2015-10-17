//
//  CommentTableViewCell.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 9/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
    [super layoutSubviews];
    float indentPoints = self.indentationWidth * self.indentationLevel;
    
    self.userNameLeading.constant = indentPoints;
}

@end
