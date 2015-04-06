//
//  NoteVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"

@interface NoteVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>{
    
    AppDelegate *delegate;
    IMSSqliteManager *sqlManager;

    IBOutlet UITableView *mainTable;
    NSMutableArray *mainArray;
    NSMutableArray *mainArrayAvatar;
    IBOutlet UIView *viewAddNote;
    IBOutlet UIImageView *bgImgSubView;
    IBOutlet UITextField *tfTitle;
    IBOutlet UITextView *txtContent;
    IBOutlet UIView *subView;
    IBOutlet UIImageView *bgSubView;
    IBOutlet UIView *viewConfirmCancel;
    
    NSMutableDictionary *imageDownloadsInProgress;
    VersionObj *objVersion;

}
- (IBAction)btnRefreshListNote:(id)sender;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnAddNoteClick:(id)sender;
- (IBAction)btnSaveNoteClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;
- (IBAction)btnYesClick:(id)sender;
- (IBAction)btnNoClick:(id)sender;

@end
