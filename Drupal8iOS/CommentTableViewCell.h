//
//  CommentTableViewCell.h
//  Drupal8iOS
//
//  Created by Vivek Pandya on 9/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIWebView *commentBody;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdated;
@property (weak, nonatomic) IBOutlet UILabel *commentSubject;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameLeading;

@end
