//
//  ReceiptVC.h
//  Fun Spot App
//
//  Created by MAC on 8/21/14.
//
//

#import <UIKit/UIKit.h>

@interface ReceiptVC : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>{
    
    IBOutlet UIImageView *bgImgView;
    AppDelegate *delegate;
    NSMutableArray *mainArray;
    IBOutlet UIScrollView *mainScroll;
    IBOutlet UIButton *btnSendToMyself;
    BOOL isSendToMyself;
    IBOutlet UITextField *tfReceiptEmailAddress;
    IBOutlet UIView *viewPhoto;
    __weak IBOutlet UILabel *lblInstruction;
    IBOutlet UICollectionView *mainCollectionView;
}
@property (strong, nonatomic) UICollectionView *mainCollectionView;
@property (strong, nonatomic) NSMutableArray *mainArray;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnSendToMySelfClick:(id)sender;
- (IBAction)btnSendReceiptClick:(id)sender;
- (IBAction)btnAddNewReceiptClick:(id)sender;
- (IBAction)btnTakePhotoClick:(id)sender;
- (IBAction)btnChoosePhotoFromLibClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;
- (void) reloadScrollView;
- (void) getImage;
@end
