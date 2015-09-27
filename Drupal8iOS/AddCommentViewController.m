
#import "AddCommentViewController.h"
#import "User.h"

//#import "UIAlertView+AFNetworking.h"
#import "DIOSComment.h"
#import "DIOSSession.h"

@interface AddCommentViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tipTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *editorSwitch;
@property (weak, nonatomic) IBOutlet UIWebView *bodyWebView;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
- (IBAction)switchEditor:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AddCommentViewController

@synthesize nid;

#define TAG_SECTION 0


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(Article *)article{
//
//    if (!_article) {
//        _article = [[NSMutableDictionary alloc]init];
//    
//    }
//    return _article;
//
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.bodyWebView.hidden = YES;
    self.bodyTextView.hidden = NO;
    [self.editorSwitch setSelectedSegmentIndex:1];
    self.bodyWebView.delegate = self;
    
//    if (self.tip != nil) {
//        
//    
//        NSLog(@"entered");
//        NSLog(@"%@",self.tip);
//           }
    
    NSLog(@"view did load\n");
    NSLog(self.nid);
   
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    //NSLog(@"%@",self.tag);

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//return @"Tag";
//
//}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [[UITableViewCell alloc]init];
//    
//    cell = [tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];
//    cell.detailTextLabel.text = [self.tip objectForKey:@"tag"];
//    return cell;
//    
//
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
*/
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"selectTag"] ) {
//        TnTSelectTagViewController *vc = (TnTSelectTagViewController *)segue.destinationViewController;
//        vc.delegate = self;
//        if ([self.tip objectForKey:@"tag"]) {
//            
//            NSString *tagID = [NSString string];
//            
//            
//            NSString *tagString = [self.tip objectForKey:@"tag"];
//            if ([tagString isEqualToString:@"Linux"]) {
//                tagID = @"1";
//            }
//            else   {
//                tagID = @"2";
//            }
//            
//            
//            vc.selectedValue = @{@"name":[self.tip objectForKey:@"tag"],@"tid":tagID};
//        }
//        
//        
//        
//    }
//    
//}


- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    
    
    User *user = [User sharedInstance];
    
    
    /* Vivek: <#Note#> This JSON request works fine with my 8.0.x branch but this does not currently work on beta14
     *              I am looking into this. But I sespect that this code will not require change. It must be some patch required on Drupal side.
     
     Given below is working JSON for 8.0.x merge on my beta 14 setup
     
     {
     "_links": {
     "type": {
     "href": "http://localhost/dr8b14/rest/type/comment/comment"
     },
     "http://localhost/dr8b14/relation/comment/comment/entity_id": [
     { "href": "http://localhost/dr8b14/rest/type/comment/comment/node/1"}
     ]
     },
     "entity_id": [
     {
     "target_id": "1"
     }
     ],
     "langcode": [
     {
     "value": "en"
     }
     ],
     "subject": [
     {
     "value": "test"
     }],
     
     "uid":[
     {
     
     "target_id": 1
     }
     ],
     "status": [
     {
     "value": "1"
     }
     ],
     "entity_type": [
     {
     "value": "node"
     }
     ],
     "comment_type": [
     {
     "target_id": "comment"
     }
     ],
     "field_name": [
     {
     "value": "comment"
     }
     ],
     "comment_body": [
     {
     "value": "Example comment message."
     }
     ]
     }
     
     
     */
    
    NSDictionary *params=
    @{
      
      @"entity_id": @[
              @{
                  @"target_id": self.nid
                  }
              ],
      @"subject": @[
              @{
                  @"value": [self.tipTitle text]
                  }],
      
      @"uid":@[
              @{
                  
                  @"target_id":user.uid
                  }
              ],
      @"status": @[
              @{
                  @"value": @"1"
                  }
              ],
      @"entity_type": @[
              @{
                  @"value": @"node"
                  }
              ],
      @"comment_type": @[
              @{
                  @"target_id": @"comment"
                  }
              ],
      @"field_name": @[
              @{
                  @"value": @"comment"
                  }
              ],
      @"comment_body": @[
              @{
                  @"value":[self.bodyTextView text]
                  }
              ]
      };
    
    MBProgressHUD  *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = @"Posting comment...";
    [hud show:YES];
    [DIOSComment createCommentWithParams:params relationID:self.nid type:@"comment" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        UIImageView *imageView;
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
        
        hud.customView = imageView;
        hud.mode = MBProgressHUDModeCustomView;
        
        hud.labelText = @"Completed";
        dispatch_async(dispatch_get_main_queue(), ^{
            // need to put main theread on sleep for 2 second so that "Completed" HUD stays on for 1 seconds
            sleep(1);
            [hud hide:YES];
        });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        
        NSInteger statusCode  = operation.response.statusCode;
        
        if ( statusCode == 403 ){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"User is not authorised for this operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
           
            alert.tag = 2; // For error related alerts tag is 2
            [alert show];
            
            
            
        }
        else if(statusCode == 401){
            User *user = [User sharedInstance];
            [user clearUserDetails];
            DIOSSession *sharedSession = [DIOSSession sharedSession];
            sharedSession.signRequests = NO;
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please verify login credentials first." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
           alert.tag = 2; // For error related alerts tag is 2
            [alert show];
            
        }
        else if( statusCode == 0 ){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"] message:@"Plese specify a Drupal 8 site first \n" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            alert.tag = 2; // For error related alerts tag is 2
            [alert show];
            
        }
        
        else {
            
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                           message:[NSString stringWithFormat:@"Error while posting the comment with error code %@",error.localizedDescription]
                                                          delegate:nil
                                                 cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            alert.tag = 2; // For error related alerts tag is 2
            [alert show];
        }
        
        
    }];

    
    
 
    
    
   
}

