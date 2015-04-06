//
//  ExpenseVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>

@interface ExpenseVC : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    IMSSqliteManager *sqliteManager;
    AppDelegate *delegate;
    IBOutlet UITableView *mainTable;
    NSMutableArray *mainArray;
    NSMutableArray *arrayExpense;
    IBOutlet UIScrollView *mainScroll;
    IBOutlet UIView *viewCirclePercent;
    IBOutlet UIImageView *bgImgCircleView;
    IBOutlet UIImageView *bgImgBudgetView;
    IBOutlet UIImageView *bgImageLinePercentBudget;
    
    IBOutlet UIImageView *lineLeftTaxi;
    IBOutlet UIImageView *lineLeftEntertainment;
    IBOutlet UIImageView *lineLeftFood;
    
    UIImageView *lineLeftShopping;
    UIImageView *lineLeftGifts;
    UIImageView *lineLeftBusiness;
    
    BOOL isFood,isEnte,isTaxi,isShopping,isGift,isBussiness;
    int numberRow;
    UIButton *btnCheckFood,*btnCheckEnt,*btnCheckTaxi,*btnCheckShop,*btnCheckGift,*btnCheckBusi;
    
    IBOutlet UILabel *budgetAmount;
    IBOutlet UILabel *spentAmout;
    IBOutlet UILabel *lblSpentAmount;
    IBOutlet UILabel *lblBudgetAmount;
    IBOutlet UILabel *remainingAmount;
    IBOutlet UILabel *lblRemainingAmount;
    __weak IBOutlet UILabel *lblNoExpenseAdded;
}
@property (nonatomic) BOOL isFood,isEnte,isTaxi,isShopping,isGift,isBussiness;
@property (nonatomic) int numberRow;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)AddNewExpensiveClick:(id)sender;
@end
