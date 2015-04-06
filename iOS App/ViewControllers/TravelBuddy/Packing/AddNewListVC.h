//
//  AddNewListVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>

@interface AddNewListVC : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    AppDelegate *delegate;
    IBOutlet UITableView *mainTable;
    NSMutableArray *mainArray;
    IBOutlet UITextField *tfNewItem;
    IBOutlet UIImageView *bgImgListTitleView;
    IBOutlet UIImageView *bgImgAddItemView;
    IBOutlet UIImageView *bgImgListItemView;
    id parent;
    IBOutlet UIView *viewListItem;
    IBOutlet UIView *viewAddItem;
    IBOutlet UITextField *tfListName;
    IBOutlet UIView *subView;
    IBOutlet UIButton *btnHome;
    IBOutlet UIView *viewSaveList;
    IBOutlet UITextField *tfItemName;
    IBOutlet UIView *viewConfirmCancel;
    __weak IBOutlet UILabel *lblTitle;
}
@property (strong, nonatomic) NSString *strTitle;
@property (nonatomic) int premadeListId;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnAddItemClick:(id)sender;
- (IBAction)btnSaveClick:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent;
- (IBAction)btnCancelMethodClick:(id)sender;
- (IBAction)btnSaveAddItemMethodClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnCancelClick;
@property (strong, nonatomic) IBOutlet UIButton *btnSaveAddItemClick;
- (IBAction)btnYesClick:(id)sender;
- (IBAction)btnNoClick:(id)sender;
- (IBAction)btnYesConfirmClick:(id)sender;
- (IBAction)btnNoConfirmClick:(id)sender;
@end