- (IBAction)switchEditor:(id)sender {
    
    
    UISegmentedControl *segmentedController = (UISegmentedControl *)sender;
    
    NSInteger index  = segmentedController.selectedSegmentIndex;
    
    if (index == 0) {
        self.bodyWebView.hidden = NO;
        self.bodyTextView.hidden = YES;
       
        [self.bodyWebView loadHTMLString:self.bodyTextView.textStorage.mutableString baseURL:nil];
    }
    if (index == 1) {
        self.bodyWebView.hidden = YES;
        self.bodyTextView.hidden = NO;
        
    }
    
}



-(void)insertHtmlTag:(NSString *)tag sender:(UIButton *)sender{
    
    NSString *startTag = [NSString stringWithFormat:@"<%@>",tag];
    NSString *endTag = [NSString stringWithFormat:@"</%@>",tag];
    
    
    NSRange selectedRange = [_bodyTextView selectedRange];
    if (selectedRange.location != NSNotFound && selectedRange.length != 0) {
        
        [_bodyTextView.textStorage.mutableString insertString:startTag atIndex:selectedRange.location];
        [_bodyTextView.textStorage.mutableString insertString:endTag atIndex:(selectedRange.location + selectedRange.length + [startTag length])];
        _bodyTextView.selectedRange = NSMakeRange([_bodyTextView.textStorage.mutableString length], 0);
        
    }
    else{
        
        if (sender.selected) {
            
            [_bodyTextView.textStorage.mutableString insertString:endTag atIndex:selectedRange.location];
            _bodyTextView.selectedRange = NSMakeRange((selectedRange.location + [endTag length]), 0);
        }
        else
        {
            [_bodyTextView.textStorage.mutableString insertString:startTag atIndex:selectedRange.location];
            _bodyTextView.selectedRange = NSMakeRange((selectedRange.location + [startTag length]), 0);
        }
        sender.selected = !sender.selected;
        
        
    }
    
    
}

-(void)paragraphText:(UIButton *)sender{
    

    [self insertHtmlTag:@"p" sender:sender];
    
}
-(void)hideKeyBoard{

    [_bodyTextView resignFirstResponder];
}

-(void)boldText:(UIButton *)sender{
    [self insertHtmlTag:@"b" sender:sender];

}

-(void)italicText:(UIButton *)sender{
    [self insertHtmlTag:@"em" sender:sender];

}

-(void)underLineText:(UIButton *)sender{
    [self insertHtmlTag:@"u" sender:sender];

}
-(void)strikeText:(UIButton *)sender{
    [self insertHtmlTag:@"strike" sender:sender];
}
-(void)blockquoteText:(UIButton *)sender{

    [self insertHtmlTag:@"blockquote" sender:sender];
}

-(void)addLink{

    UIAlertView *addLinkAlert = [[UIAlertView alloc]initWithTitle:@"Enter URL for link here" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [addLinkAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    addLinkAlert.tag = 1;
    [addLinkAlert show];

}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1) {
        NSLog(@"here");
        
        // cancel button will have index 0
        if (buttonIndex == 1) {
            
            
            NSRange selectedRange = [_bodyTextView selectedRange];
            
            if (selectedRange.location != NSNotFound && selectedRange.length != 0) {
                
                NSString *linkString = [NSString stringWithFormat:@"<a href='%@'>",[alertView textFieldAtIndex:0].text];
                
                [_bodyTextView.textStorage.mutableString insertString:linkString atIndex:selectedRange.location];
                [_bodyTextView.textStorage.mutableString insertString:@"</a>" atIndex:(selectedRange.location + selectedRange.length + [linkString length])];
                _bodyTextView.selectedRange = NSMakeRange([_bodyTextView.textStorage.mutableString length], 0);
                
            }
            else{
                
                NSString *linkString = [NSString stringWithFormat:@"<a href='%@'>%@</a>",[alertView textFieldAtIndex:0].text ,[alertView textFieldAtIndex:0].text ];
                
                [_bodyTextView.textStorage.mutableString insertString:linkString atIndex:selectedRange.location];
                
                
            }
            
        }
    }
    else if (alertView.tag == 2){
        NSLog(@"It reaches here");
        [self dismissViewControllerAnimated:YES completion:nil];  // Hide modal view if user press "Dismiss" button on error alertView
    }
    
    
    
    
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    
    if ([alertView textFieldAtIndex:0]) {
        if ([alertView textFieldAtIndex:0].text.length > 0) {
            return YES;
            
        }
        else
            return  NO;
    }
    else{
        return NO;
    }
    
}

