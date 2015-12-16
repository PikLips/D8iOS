//
//  AddCommentViewController.m
//  Drupal8iOS
//
//  Created by Vivek Pandya on 7/19/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//

#import "AddCommentViewController.h"
#import "User.h"
#import "Developer.h"
#import "D8iOS.h"
#import "DIOSComment.h"
#import "DIOSSession.h"
#import "NotifyViewController.h"

@interface AddCommentViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tipTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *editorSwitch;
@property (weak, nonatomic) IBOutlet UIWebView *bodyWebView;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (nonatomic,strong) MBProgressHUD *hud;

- (IBAction)switchEditor:(id)sender;
@end

@implementation AddCommentViewController

@synthesize nid;

#define TAG_SECTION 0

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    D8D(@"view did load\n");
    D8D(@"nib ID: %@", self.nid);
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self toggleSpinner:YES isSuccess:NO];
    [D8iOS postComment:[self.bodyTextView text] withTitle:[self.tipTitle text] onNodeID:self.nid success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self toggleSpinner:NO isSuccess:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSInteger statusCode  = operation.response.statusCode;
        if ( statusCode == 403 ) {
            [self presentViewController:[NotifyViewController notAuthorisedNotifyError]
                               animated:YES
                             completion:nil];
            
        }
        else if ( statusCode == 401 ) {
            User *user = [User sharedInstance];
            // Credentials are not valid so remove it
            [user clearUserDetails];
            DIOSSession *sharedSession = [DIOSSession sharedSession];
            sharedSession.signRequests = NO;
            
            [self presentViewController:[NotifyViewController invalidCredentialNotify]
                               animated:YES
                             completion:nil];
            
        }
        else if ( statusCode == 0 ) {
            [self presentViewController:[NotifyViewController zeroStatusCodeNotifyError:error.localizedDescription]
                               animated:YES
                             completion:nil];
        }
        
        else {
            
            NSMutableDictionary *errorRes = (NSMutableDictionary *) operation.responseObject;
            [self presentViewController:[NotifyViewController genericNotifyError:[errorRes objectForKey:@"error"]]
                               animated:YES
                             completion:nil];
        }

    }];
    
}

- (IBAction)switchEditor:(id)sender {
    
    UISegmentedControl *segmentedController = (UISegmentedControl *)sender;
    
    NSInteger index  = segmentedController.selectedSegmentIndex;
    
    if ( index == 0 ) {
        self.bodyWebView.hidden = NO;
        self.bodyTextView.hidden = YES;
        
        [self.bodyWebView loadHTMLString:self.bodyTextView.textStorage.mutableString baseURL:nil];
    }
    if ( index == 1 ) {
        self.bodyWebView.hidden = YES;
        self.bodyTextView.hidden = NO;
        
    }
}

-(void)insertHtmlTag:(NSString *)tag sender:(UIButton *)sender {
    
    NSString *startTag = [NSString stringWithFormat:@"<%@>",tag];
    NSString *endTag = [NSString stringWithFormat:@"</%@>",tag];
    
    
    NSRange selectedRange = [_bodyTextView selectedRange];
    if ( selectedRange.location != NSNotFound && selectedRange.length != 0 ) {
        
        [_bodyTextView.textStorage.mutableString insertString:startTag
                                                      atIndex:selectedRange.location];
        [_bodyTextView.textStorage.mutableString insertString:endTag
                                                      atIndex:(selectedRange.location + selectedRange.length + [startTag length])];
        _bodyTextView.selectedRange = NSMakeRange([_bodyTextView.textStorage.mutableString length], 0);
        
    }
    else {
        
        if ( sender.selected ) {
            
            [_bodyTextView.textStorage.mutableString insertString:endTag
                                                          atIndex:selectedRange.location];
            _bodyTextView.selectedRange = NSMakeRange((selectedRange.location + [endTag length]), 0);
        }
        else {
            [_bodyTextView.textStorage.mutableString insertString:startTag
                                                          atIndex:selectedRange.location];
            _bodyTextView.selectedRange = NSMakeRange((selectedRange.location + [startTag length]), 0);
        }
        sender.selected = !sender.selected;
    }
}

