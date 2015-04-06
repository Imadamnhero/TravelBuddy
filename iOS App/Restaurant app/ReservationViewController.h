//
//  ReservationViewController.h
//  Restaurant app
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ReservationViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    MFMailComposeViewController *mailComposeViewController;
    NSDateFormatter *dateFormatter;
    NSString *phoneNumber;
}

@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (retain, nonatomic) IBOutlet UITextField *peopleTextField;
@property (retain, nonatomic) IBOutlet UITextField *dateTextField;
@property (retain, nonatomic) IBOutlet UITextField *phoneTextField;
@property (retain, nonatomic) IBOutlet UIButton *sendReservationButton;
@property (retain, nonatomic) IBOutlet UIButton *callUsButton;

- (IBAction)buttonPressed:(id)sender;

@end
