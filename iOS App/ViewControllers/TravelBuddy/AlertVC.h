//
//  AlertVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"

@interface AlertVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,IconDownloaderDelegate>{
    
    AppDelegate *delegate;
    IBOutlet UITableView *mainTable;
    NSMutableArray *mainArray;
    IBOutlet UIImageView *bgImgView;
    BOOL isSelectAll;
    IBOutlet UIButton *btnHome;
    IBOutlet UITextView *txtContent;
    IBOutlet UIView *viewConfirmSendAlert;
    NSMutableDictionary *imageDownloadsInProgress;
    IMSSqliteManager *sqliteManager;
}
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnSendAlert:(id)sender;
- (IBAction)btnYesClick:(id)sender;
- (IBAction)btnNoClick:(id)sender;

@end
