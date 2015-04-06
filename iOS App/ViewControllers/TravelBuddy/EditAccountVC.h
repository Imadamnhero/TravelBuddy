//
//  EditAccountVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/14/14.
//
//

#import <UIKit/UIKit.h>
#import "AsynImageButton.h"

@interface EditAccountVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>{
    AppDelegate *delegate;
    IBOutlet UITextField *tfUserName;
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfPassword;
    IBOutlet UITextField *tfNewPass;
    IBOutlet UITextField *tfConfirmNewPass;
    IBOutlet AsynImageButton *asynImgPhoto;
    IBOutlet UIView *viewPhoto;
    IBOutlet UIImageView *bgImgView;
    IBOutlet UIButton *btnCancelImage;
    BOOL isAddAvatar;
    IBOutlet UIButton *btnDeleteAvatar;
    IBOutlet UIButton *btnRemember;
    BOOL isMemory;
}
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnRememberClick:(id)sender;
- (IBAction)btnSaveClick:(id)sender;
- (IBAction)btnDeleteAvatarClick:(id)sender;

- (IBAction)takePhotoClick:(id)sender;
- (IBAction)chooseFromLibClick:(id)sender;
- (IBAction)btnPhotoClick:(id)sender;
- (IBAction)btnCancelImageClick:(id)sender;
@end
