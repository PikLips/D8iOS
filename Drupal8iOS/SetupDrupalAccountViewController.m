//
//  SetupDrupalAccountViewController.m
//  Drupal8iOS
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS: 
 *  This allows anonymous visitors to get a Drupal account.  On the webpage
 *  interface, anonymous visitors can be permitted to automatically create an
 *  account, create an account after verifying with an email, or create an
 *  account after admin approval.
 */

/*  Vivek: This code creates POST on /user/entity. So it probably does not follow any permision settings
 *  enforced by Drupal's REGISTRATION AND CANCELLATION section.
 *  It directly follows it from ~/admin/people/permissions and just says that who can make POST on request 
 *  on /user/entity. There is a work going on and almost done. Refer to https://www.drupal.org/node/2291055.
 *  The mentioned feature request covers many other issues related to user reqistration. After this works
 *  in upstream permissions on user sign up via REST, this will follow REGISTRAION AND CANCELLATION settings.
 *  Once done, then case-by-case details sent by client to the server will differ. For example most preferred 
 *  case would be <#Visitors, but administrator approval is required#>. For that matter, the app will not send
 *  <#"status": [{"value": "1"}]#> in the JSON request becuase the created account will be unblocked by the
 *  administrator only. So, the traditional webpage user reponse may not apply.
 */


#import "SetupDrupalAccountViewController.h"
#import "Developer.h"  // MAS: for development only, see which
#import "NJOPasswordStrengthEvaluator.h"
#import "User.h"
#import "DIOSSession.h"
#import "DIOSUser.h"

@interface SetupDrupalAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *drupalUserName;
@property (weak, nonatomic) IBOutlet UITextField *drupalUserEmail;
@property (weak, nonatomic) IBOutlet UITextField *drupalUserPassword;
@property (weak, nonatomic) IBOutlet UILabel *passwordStrengthLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *passwordStrengthProgressView;
@property (weak, nonatomic) IBOutlet UITextView *validationsTextView;
@property (weak, nonatomic) IBOutlet UIButton *addAccBtn;
@property (nonatomic, strong) NJOPasswordValidator *strictValidator;
@property (weak, nonatomic) IBOutlet UITextView *emailValidationTextView;
@property (weak, nonatomic) IBOutlet UITextView *userNameValidationTextView;

@end

@implementation SetupDrupalAccountViewController

bool userNameStatus = NO;
bool passwordStatus = NO;
bool emailStatus = NO;

-(NJOPasswordValidator *)strictValidator {
    if (!_strictValidator) {
        _strictValidator = [NJOPasswordValidator validatorWithRules:@[[NJOLengthRule ruleWithRange:NSMakeRange(8, 64)], [NJORequiredCharacterRule lowercaseCharacterRequiredRule], [NJORequiredCharacterRule uppercaseCharacterRequiredRule], [NJORequiredCharacterRule symbolCharacterRequiredRule]]];
    }
    return _strictValidator;
}

-(IBAction)createUserAccount:(id)sender {
    /*  Vivek: This validates format of userName, userEmail, and userPassword, then submits it
     *  to a Drupal site as new account.
     *  Report error alert for duplicate userName and allow retry.
     *  Validations are done in separate methods.
     */
    
    /* This is the example HAL+JSON for creating User
     {"_links":{
     "type":{
     "href":"http://localhost/dr8b14/rest/type/user/user"  // This _links part will be taken care by drupal-ios-sdk
     }
     },
     "langcode": [
     {
     "value": "en"
     }
     ],
     "name": [
     {
     "value": "Pandya"
     }
     ],
     "mail": [
     {
     "value": "pandya@mail.com"
     }
     ],
     "pass": [
     {
     "value": "CH92viveK"
     }
     ],
     }

    */
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    hud.delegate = self;
    hud.labelText = @"Creating Account";
    [hud show:YES];
    
    User *sharedUser = [User sharedInstance];
    // DIOSSession *sharedSession = [DIOSSession sharedSession]; // MAS: is this needed??
    
    if ( sharedUser.name !=nil && ![sharedUser.name isEqualToString:@""] ) {
    // A user is already logged in
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Information" message:@"You are already logged in." delegate:nil cancelButtonTitle:@"Dissmiss" otherButtonTitles:nil];
        [alert show];
    }
    else {
        // Creating NSDictionary for JSON body on the fly
        NSDictionary *JSONBody =  @{
                    @"langcode": @[
                            @{
                                @"value": @"en"}
                            ],
                    @"name": @[
                            @{
                                @"value": self.drupalUserName.text
                                }
                            ],
                    @"mail": @[
                            @{
                                @"value": self.drupalUserEmail.text
                                }
                            ],
                    @"pass": @[
                            @{
                                @"value": self.drupalUserPassword.text
                 }
                 ]
          };
        
        [DIOSUser createUserWithParams:JSONBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Congratulations!" message:@"Your account has been created. Further details will be mailed by application server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
                [hud hide:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [hud hide:YES];
            
            NSInteger statusCode  = operation.response.statusCode;
            
            if ( statusCode == 403 ) {
                
              // After https://www.drupal.org/node/2291055 is solved we do not need this block of code
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Credentials" message:@"User is not authorised for this operation." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alert show];
            }
            else if( statusCode == 0 ) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"No URL to connect"] message:@"Plese specify a Drupal 8 site first \n" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alert show];
                
            }
            else {
                // Email and Password change requires existing password to be specified.
                // The code above tries to capture those requirements.  If it is missed then
                // Drupal REST will provide propper error and that will be reflected by this alert
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                               message:[NSString stringWithFormat:@"Error while creating user with %@",error.localizedDescription]
                                                              delegate:nil
                                                     cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Add notification center observer to observe change in password filed
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self.drupalUserPassword queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self updatePasswordStrength:note.object];
    }];
    
    // Add notification center observer to observe change in email filed

    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self.drupalUserEmail queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __nonnull note) {
        [self updateEmailValidation:note.object];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self.drupalUserName queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __nonnull note) {
        [self updateUserNameValidation:note.object];
    }];
    
    [self updatePasswordStrength:self];
    [self updateEmailValidation:self];
    [self updateUserNameValidation:self];
    [self changeAddAccBtnStatus];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)validateUserName:(NSString *) userName {
// Spaces are allowed; punctuation is not allowed except for periods, hyphens, apostrophes, and underscores.
    // For regExp refer http://www.raywenderlich.com/30288/nsregularexpression-tutorial-and-cheat-sheet
    
    NSString *regExPattern = @"^[A-Za-z0-9-'_.][A-Za-z0-9-'_.\\s]*";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExPattern];
    
    if ([myTest evaluateWithObject: userName]){
       
        D8D(@"User Name validation succeed");
        userNameStatus = YES;
        return YES;
        
    }
    else {
        
        D8D(@"Username validation failed");
        userNameStatus = NO;
        return NO;
       
    }
}

