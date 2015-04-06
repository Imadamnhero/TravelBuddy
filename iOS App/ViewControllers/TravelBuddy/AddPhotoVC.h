//
//  AddPhotoVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>
#import "AsynImageButton.h"

@interface AddPhotoVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>{
    
    IBOutlet AsynImageButton *asynImgPhoto;
    IBOutlet UIView *viewPhoto;
    AppDelegate *delegate;
    IBOutlet UIImageView *bgViewLabelDes;
    IBOutlet UIButton *btnDelete;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIButton *btnTakePhoto;
    IBOutlet UIButton *btnSelectPhoto;
    BOOL isAddedPhoto;
    IBOutlet UITextField *tfDescribePhoto;
    IBOutlet UIButton *btnAddPhotoSmall;
    IBOutlet UIView *viewConfirmDeletePhoto;
    IBOutlet UILabel *lblTitleViewPhoto;
    UIImage *currentImage;
}
@property (strong, nonatomic) IBOutlet UIView *viewDescription;
@property (assign, nonatomic) BOOL isAddPhoto;
@property (assign, nonatomic) BOOL isTakePhoto;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)takePhotoClick:(id)sender;
- (IBAction)chooseFromLibClick:(id)sender;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnDeletePhotoCLick:(id)sender;
- (IBAction)btnPhotoClick:(id)sender;
- (IBAction)btnCancelImageClick:(id)sender;
- (IBAction)btnSaveClick:(id)sender;
- (IBAction)btnAddPhotoSmallClicck:(id)sender;
- (IBAction)btnYesClick:(id)sender;
- (IBAction)btnNoClick:(id)sender;

@end
