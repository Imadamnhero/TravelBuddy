//
//  PackingVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>

@interface PackingVC : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    AppDelegate *delegate;
    IBOutlet UITableView *mainTable;
    NSMutableArray *mainArray;
    IBOutlet UIView *subViewChooseList;
    IBOutlet UILabel *lblTitleStart;
    IBOutlet UILabel *lblOr;
    IBOutlet UILabel *lblLine;
    IBOutlet UIButton *btnCustomeList;
    IBOutlet UIButton *btnNewList;
    IBOutlet UILabel *lblStart;
    IBOutlet UIButton *btnIConCustomeList;
    IBOutlet UIButton *btnIconNewList;
    IBOutlet UIImageView *bgImgSubView;
    int secondLoad;
}
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnCustomClick:(id)sender;
- (IBAction)btnNewListClick:(id)sender;

@end
