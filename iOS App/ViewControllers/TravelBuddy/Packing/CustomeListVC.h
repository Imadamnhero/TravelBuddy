//
//  CustomeListVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>

@interface CustomeListVC : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
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
    IBOutlet UIButton *btnHome;
    IBOutlet UIView *viewSaveList;
}
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnAddItemClick:(id)sender;
- (IBAction)btnSaveClick:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent;
- (IBAction)btnYesClick:(id)sender;
- (IBAction)btnNoClick:(id)sender;
@end