#pragma mark UIWebView Delegate method 
// this method make links to be opened in Safari
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
    
}



//-(void)uploadImage{
//
//}

-(UIView *)inputAccessoryView{
    
    CGRect accessFrame = CGRectMake(0.0,0.0,100.0,40.0);
    UIView *inputAccessoryView = [[UIView alloc]initWithFrame:accessFrame];
    inputAccessoryView.backgroundColor = [UIColor blackColor];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneButton.frame = CGRectMake(0.0,0.0,50.0,40.0);
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // [doneButton addTarget:self action:@selector(hideKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [doneButton addTarget:self action:@selector(hideKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:doneButton];
    UIButton *boldButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    boldButton.frame = CGRectMake(50.0, 0.0,30.0, 40.0);
    
    [boldButton setTitle:@"B" forState:UIControlStateNormal];
    [boldButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [boldButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [boldButton addTarget:self action:@selector(boldText:) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:boldButton];
    
    UIButton *italicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    italicButton.frame = CGRectMake(80.0, 0.0, 30.0, 40.0);
    [italicButton setTitle:@"I" forState:UIControlStateNormal];
    [italicButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [italicButton addTarget:self action:@selector(italicText:) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:italicButton];
    
    UIButton *underlineButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    underlineButton.frame = CGRectMake(110.0, 0.0, 30.0, 40.0);
    [underlineButton setTitle:@"U" forState:UIControlStateNormal];
    [underlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [underlineButton addTarget:self action:@selector(underLineText:) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:underlineButton];
    
    UIButton *strikeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    strikeButton.frame = CGRectMake(140.0, 0.0, 30.0, 40.0);
    [strikeButton setTitle:@"≁" forState:UIControlStateNormal];
    [strikeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [strikeButton addTarget:self action:@selector(strikeText:) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:strikeButton];
    
    UIButton *blockquoteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    blockquoteButton.frame = CGRectMake(170.0, 0.0, 30.0, 40.0);
    [blockquoteButton setTitle:@"❝" forState:UIControlStateNormal];
    [blockquoteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [blockquoteButton addTarget:self action:@selector(blockquoteText:) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:blockquoteButton];
    
    
    UIButton *paragraphButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    paragraphButton.frame = CGRectMake(200.0, 0.0, 30.0, 40.0);
    [paragraphButton setTitle:@"¶" forState:UIControlStateNormal];
    [paragraphButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [paragraphButton addTarget:self action:@selector(paragraphText:) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:paragraphButton];
    
    UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    linkButton.frame = CGRectMake(230.0, 0.0, 30.0, 40.0);
    [linkButton setTitle:@"🔗" forState:UIControlStateNormal];
    [linkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [linkButton addTarget:self action:@selector(addLink) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:linkButton];
//    
//    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    imageButton.frame = CGRectMake(260.0, 0.0, 30.0, 40.0);
//    [imageButton setTitle:@"🌈" forState:UIControlStateNormal];
//    [imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [imageButton addTarget:self action:@selector(uploadImage) forControlEvents:UIControlEventTouchUpInside];
//    [inputAccessoryView addSubview:imageButton];
//    
    
    return inputAccessoryView;
    
    
}

//-(void)backButtonSelected:(id)object{
//    
//    NSDictionary *tag = (NSDictionary *)object;
//    [self.tip setObject:[tag objectForKey:@"name"] forKey:@"tag"];
//   // self.tag = object;
//}

#pragma mark TextView adjustments while typing


- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:nil];
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newRect = self.bodyTextView.frame;
    //Down size your text view
    newRect.size.height -=   (newRect.size.height - endRect.size.height) ;
    self.bodyTextView.frame = newRect;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    [UIView beginAnimations:nil context:nil];
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newRect = self.bodyTextView.frame;
    //Down size your text view
    newRect.size.height +=  (newRect.size.height - endRect.size.height);
    self.bodyTextView.frame = newRect;
    [UIView commitAnimations];
    
}


@end
