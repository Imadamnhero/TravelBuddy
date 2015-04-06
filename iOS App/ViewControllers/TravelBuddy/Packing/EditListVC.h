//
//  EditListVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>

@interface EditListVC : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    AppDelegate *delegate;
    IBOutlet UITableView *mainTable;
    NSMutableArray *mainArray;
    NSMutableArray *mainArrayUpdated;
    IBOutlet UIView *viewAddNote;
    IBOutlet UIImageView *bgImgSubview;
    IBOutlet UITextField *tfTitle;
    IBOutlet UITextView *txtContent;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnHome;
    IBOutlet UIButton *btnSave;
    IBOutlet UIButton *btnCancel;
    int number;
}
@property (nonatomic) int packingId;
@property (strong, nonatomic) NSString *strTitle;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnAddClick:(id)sender;
- (IBAction)btnSaveClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;

@end
