//
//  CreateSlideShowVC.h
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 10/16/14.
//
//

#import <UIKit/UIKit.h>
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

@interface CreateSlideShowVC : UIViewController<MPMediaPickerControllerDelegate,MFMailComposeViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    MPMoviePlayerController *moviePlayer;
    MPMoviePlayerViewController *mp;
    __weak IBOutlet UILabel *lblInstruction;
    __weak IBOutlet UICollectionView *mainCollectionView;
}
@property (nonatomic,strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic,strong)NSMutableArray *arrayImages;
- (IBAction)btnSendEmailClick:(id)sender;
- (IBAction)btnShareLinkFacebookClick:(id)sender;
- (IBAction)btnCancelViewSharingClick:(id)sender;
@end
