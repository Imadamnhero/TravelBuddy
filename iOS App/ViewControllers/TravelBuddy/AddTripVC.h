//
//  AddTripVC.h
//  Fun Spot App
//
//  Created by Luong Anh on 8/14/14.
//
//

#import <UIKit/UIKit.h>
//#import "AbstractActionSheetPicker.h"
//#import "ActionSheetDatePicker.h"
#import "ActionSheetPicker.h"
#import "ActionSheetStringPicker.h"
#import "VRGCalendarView.h"

@interface AddTripVC : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,VRGCalendarViewDelegate>{
    AppDelegate *delegate;
    IBOutlet UITextField *tfTripName;
    IBOutlet UITextField *tfName;
    IBOutlet UITextField *tfFromDate;
    IBOutlet UITextField *tfToDate;
    IBOutlet UITextField *tfBudget;
    int typeDate;
    VRGCalendarView *calendar;
    AbstractActionSheetPicker *_actionSheetPicker;
    NSDate *selectedBegin;
    NSDate *selectedEnd;
    IBOutlet UIScrollView *mainScroll;
    IBOutlet UIImageView *bgImageTripName;
    IBOutlet UIImageView *bgImageName;
    IBOutlet UIImageView *bgImageDates;
    IBOutlet UIImageView *bgImageBudget;
    IBOutlet UIImageView *bgImageGroup;
    IBOutlet UIButton *btnCancelTrip;
    UIDatePicker *datePicker;
    IBOutlet UIButton *btnAddTrip;
    __weak IBOutlet UIView *viewCalendar;
}
@property (strong, nonatomic) NSString *isFromLogin;
@property (strong, nonatomic) IBOutlet UIView *itemsView;
- (IBAction)btnHomeClick:(id)sender;
- (IBAction)btnInviteUserClick:(id)sender;
- (IBAction)btnNextClick:(id)sender;
- (IBAction)btnCancelTripClick:(id)sender;

@end
