//
//  NewListVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>

@interface NewListVC : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    AppDelegate *delegate;
    IBOutlet UITableView *mainTable;
    NSMutableArray *mainArray;
    IBOutlet UIImageView *bgImgSubView;
    IBOutlet UIButton *btnHome;
}
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;

@end
