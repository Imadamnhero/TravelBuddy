//
//  SendReceiptEmailVC.h
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 11/3/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface SendReceiptEmailVC : UIViewController <MFMailComposeViewControllerDelegate>{
    __weak IBOutlet UIScrollView *scrollChooseImages;
    __weak IBOutlet UIButton *btnSendMail;
    __weak IBOutlet UIButton *btnBack;
}
@property BOOL isSendMySelf;
@property (nonatomic,strong) NSString *emailFriend;
@property (nonatomic,strong) NSMutableArray *arrayImages;
@end