-(void)paragraphText:(UIButton *)sender{
    
    
    [self insertHtmlTag:@"p"
                 sender:sender];
    
}
-(void)hideKeyBoard{
    
    [_bodyTextView resignFirstResponder];
}

-(void)boldText:(UIButton *)sender{
    [self insertHtmlTag:@"b"
                 sender:sender];
    
}

-(void)italicText:(UIButton *)sender {
    [self insertHtmlTag:@"em"
                 sender:sender];
    
}

-(void)underLineText:(UIButton *)sender {
    [self insertHtmlTag:@"u"
                 sender:sender];
    
}
-(void)strikeText:(UIButton *)sender {
    [self insertHtmlTag:@"strike"
                 sender:sender];
}
-(void)blockquoteText:(UIButton *)sender {
    
    [self insertHtmlTag:@"blockquote"
                 sender:sender];
}

-(void)addLink {
    
    UIAlertView *addLinkAlert = [[UIAlertView alloc]initWithTitle:@"Enter URL for link here"
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Add", nil];
    [addLinkAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    addLinkAlert.tag = 1;
    [addLinkAlert show];
    
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ( alertView.tag == 1 ) {
        // cancel button will have index 0
        if ( buttonIndex == 1 ) {
            
            NSRange selectedRange = [_bodyTextView selectedRange];
            
            if ( selectedRange.location != NSNotFound && selectedRange.length != 0 ) {
                
                NSString *linkString = [NSString stringWithFormat:@"<a href='%@'>",[alertView textFieldAtIndex:0].text];
                
                [_bodyTextView.textStorage.mutableString insertString:linkString
                                                              atIndex:selectedRange.location];
                [_bodyTextView.textStorage.mutableString insertString:@"</a>"
                                                              atIndex:(selectedRange.location + selectedRange.length + [linkString length])];
                _bodyTextView.selectedRange = NSMakeRange([_bodyTextView.textStorage.mutableString length], 0);
                
            }
            else {
                
                NSString *linkString = [NSString stringWithFormat:@"<a href='%@'>%@</a>",[alertView textFieldAtIndex:0].text ,[alertView textFieldAtIndex:0].text ];
                
                [_bodyTextView.textStorage.mutableString insertString:linkString
                                                              atIndex:selectedRange.location];
                
            }
            
        }
    }
    else if ( alertView.tag == 2 ) {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];  // Hide modal view if user press "Dismiss" button on error alertView
    }
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    if ( [alertView textFieldAtIndex:0] ) {
        if ( [alertView textFieldAtIndex:0].text.length > 0 ) {
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
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)navigationType {
    
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
    
}

-(UIView *)inputAccessoryView {
    
    CGRect accessFrame = CGRectMake(0.0,0.0,100.0,40.0);
    UIView *inputAccessoryView = [[UIView alloc]initWithFrame:accessFrame];
    inputAccessoryView.backgroundColor = [UIColor blackColor];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneButton.frame = CGRectMake(0.0,0.0,50.0,40.0);
    [doneButton setTitle:@"Done"
                forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    
    [doneButton addTarget:self action:@selector(hideKeyBoard)
         forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:doneButton];
    UIButton *boldButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    boldButton.frame = CGRectMake(50.0, 0.0,30.0, 40.0);
    
    [boldButton setTitle:@"B" forState:UIControlStateNormal];
    [boldButton setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [boldButton setTitleColor:[UIColor blueColor]
                     forState:UIControlStateSelected];
    [boldButton addTarget:self
                   action:@selector(boldText:)
         forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:boldButton];
    
    UIButton *italicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    italicButton.frame = CGRectMake(80.0, 0.0, 30.0, 40.0);
    [italicButton setTitle:@"I"
                  forState:UIControlStateNormal];
    [italicButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
    [italicButton addTarget:self
                     action:@selector(italicText:)
           forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:italicButton];
    
    UIButton *underlineButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    underlineButton.frame = CGRectMake(110.0, 0.0, 30.0, 40.0);
    [underlineButton setTitle:@"U" forState:UIControlStateNormal];
    [underlineButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
    [underlineButton addTarget:self
                        action:@selector(underLineText:)
              forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:underlineButton];
    
    UIButton *strikeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    strikeButton.frame = CGRectMake(140.0, 0.0, 30.0, 40.0);
    [strikeButton setTitle:@"≁" forState:UIControlStateNormal];
    [strikeButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
    [strikeButton addTarget:self
                     action:@selector(strikeText:)
           forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:strikeButton];
    
    UIButton *blockquoteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    blockquoteButton.frame = CGRectMake(170.0, 0.0, 30.0, 40.0);
    [blockquoteButton setTitle:@"❝"
                      forState:UIControlStateNormal];
    [blockquoteButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
    [blockquoteButton addTarget:self
                         action:@selector(blockquoteText:)
               forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:blockquoteButton];
    
    UIButton *paragraphButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    paragraphButton.frame = CGRectMake(200.0, 0.0, 30.0, 40.0);
    [paragraphButton setTitle:@"¶" forState:UIControlStateNormal];
    [paragraphButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
    [paragraphButton addTarget:self
                        action:@selector(paragraphText:)
              forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:paragraphButton];
    
    UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    linkButton.frame = CGRectMake(230.0, 0.0, 30.0, 40.0);
    [linkButton setTitle:@"🔗" forState:UIControlStateNormal];
    [linkButton setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [linkButton addTarget:self
                   action:@selector(addLink)
         forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:linkButton];
    
    return inputAccessoryView;
}

#pragma mark TextView adjustments while typing

-(void)keyboardWillShow:(NSNotification *)notification {
    [UIView beginAnimations:nil context:nil];
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newRect = self.bodyTextView.frame;
    //Down size your text view
    newRect.size.height -=   (newRect.size.height - endRect.size.height) ;
    self.bodyTextView.frame = newRect;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    [UIView beginAnimations:nil context:nil];
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newRect = self.bodyTextView.frame;
    //Down size your text view
    newRect.size.height +=  (newRect.size.height - endRect.size.height);
    self.bodyTextView.frame = newRect;
    [UIView commitAnimations];
    
}

/** @function toggleSpinner: (bool) on isSuccess:(bool)flag
 *  @param on A bool indicating whether the activity indicator should be on or off.
 *  @param flag A bool indication whether the operation is successful or not. This param will be ignored if on is YES
 *  @abstract This implements MBProgressHUB as an alternative to UIActivityIndicatorView .
 *  @seealso https://github.com/jdg/MBProgressHUD
 *  @discussion This needs to be a Cocoapod and abstracted into its own class with specific objects
 *              for each use (more illustrative).
 *  @return N/A
 *  @throws N/A
 *  @updated
 *
 */

-(void)toggleSpinner:(bool) on isSuccess:(bool)flag{
    if ( on ) {
        _hud = [[MBProgressHUD alloc ] initWithView:super.view];
        [super.view addSubview:_hud];
        _hud.delegate = nil;
        _hud.labelText = @"Posting the comment ...";
        [_hud show:YES];
    }
    else {
        if (!flag) {
            [_hud hide:YES];
        }
        else{
            UIImageView *imageView;
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
            imageView = [[UIImageView alloc] initWithImage:image];
            
            _hud.customView = imageView;
            _hud.mode = MBProgressHUDModeCustomView;
            
            _hud.labelText = @"Completed";
            dispatch_async(dispatch_get_main_queue(), ^{
                // need to put main theread on sleep for 2 second so that "Completed" HUD stays on for 2 seconds
                sleep(1);
                [_hud hide:YES];
                [self dismissViewControllerAnimated:YES
                                         completion:nil];
            });
        }
        
    }
}


@end
