//
//  TripDetailVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/18/14.
//
//

#import <UIKit/UIKit.h>
#import "IMSSqliteManager.h"
#import "VersionObj.h"

@interface TripDetailVC : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>{
    AppDelegate *delegate;
    IMSSqliteManager *sqlManager;

    IBOutlet UIView *viewSending;
    IBOutlet UIView *viewSendSlideshow;
    IBOutlet UIView *viewSendEmail;
    IBOutlet UIImageView *bgImgDate;
    IBOutlet UIImageView *bgImgBudget;
    IBOutlet UIImageView *bgImgDates;
    IBOutlet UIImageView *bgImgSendReceipt;
    IBOutlet UIImageView *bgImgSendSlider;
    IBOutlet UIImageView *bgImgSend;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIImageView *bgImgLinePercentBudget;
    BOOL isSendToMysefl;
    IBOutlet UITextField *tfReceiptEmail;
    IBOutlet UIButton *btnSendToMySelf;
    IBOutlet UILabel *lblBudgetAmount;
    IBOutlet UILabel *lblTitleBudget;
    IBOutlet UILabel *lblSpentAmount;
    IBOutlet UILabel *lblTitleSpent;
    IBOutlet UILabel *lblRemainingAmount;
    IBOutlet UILabel *lblTitleRemaining;
    IBOutlet UILabel *lblTitleSlideshowPhoto;
    IBOutlet UILabel *lblSlideshowPhotoNumber;
    IBOutlet UILabel *lblGroupPhotoNumber;
    IBOutlet UILabel *lblTitleGroupPhoto;
    IBOutlet UILabel *lblDateFrom;
    
    IBOutlet UILabel *lblTitleFrom;
    IBOutlet UILabel *lblTitleTo;
    IBOutlet UILabel *lblDateTo;
    
    __weak IBOutlet UIView *viewBudget;
    __weak IBOutlet UITextField *tfAmount;
    __weak IBOutlet UIView *viewAddBudget;
    __weak IBOutlet UIView *viewEdited;
    __weak IBOutlet UITextField *tfEdit;
    IBOutlet UIView *viewConfirmEndTrip;
//    VersionObj *objVersion;
}
@property (nonatomic,readwrite) BOOL isFromAddTrip;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)SendByEmailClick:(id)sender;
- (IBAction)SendSlideShowClick:(id)sender;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnEndTripClick:(id)sender;
- (IBAction)btnAddPhotoClick:(id)sender;
- (IBAction)btnAddNewExpenseClick:(id)sender;
- (IBAction)btnBackClick:(id)sender;
- (IBAction)btnAddBudgetClick:(id)sender;
- (IBAction)btnCancelEndTripClick:(id)sender;
- (IBAction)btnConfirmEndTripClick:(id)sender;

- (IBAction)btnSendReceiptEmailClick:(id)sender;
- (IBAction)btnSendToMyseftClick:(id)sender;
// all method sync

// sync note
+ (void) SyncNoteData;
+ (void)UpdateNoteVersion:(VersionObj*)objVersion;

//sync expense
+ (void) SyncExpenseData;

//sync Packing title
+ (void) SyncPackingTitleData;

//sync Packing Item
+ (void) SyncPackingItemData;

//sync photo
+ (void) syncPhoto;

//sync User in trip
+ (void) syncUsers;

//sync Category
+ (void) SyncCategoryData;
@end
