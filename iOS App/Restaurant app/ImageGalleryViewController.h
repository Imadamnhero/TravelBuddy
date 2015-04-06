//
//  ImageGalleryViewController.h
//  Fun Spot App
//
//  Created by Pradeep Sundriyal on 01/10/12.
//
//

//#import "MultipleDownload.h"
#import "BaseViewController.h"

@interface ImageGalleryViewController : BaseViewController<UIScrollViewDelegate>{
    AppDelegate *delegate;
    UIPageControl *pageControl;
    NSOperationQueue *nsQueue;
    UIScrollView *scrollView;
    IBOutlet UILabel *lblDescibeImage;
    IBOutlet UIView *viewPhoto;
    NSMutableArray *mainArray;
    __weak IBOutlet UIButton *btnSyncPhoto;
    __weak IBOutlet UIButton *btnDelete;
    id parent;
    __weak IBOutlet UIView *myViewContain;
    __weak IBOutlet UIScrollView *scrView;
    __weak IBOutlet UIImageView *myImageView;
}
@property int indexImage;
- (IBAction)SyncPhotoClick:(id)sender;
-(void)loadImagesAndAddToScrollView;
@property (assign,nonatomic) BOOL isSlideshow;
@property (assign,nonatomic) int currentPage;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl* pageControl;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
- (IBAction)btnDeleteClick:(id)sender;
- (IBAction)btnBackClick:(id)sender;
- (IBAction)btnYesClick:(id)sender;
- (IBAction)btnNoClick:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent;
//@property (nonatomic, strong) MultipleDownload *downloads;
@end
