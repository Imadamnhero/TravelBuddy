//
//  PreviewSlideshow.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//
#import "AsynImageButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

@interface PreviewSlideshow : UIViewController<UITextFieldDelegate,MPMediaPickerControllerDelegate,UIWebViewDelegate>{
    AppDelegate *delegate;
    IBOutlet UIImageView *bgSendEmail;
    IBOutlet UIImageView *bgInviteFriend;
    IBOutlet UIButton *btnHome;
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfTypingMode;
    __weak IBOutlet AsynImageButton *btnImagePlayVideo;
    MPMoviePlayerController *moviePlayer;
    __weak IBOutlet UIButton *btnPlay;
    __weak IBOutlet UIView *viewPlayVideo;
    BOOL isDownloading;
    BOOL isDownloaded;
}
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *strImageLink;
@property (strong, nonatomic) NSString *strVideoLink;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnSendMailClick:(id)sender;
- (IBAction)btnInviteFriendClick:(id)sender;
- (IBAction)btnPlayVideoClick:(id)sender;

@end
