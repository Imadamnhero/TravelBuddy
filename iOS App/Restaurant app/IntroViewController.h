//
//  IntroViewController.h
//  Restaurant app
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface IntroViewController : UIViewController <LeftTabBarIconDownloadDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
{
    UIImageView *homeScreenImage;
    AppDelegate *delegate;
    IBOutlet UIButton *btnCreatNewAccount;
    IBOutlet UIButton *btnSelectCountry;
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfPassword;
    IBOutlet UIButton *btnLogin;
    IBOutlet UILabel *lblMemorize;
    
    IBOutlet UIView *pickerView;
    NSMutableArray *arrayCountry;
    UIPickerView *picker;
    NSString *strCountry;
    NSString *strShotCountry;
    IBOutlet UIButton *btnMemory;
    BOOL isMemory;
    IBOutlet UIButton *btnDone;
    IBOutlet UIButton *btnCancel;
}
@property (strong, nonatomic) IBOutlet UIView *itemsView;
@property (nonatomic,strong) IBOutlet UIImageView *homeScreenImage;
- (void)goMainScreen;
- (IBAction)btnMemoryClick:(id)sender;
- (void)loadMainData;
- (void)checkForUpdates;
- (bool)isDataExist;

- (void)resetApplication;
- (IBAction)btnLoginClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;
- (IBAction)btnDoneClick:(id)sender;

- (IBAction)btnSignupClick:(id)sender;
- (IBAction)btnSelectCountryClick:(id)sender;
@end
