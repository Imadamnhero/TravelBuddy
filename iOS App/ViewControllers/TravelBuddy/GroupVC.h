//
//  GroupVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"


@interface GroupVC : UIViewController<UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate>{
    
    AppDelegate *delegate;
    IBOutlet UITableView *mainTable;
    NSMutableArray *mainArray;
    IBOutlet UIImageView *bgImgGroup;
    NSMutableDictionary *imageDownloadsInProgress;
    IMSSqliteManager *sqliteManager;
}
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnInviteGroup:(id)sender;

@end
