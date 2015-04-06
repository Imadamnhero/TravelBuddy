//
//  AddExpenseVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>

@interface AddExpenseVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate>{
    id parent;
    IBOutlet UIButton *nextCategory;
    IBOutlet UIButton *previousCategory;
    AppDelegate *delegate;
    IBOutlet UITableView *mainTable;
    NSMutableArray *mainArray;
    IBOutlet UIImageView *bgImgCategory;
    IBOutlet UIImageView *bgImgAmount;
    int currentCategory;
    IBOutlet UILabel *lblCategoryName;
    IBOutlet UITextView *txtContent;
    IBOutlet UITextField *tfAmount;
    IBOutlet UIButton *btnHome;
    IBOutlet UIView *viewConfirmCancel;
    __weak IBOutlet UIView *viewAddCategory;
    __weak IBOutlet UIButton *btnDelete;
    __weak IBOutlet UIButton *btnIconDelete;
    __weak IBOutlet UITextField *tfCategoryName;
    BOOL isEdit;
    IMSSqliteManager *sqliteManager;
    __weak IBOutlet UILabel *lblContentConfirm;
    
    __weak IBOutlet UILabel *lblAddNewCategory;
}
- (IBAction)btnEditCategoryClick:(id)sender;
- (IBAction)btnAddNewCategpryClick:(id)sender;
- (IBAction)btnSaveCategoryClick:(id)sender;
- (IBAction)btnDeleteClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;
@property (nonatomic) float budget;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)NextCategoryClick:(id)sender;
- (IBAction)PreviousCategoryClick:(id)sender;
- (IBAction)btnSaveClick:(id)sender;
- (IBAction)btnYesClick:(id)sender;
- (IBAction)btnNoClick:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent;
@end
