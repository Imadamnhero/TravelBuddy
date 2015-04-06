//
//  LoginControllerVC.h
//  Restaurant app
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AsynImageButton.h"
//#import "User.h"

@interface LoginControllerVC : UIViewController <LeftTabBarIconDownloadDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,NSURLConnectionDelegate>
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
    BOOL isMemory,isMemorySignUp;
    IBOutlet UIButton *btnDone;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIButton *btnHome;
    IBOutlet UIView *viewLogin;
    IBOutlet UIView *viewSignUp;
    IBOutlet UIView *viewAbout;
    IBOutlet UIImageView *bgImgAboutView;
    IBOutlet UIImageView *bgImgLoginView;
    IBOutlet UIImageView *bgImgSignUpView;
    IBOutlet UIButton *btnAddTripIcon;
    IBOutlet UIButton *btnSignUpClick;
    IBOutlet UIButton *btnSignInClick;
    BOOL isLoginViewShowing,isAddAvatar;
    IBOutlet UIButton *btnRememberSignUp;
    IBOutlet UIView *viewPhoto;
    IBOutlet UIButton *btnCancelViewPhoto;
    IBOutlet AsynImageButton *asynImgPhoto;
    IBOutlet UIButton *btnCloseViewAbout;
    IBOutlet UIButton *btnClose;
    IBOutlet UITextField *tfUserName;
    IBOutlet UITextField *tfEmailSignUp;
    IBOutlet UITextField *tfPassSignUp;
    IBOutlet UIButton *btnDeleteAvatar;
    IBOutlet UITextView *txtAboutContent;
    IBOutlet UIView *viewForgotPassword;
    IBOutlet UITextField *tfEmailForgotPassword;
}
@property (strong, nonatomic) IBOutlet UIView *itemsView;
@property (nonatomic,strong) IBOutlet UIImageView *homeScreenImage;
- (IBAction)btnHomeClick:(id)sender;

- (IBAction)btnMemoryClick:(id)sender;
- (void)loadMainData;
- (void)checkForUpdates;
- (bool)isDataExist;
- (IBAction)btnClickToSignUp:(id)sender;

- (IBAction)btnClickToSignIn:(id)sender;
- (void)resetApplication;
- (IBAction)btnLoginClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;
- (IBAction)btnDoneClick:(id)sender;
- (IBAction)btnTakeImageClick:(id)sender;
- (IBAction)btnCloseViewAboutClick:(id)sender;
- (IBAction)btnOpenViewAboutClick:(id)sender;
- (IBAction)btnRememberSignUpClick:(id)sender;
- (IBAction)btnSignupClick:(id)sender;
- (IBAction)btnSelectCountryClick:(id)sender;
- (IBAction)btnCreateClick:(id)sender;
- (IBAction)btnForgotPasswordClick:(id)sender;
- (IBAction)btnDeleteAvatar:(id)sender;

- (IBAction)takePhotoClick:(id)sender;
- (IBAction)chooseFromLibClick:(id)sender;
//- (IBAction)btnPhotoClick:(id)sender;
- (IBAction)btnCancelImageClick:(id)sender;
- (IBAction)btnSendEmailForgotClick:(id)sender;
- (IBAction)btnCancelForgotPassClick:(id)sender;
@end
