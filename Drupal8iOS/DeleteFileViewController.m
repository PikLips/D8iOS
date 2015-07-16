//
//  DeleteFileViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/12/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "DeleteFileViewController.h"
#import "Developer.h"  // MAS: for development only, see which

@interface DeleteFileViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *deleteFilePicker;

@end

@implementation DeleteFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIPickerView *deleteFilePicker = [UIPickerView alloc]; //MAS: initialize
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
