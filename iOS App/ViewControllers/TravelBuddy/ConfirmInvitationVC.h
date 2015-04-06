//
//  ConfirmInvitationVC.h
//  Fun Spot App
//
//  Created by MAC on 8/27/14.
//
//

#import <UIKit/UIKit.h>
#import "AsynImageButton.h"

@interface ConfirmInvitationVC : UIViewController{
    
    IBOutlet UIImageView *bgImgLogOur;
    UIViewController *m_parentViewController;
    __weak IBOutlet UIButton *btnUserInvite;
    __weak IBOutlet UILabel *lblTripName;
    __weak IBOutlet AsynImageButton *btnAvatarUserInvite;
    AppDelegate *delegate;
    __weak IBOutlet UIButton *btnAccept;
    __weak IBOutlet UIButton *btnDecline;
    __weak IBOutlet UILabel *lblTitleInvitation;
}
@property (nonatomic,strong) NSDictionary *dictInforUser;

- (IBAction)btnYesClick:(id)sender;
- (IBAction)btnNoClick:(id)sender;

@end
