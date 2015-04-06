//
//  InviteGroupVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import <UIKit/UIKit.h>

@interface InviteGroupVC : UIViewController<UITextFieldDelegate>{
    AppDelegate *delegate;
    IBOutlet UIImageView *bgSendEmail;
    IBOutlet UIImageView *bgInviteFriend;
    IBOutlet UIButton *btnHome;
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfTypingMode;
}
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnSendMailClick:(id)sender;
- (IBAction)btnInviteFriendClick:(id)sender;

@end