-(BOOL)validateEmail:(NSString*) emailString
{
    // Please refer to http://www.regular-expressions.info/email.html for more information on Regular Expression for email validation
    
    NSString *regExPattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExPattern];
    
    if ( [myTest evaluateWithObject: emailString] ) {
        
        emailStatus = YES;
        return YES;
    }
    else {
        
        emailStatus = NO;
        return NO;
        
    }
}

-(void)updateEmailValidation:(id)sender{
    NSString *email  = self.drupalUserEmail.text;
    
    if ( [email length] == 0 ) {
        
        self.emailValidationTextView.text = nil;
        emailStatus = NO;
        
    }
    else {
        
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];

        if ( [self validateEmail:email] ) {
            
                [mutableAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"It's a valid email." attributes:@{NSForegroundColorAttributeName: [UIColor greenColor]}]];
            
            self.emailValidationTextView.attributedText = mutableAttributedString;

        }
        else {
            
            [mutableAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"Please enter a valid email." attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}]];
            
            self.emailValidationTextView.attributedText = mutableAttributedString;
            
        }
    }
    [self changeAddAccBtnStatus];
}

-(void)updateUserNameValidation:(id)sender{
    NSString *userName  = self.drupalUserName.text;
    
    if ( [userName length] == 0 ){
        self.userNameValidationTextView.text = nil;
        userNameStatus = NO;
    }
    else {
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        
        if ( ![self validateUserName:userName] ) {
            
            [mutableAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"Spaces are allowed; punctuation is not allowed except for ., -, ', and _ ." attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}]];
            
            self.userNameValidationTextView.attributedText = mutableAttributedString;
            
        }
        else {
            
            self.userNameValidationTextView.text = nil;

        }
    }
    [self changeAddAccBtnStatus];
}

- (void)updatePasswordStrength:(id)sender {
    NSString *password = self.drupalUserPassword.text;
    
    if ( [password length] == 0 ) {
        self.validationsTextView.text = nil;
        self.passwordStrengthProgressView.progress = 0.0f;
        self.passwordStrengthLabel.text = nil;
        passwordStatus = NO;
    } else {
        NJOPasswordStrength strength = [NJOPasswordStrengthEvaluator strengthOfPassword:password];
        
        NSArray *failingRules = nil;
        if ( [self.strictValidator validatePassword:password failingRules:&failingRules] ) {
            self.passwordStrengthLabel.text = [NJOPasswordStrengthEvaluator localizedStringForPasswordStrength:strength];
            switch ( strength ) {
                case NJOVeryWeakPasswordStrength:
                    self.passwordStrengthProgressView.progress = 0.05f;
                    self.passwordStrengthProgressView.tintColor = [UIColor redColor];
                    break;
                case NJOWeakPasswordStrength:
                    self.passwordStrengthProgressView.progress = 0.25f;
                    self.passwordStrengthProgressView.tintColor = [UIColor orangeColor];
                    break;
                case NJOReasonablePasswordStrength:
                    self.passwordStrengthProgressView.progress = 0.5f;
                    self.passwordStrengthProgressView.tintColor = [UIColor yellowColor];
                    break;
                case NJOStrongPasswordStrength:
                    self.passwordStrengthProgressView.progress = 0.75f;
                    self.passwordStrengthProgressView.tintColor = [UIColor greenColor];
                    break;
                case NJOVeryStrongPasswordStrength:
                    self.passwordStrengthProgressView.progress = 1.0f;
                    self.passwordStrengthProgressView.tintColor = [UIColor cyanColor];
                    break;
            }
            
            self.validationsTextView.text = nil;
            passwordStatus = YES;

        } else {
            self.passwordStrengthLabel.text = NSLocalizedString(@"Invalid Password", nil);
            self.passwordStrengthProgressView.progress = 0.0f;
            self.passwordStrengthProgressView.tintColor = [UIColor redColor];
            
            NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
            for (id <NJOPasswordRule> rule in failingRules) {
                [mutableAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"• %@\n", [rule localizedErrorDescription]] attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}]];
            }
            
            self.validationsTextView.attributedText = mutableAttributedString;
            passwordStatus = NO;
        }
    }
     [self changeAddAccBtnStatus];
}

-(void)changeAddAccBtnStatus{

    self.addAccBtn.enabled = emailStatus && userNameStatus && passwordStatus;
}

@end
