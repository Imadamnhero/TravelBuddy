//
//  SendSlideShowVC.h
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 11/4/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

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
@interface SendSlideShowVC : UIViewController <MFMailComposeViewControllerDelegate,MPMediaPickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>{
    
    MPMoviePlayerViewController *mp;
    __weak IBOutlet UIButton *btnBack;
    __weak IBOutlet UIScrollView *mainScroll;
    __weak IBOutlet UIView *viewSharing;
    int currentTag;
    __weak IBOutlet UICollectionView *mainCollectionView;
}
- (IBAction)btnSendVideoToFBClick:(id)sender;
- (IBAction)btnOpenVideoClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;
- (IBAction)btnSendVideoToEmailClick:(id)sender;
- (IBAction)btnDeleteVideoClick:(id)sender;

@property int type;
@end
