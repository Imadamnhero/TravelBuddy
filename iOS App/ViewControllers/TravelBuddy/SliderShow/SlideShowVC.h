//
//  SlideShowVC.h
//  Fun Spot App
//
//  Created by MAC on 8/29/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface SlideShowVC : UIViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource,MKMapViewDelegate,MPMediaPickerControllerDelegate,MFMailComposeViewControllerDelegate,UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>{
    AppDelegate *delegate;
    IBOutlet UIView *subViewCreateSlide;
    NSMutableArray *mainArray,*arrayFilePathVideos,*arrayFilePathSaved;
    IBOutlet UIScrollView *mainScroll;
    __weak IBOutlet UIScrollView *scrollPreviews;
    IBOutlet MKMapView *mapView;
    MPMoviePlayerViewController *mp;
    MFMailComposeViewController *mailComposer;
    __weak IBOutlet UIScrollView *scrollChooseVideo;
    __weak IBOutlet UIButton *btnDone;
    __weak IBOutlet UIView *viewSharing;
    __weak IBOutlet UILabel *lblInstruction;
    __weak IBOutlet UIButton *btnBack;
    __weak IBOutlet UIButton *btnHome;
    int currentTag;
    IBOutlet UICollectionView *mainCollectionView;
}
@property (strong, nonatomic) UICollectionView *mainCollectionView;
@property (strong, nonatomic) NSMutableArray *mainArray;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnCreateClick:(id)sender;
- (IBAction)btnPreviewClick:(id)sender;
- (IBAction)btnSendSlideShowClick:(id)sender;
- (IBAction)btnBackClick:(id)sender;

- (IBAction)btnCancelClick:(id)sender;
- (IBAction)btnPreviewCreateSlideClick:(id)sender;
- (IBAction)btnSendMailCreateSlideClick:(id)sender;
- (IBAction)btnSendFacebookCreateSlideClick:(id)sender;
- (void) reloadScrollView;
- (void) getImage;
- (IBAction)btnDeleteSlideshowClick:(id)sender;
@end
