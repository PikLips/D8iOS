



#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AddCommentViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIWebViewDelegate,MBProgressHUDDelegate>


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (nonatomic,strong) NSString *nid;
@end
