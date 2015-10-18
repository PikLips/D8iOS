//
//  CommentsTableViewController.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 9/21/15.
//  Copyright © 2015 PikLips. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "D8iOS.h"
#import "Developer.h"
#import "Comment.h"
#import "CommentTableViewCell.h"

@interface CommentsTableViewController ()
@property (nonatomic,strong) NSMutableArray * commentList;
@end

@implementation CommentsTableViewController
@synthesize nid;

-(NSMutableArray *)commentList {
    if ( !_commentList ) {
        _commentList = [[NSMutableArray alloc]init];
    }
    return _commentList;
}

-(IBAction)getData{
    [D8iOS getCommentDataforNodeID:self.nid withView:self.view completion:^(NSMutableArray *commentList) {
        if (commentList != nil) {
            self.commentList = commentList;
            [self.tableView reloadData];
        }
    }];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( self.commentList.count !=0 ) {
        return self.commentList.count;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( self.commentList.count != 0 ) {
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
        
        Comment *comment = [self.commentList objectAtIndex:indexPath.row];
        cell.userName.text = comment.name;
        cell.lastUpdated.text = comment.changed;
        cell.commentSubject.text = comment.subject;
        [cell.commentBody loadHTMLString:comment.comment_body baseURL:[NSURL URLWithString:DRUPAL8SITE]];
        cell.indentationLevel = [comment.thread intValue];
        D8D(@"%ld",(long)cell.indentationLevel);
        cell.indentationWidth = 10.0f;
    
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noComments" forIndexPath:indexPath];
        
        return cell;
    }
}

@end
