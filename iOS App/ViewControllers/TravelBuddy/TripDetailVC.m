//
//  TripDetailVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/18/14.
//
//

#import "TripDetailVC.h"
#import "LoginControllerVC.h"
#import "AddPhotoVC.h"
#import "AddExpenseVC.h"
#import "IntroViewController.h"
#import "InviteGroupVC.h"
#import "ExpenseObj.h"
#import "PackingItemObj.h"
#import "PackingTitleObj.h"
#import "SendSlideShowVC.h"
#import "SendReceiptEmailVC.h"

@interface TripDetailVC ()
{
    NSString *userId_Owner;
}
@end

@implementation TripDetailVC
@synthesize isFromAddTrip;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        if (buttonIndex == 0){
            [self afterClickEndTrip];
        }
}
-(void)getTripInformation{
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // DATA PROCESSING 1
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *kURLString = [NSString stringWithFormat:@"%@/get_trip.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:[userDefault objectForKey:@"userTripId"] forKey:@"tripid"];
        [request setPostValue:[userDefault objectForKey:@"userId"] forKey:@"userid"];
        [request setDelegate:self];
        [request setTimeOutSeconds:10];
        [request startSynchronous];
        
        NSError *error = [request error];
        if (!error) {
            NSLog(@"NO error");
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"%@",dict);
            if (!dict) {
                [delegate showAlert:@"The server could not be found"];
            }else{
                if ([[dict objectForKey:@"success"] intValue] == 0) {
                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                            message:@"Your current trip is ended"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [someError show];
                     }];
                    
//                    [self drawRect:bgImgLinePercentBudget.frame];
//                    [self drawSpent];
                }else{
                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                        lblTitle.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"tripname"]];
                        
                        lblDateFrom.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"start_date"]];
                        lblDateTo.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"finish_date"]];
                        
                        lblBudgetAmount.text = [NSString stringWithFormat:@"$ %@",[dict objectForKey:@"budget"]];
                        if ([[dict objectForKey:@"budget"] intValue] <= 0) {
                            viewAddBudget.hidden = NO;
                            viewBudget.hidden = YES;
                        }else{
                            viewAddBudget.hidden = YES;
                            viewBudget.hidden = NO;
                        }
//                        float numberRemaining = [[dict objectForKey:@"budget"] floatValue] - 0;
//                        lblRemainingAmount.text = [NSString stringWithFormat:@"$ %0.2f",numberRemaining];
                        
                        lblGroupPhotoNumber.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"photo_count"]];
                        //                    [self drawRect:bgImgLinePercentBudget.frame];
                        //                    [self drawSpent];
                        //tri code
                        userId_Owner = [dict objectForKey:@"ownerid"];
                    }];
                }
            }
        }
//        else
//            [delegate showAlert:@"The server could not be found"];
//    });
}
- (void) syncData:(NSString*)tableName{
    
    if ([tableName isEqualToString:@""]) {
        
    }else{
        
        if ([tableName isEqualToString:@"Notes"]) {
            if (delegate.isUpdateAvailableForNote == false) {
                return;
            }
            delegate.isUpdateAvailableForNote = false;
            [TripDetailVC SyncNoteData];
            delegate.isUpdateAvailableForNote = true;
        }else if ([tableName isEqualToString:@"Expenses"]) {
            [TripDetailVC SyncExpenseData];
        }else if ([tableName isEqualToString:@"PackingTitles"]) {
            [TripDetailVC SyncPackingTitleData];
        }else if ([tableName isEqualToString:@"SyncPhoto"]) {
            [TripDetailVC syncPhoto];
        }else if ([tableName isEqualToString:@"SyncUser"]) {
            [TripDetailVC syncUsers];
        }
    }
    
}
- (void) inviteGroup {
    InviteGroupVC *tripDetailController = [[InviteGroupVC alloc] initWithNibName:@"InviteGroupVC" bundle:nil];
    [self.navigationController pushViewController:tripDetailController animated:YES];
    isFromAddTrip = NO;
}
- (void)viewWillAppear:(BOOL)animated{
    //    [self getTripInformation];
    //    return;
    if (isFromAddTrip) {
        [self performSelector:@selector(inviteGroup) withObject:nil afterDelay:1.0];
    }
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    //    NSMutableArray *arrayExp = [[NSMutableArray alloc] init];
//    if (netStatus == NotReachable) {
    TripObj *tripInfor     = [[TripObj alloc] init];
    
    [userDefault setObject:@"1" forKey:@"addingTrip"];
    [userDefault synchronize];
    lblTitle.text = [USER_DEFAULT objectForKey:@"userTripName"];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    @synchronized(self)
    {
        array = [sqliteManager getTripInfor:[[userDefault objectForKey:@"userTripId"] intValue]];
    }
    if (array.count >0) {
        tripInfor  = [array objectAtIndex:0];
        //[NSString stringWithFormat:@"%@",tripInfor.tripLocation];
        
        lblDateFrom.text = [NSString stringWithFormat:@"%@",tripInfor.startDate];
        lblDateTo.text = [NSString stringWithFormat:@"%@",tripInfor.finishDate];
        
        if ([tripInfor.budget intValue] <= 0) {
            viewAddBudget.hidden = NO;
            viewBudget.hidden = YES;
        }else{
            viewAddBudget.hidden = YES;
            viewBudget.hidden = NO;
        }
        lblBudgetAmount.text = [NSString stringWithFormat:@"$ %@",tripInfor.budget];
    }
    [self drawSpent];
    
    if (netStatus == NotReachable) {
        
    }else{
//        int continueSync = [[USER_DEFAULT objectForKey:@"mainSyncing"] intValue];
//        [delegate showAlert:[NSString stringWithFormat:@"%d",continueSync]];
//        if (continueSync == 0) {
//            NSLog(@"set 1");
//            [USER_DEFAULT setObject:@"1" forKey:@"mainSyncing"];
//            [USER_DEFAULT synchronize];
            [[NSOperationQueue mainQueue] cancelAllOperations];
            NSOperationQueue *newQueue = [[NSOperationQueue alloc]init];
            [newQueue addOperationWithBlock:^{
                
                NSLog(@"=========================================== begin =========================================== ===========================================");
                [self getTripInformation];
                [TripDetailVC SyncCategoryData];
                [TripDetailVC SyncExpenseData];
                [TripDetailVC SyncNoteData];
                [TripDetailVC syncUsers];
                [TripDetailVC SyncPackingTitleData];
                
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [self drawSpent];
//                    NSLog(@"set ve 0");
//                    [USER_DEFAULT setObject:@"0" forKey:@"mainSyncing"];
//                    [USER_DEFAULT synchronize];
                }];
            }];
//        }
        [delegate.myQueue cancelAllOperations];
        [delegate.myQueue addOperationWithBlock:^{
            [TripDetailVC syncPhoto];
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                //get number of local photo
                [self getImage];
            }];
        }];
    }
    
}
- (void) drawSpent{
    
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    NSMutableArray *arrayExp = [[NSMutableArray alloc] init];
    @synchronized(self)
    {
        arrayExp = [sqliteManager getExpenses:0];
    }
    
    float sumFood = 0;
    for (int i = 0; i < arrayExp.count; i++) {
        ExpenseObj *expenseObj = [[ExpenseObj alloc] init];
        expenseObj = [arrayExp objectAtIndex:i];
        sumFood += [expenseObj.money floatValue];
    }
    lblSpentAmount.text = [NSString stringWithFormat:@"$ %0.2f",sumFood];
    float budget = [[lblBudgetAmount.text substringFromIndex:2] floatValue];
    float numberRemaining = budget - sumFood;
    lblRemainingAmount.text = [NSString stringWithFormat:@"$ %0.2f",numberRemaining];
    [self drawRect:bgImgLinePercentBudget.frame];
}
- (void) getImage{
    NSMutableArray *arrayPhoto = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    @synchronized(self){
        arrayPhoto = [sqlManager getPhotoItems:[[userDefault objectForKey:@"userTripId"] intValue] andReceipt:0];
    }
    lblSlideshowPhotoNumber.text = [NSString stringWithFormat:@"%d",arrayPhoto.count];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"0" forKey:@"syncExpense"];
    [userDefault setObject:@"0" forKey:@"syncCategory"];
    [userDefault setObject:@"0" forKey:@"syncNote"];
    [userDefault setObject:@"0" forKey:@"syncPackingTitle"];
    [userDefault setObject:@"0" forKey:@"syncPackingItem"];
    [userDefault setObject:@"0" forKey:@"syncUser"];
    [userDefault synchronize];
    // Do any additional setup after loading the view from its nib.
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sqlManager = [[IMSSqliteManager alloc] init];
    
    //get number of photo
//    [self getImage];
    //    objVersion = [[VersionObj alloc] init];
    float main_top = 0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        main_top = 0;
    }
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    
    bgImgBudget.layer.cornerRadius = bgImgDate.layer.cornerRadius = bgImgDates.layer.cornerRadius = bgImgSend.layer.cornerRadius = bgImgSendReceipt.layer.cornerRadius = bgImgSendSlider.layer.cornerRadius = 5.0;
    
    lblTitle.text = [NSString stringWithFormat:@"%@",[userDefault objectForKey:@"tripName"]];
    //    [self drawRect:bgImgLinePercentBudget.frame];
    
    [lblTitleBudget setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:17.f]];
    [lblBudgetAmount setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:17.f]];
    
    [lblTitleSpent setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:13.f]];
    [lblSpentAmount setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:14.f]];
    
    [lblTitleRemaining setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:13.f]];
    [lblRemainingAmount setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:14.f]];
    
    [lblTitleSlideshowPhoto setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
    [lblSlideshowPhotoNumber setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
    
    [lblTitleGroupPhoto setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
    [lblGroupPhotoNumber setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
    
    [lblTitleFrom setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:12.f]];
    [lblDateFrom setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
    
    [lblTitleTo setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:12.f]];
    [lblDateTo setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
    
    [viewEdited setHidden:YES];
    
}
- (void)drawRect:(CGRect)rect {
    bgImgLinePercentBudget.layer.cornerRadius = 3.0;
    float numberBudget = [[lblBudgetAmount.text substringFromIndex:2] floatValue];
    if (numberBudget == 0) {
        numberBudget = 2200;
    }
    float spent = [[lblSpentAmount.text substringFromIndex:2] floatValue];
    float percent = spent/numberBudget;
    if (percent>1) {
        percent = 1;
    }
    rect.size.width = 300*percent;
    bgImgLinePercentBudget.frame = rect;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SendByEmailClick:(id)sender {
    viewSending.hidden = YES;
    viewSendEmail.hidden = NO;
}

- (IBAction)SendSlideShowClick:(id)sender {
    SendSlideShowVC *sendSlide = [[SendSlideShowVC alloc]init];
    [self.navigationController pushViewController:sendSlide animated:YES];
//    viewSending.hidden = YES;
//    viewSendSlideshow.hidden = NO;
}

- (IBAction)btnHomeClick:(id)sender {
    if (self.itemsView.hidden) {
        self.itemsView.hidden = NO;
        [delegate.leftTabBarViewCtrl showLeftTabBar:self.itemsView show:YES delegate:self rect:self.itemsView.frame selected:@""];
        
        [UIView animateWithDuration:0.2f
                              delay:0.1f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGRect rect = self.itemsView.frame;
                             rect.origin.x = 0;
                             self.itemsView.frame = rect;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];
    } else {
        [UIView animateWithDuration:0.2f
                              delay:0.1f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGRect rect = self.itemsView.frame;
                             rect.origin.x = -rect.size.width;
                             self.itemsView.frame = rect;
                         }
                         completion:^(BOOL finished){
                             self.itemsView.hidden = YES;
                             [delegate.leftTabBarViewCtrl showLeftTabBar:self.itemsView show:NO delegate:self rect:self.itemsView.frame selected:@""];
                         }];
    }
}
-(void)afterClickEndTrip{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *kURLString = [NSString stringWithFormat:@"%@/end_trip.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[userDefault objectForKey:@"userId"] forKey:@"userid"];
    [request setPostValue:[userDefault objectForKey:@"userTripId"] forKey:@"tripid"];
    
    [request setDelegate:self];
    [request startSynchronous];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //userid,tripname, name,start_date, finish_date,trip_budget
    NSError *error = [request error];
    if (!error) {
        NSLog(@"NO error");
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSData *response = [request responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSLog(@"%@",dict);
        if ([dict objectForKey:@"success"] == 0) {
            //            [delegate showAlert:[dict objectForKey:@"message"]];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self endTrip];
        }
    }
}
- (void) endTrip{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"0" forKey:@"addingTrip"];
    [userDefault synchronize];
    
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[IntroViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            [self performSelector:@selector(pushView:) withObject:viewController afterDelay:0.6];
            break;
        }
    }
}
- (IBAction)btnEndTripClick:(id)sender {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
//        [Common showNetworkFailureAlert];
    } else {
        //[self performSelector:@selector(afterClickEndTrip) withObject:nil afterDelay:1.0];
        viewConfirmEndTrip.hidden = NO;
    }
    
    //    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    [userDefault setObject:@"0" forKey:@"addingTrip"];
    //
    //    for (UIViewController *viewController in self.navigationController.viewControllers) {
    //        if ([viewController isKindOfClass:[IntroViewController class]]) {
    //            [self.navigationController popToViewController:viewController animated:YES];
    //            [self performSelector:@selector(pushView:) withObject:viewController afterDelay:0.6];
    //            break;
    //        }
    //    }
}
- (void) pushView:(UIViewController*)viewController{
    IntroViewController *vc = (IntroViewController*)viewController;
    [vc goMainScreen];
}
- (IBAction)btnAddPhotoClick:(id)sender {
    AddPhotoVC *tripDetailController = [[AddPhotoVC alloc] initWithNibName:@"AddPhotoVC" bundle:nil];
    [self.navigationController pushViewController:tripDetailController animated:YES];
}

- (IBAction)btnAddNewExpenseClick:(id)sender {
    AddExpenseVC *addExpensiveController = [[AddExpenseVC alloc] initWithNibName:@"AddExpenseVC" bundle:nil];
    addExpensiveController.budget = [[lblBudgetAmount.text substringFromIndex:2] floatValue];
    [self.navigationController pushViewController:addExpensiveController animated:YES];
}

- (IBAction)btnBackClick:(id)sender {
    viewSendEmail.hidden = viewSendSlideshow.hidden = YES;
    viewSending.hidden = NO;
}

- (IBAction)btnAddBudgetClick:(id)sender {
    if ([tfAmount.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input amount budget"];
        return;
    }
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [Common showNetworkFailureAlert];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
        [self afterClickAddBudget];
    }
}

- (IBAction)btnCancelEndTripClick:(id)sender {
    viewConfirmEndTrip.hidden = YES;
}

- (IBAction)btnConfirmEndTripClick:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Deleting..." animated:YES];
    [self afterClickEndTrip];
    viewConfirmEndTrip.hidden = YES;
}
-(void) afterClickAddBudget{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *kURLString = [NSString stringWithFormat:@"%@/add_budget.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[userDefault objectForKey:@"userId"] forKey:@"userid"];
    [request setPostValue:[NSNumber numberWithDouble:[[tfAmount.text substringFromIndex:2] doubleValue]] forKey:@"budget"];
    
    [request setDelegate:self];
    [request startSynchronous];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //userid, budget (double)
    NSError *error = [request error];
    if (!error) {
        NSLog(@"NO error");
        
        NSData *response = [request responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSLog(@"%@",dict);
        if ([dict objectForKey:@"success"] == 0) {
            [delegate showAlert:[dict objectForKey:@"message"]];
        }else{
            [delegate showAlert:[dict objectForKey:@"message"]];
            [sqlManager updateTripBudget:[NSString stringWithFormat:@"%0.2f",[[dict objectForKey:@"budget"] floatValue]] tripId:[[userDefault objectForKey:@"userTripId"] intValue]];
            [self getTripInformation];
            lblRemainingAmount.text = [NSString stringWithFormat:@"$ %0.2f",[[dict objectForKey:@"budget"] floatValue]];
//            viewAddBudget.hidden = YES;
//            viewBudget.hidden = NO;
//            [self drawSpent];
        }
    }
}
- (IBAction)btnSendReceiptEmailClick:(id)sender {
    if ([tfReceiptEmail.text isEqualToString:@""] && (isSendToMysefl == NO)) {
        [delegate showAlert:@"Please input an email address"];
        return;
    }
    else{
        if (tfReceiptEmail.text.length>0) {
            if(![self validateEmail:tfReceiptEmail.text]) {
                [delegate showAlert:@"Email is invalid!"];
                return;
            }else{
                [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading" animated:YES];
                SendReceiptEmailVC *sendReceipt = [[SendReceiptEmailVC alloc]init];
                sendReceipt.emailFriend = tfReceiptEmail.text;
                sendReceipt.isSendMySelf = isSendToMysefl;
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self.navigationController pushViewController:sendReceipt animated:YES];
            }
        }
        else{
            SendReceiptEmailVC *sendReceipt = [[SendReceiptEmailVC alloc]init];
            sendReceipt.emailFriend = tfReceiptEmail.text;
            sendReceipt.isSendMySelf = isSendToMysefl;
            [self.navigationController pushViewController:sendReceipt animated:YES];
        }
    }
}
- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}
- (IBAction)btnSendToMyseftClick:(id)sender {
    if (isSendToMysefl) {
        isSendToMysefl = false;
        [btnSendToMySelf setSelected:NO];
    }else{
        isSendToMysefl = YES;
        [btnSendToMySelf setSelected:YES];
    }
}



#pragma text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 200, self.view.frame.size.width, self.view.frame.size.height);
    if (tfAmount.text.length == 0) {
        tfAmount.text = [NSString stringWithFormat:@"$ %@",tfAmount.text];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == tfAmount) {
        if (tfAmount.text.length == 0) {
            tfAmount.text = [NSString stringWithFormat:@"$ "];
        }
    }
    return YES;
}
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 200, self.view.frame.size.width, self.view.frame.size.height);
    if (textField == tfAmount) {
        if ([tfAmount.text isEqualToString:@"$ "] || [tfAmount.text isEqualToString:@""]) {
            tfAmount.text = @"";
        }else{
            if (tfAmount.text.length < 2) {
                tfAmount.text=@"";
            }else if (![self validateDecimal:[tfAmount.text substringFromIndex:2]]) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Amount is invalid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                tfAmount.text=@"";
            }
        }
    }
}
- (BOOL)validateDecimal:(NSString*)inputString{
    NSNumberFormatter * formatDecimal = [[NSNumberFormatter alloc] init];
    [formatDecimal setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [formatDecimal numberFromString:inputString];
    if (myNumber == Nil || [myNumber intValue] == 0) {
        return NO;
    }else
        return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGRect rect = self.itemsView.frame;
    if (rect.origin.x == 0) {
        [UIView animateWithDuration:0.2f
                              delay:0.1f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGRect rect = self.itemsView.frame;
                             rect.origin.x = -rect.size.width;
                             self.itemsView.frame = rect;
                         }
                         completion:^(BOOL finished){
                             self.itemsView.hidden = YES;
                             [delegate.leftTabBarViewCtrl showLeftTabBar:self.itemsView show:NO delegate:self rect:self.itemsView.frame selected:@""];
                         }];
    }else
        [self.view endEditing:YES];
}
//tri code
- (IBAction)editTripName:(id)sender {
    
    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
    NSString *userId_Current = [myUserDefault objectForKey:@"userId"];
    
    if ([userId_Current isEqualToString:userId_Owner])
    {
        NSLog(@"Edit Trip name");
        [viewEdited setHidden:NO];
        tfEdit.text = lblTitle.text;
    }
    
}
- (IBAction)saveTripNameEdited:(id)sender {
    
    [tfEdit resignFirstResponder];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [Common showNetworkFailureAlert];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
        
        NSString *kURLString = [NSString stringWithFormat:@"%@/edit_tripname.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        //userid (của owner), new_tripname (tên mới)
        NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
        NSString *userId_Current = [myUserDefault objectForKey:@"userId"];
        NSString *tripId_Current = [myUserDefault objectForKey:@"userTripId"];
        //luu local db
        [sqlManager updateNameTrip:[tripId_Current integerValue]  name:tfEdit.text owner:[userId_Owner integerValue]];
        
        [request setPostValue:userId_Current forKey:@"userid"];
        [request setPostValue:tfEdit.text forKey:@"new_tripname"];
        
        [request setDelegate:self];
        [request startSynchronous];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSError *error = [request error];
        if (!error) {
            NSLog(@"NO error");
            
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"%@",dict);
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            
            if ([[dict objectForKey:@"success"] intValue] == 0) {
                
                [delegate showAlert:[dict objectForKey:@"message"]];
                
            }else{
                [delegate showAlert:[dict objectForKey:@"message"]];
                
                [viewEdited setHidden:YES];
                lblTitle.text = [dict objectForKey:@"tripname"];
                [USER_DEFAULT setObject:lblTitle.text forKey:@"userTripName"];
            }
        }
    }
    
}
- (IBAction)cancelEditTripName:(id)sender {
    
    [tfEdit resignFirstResponder];
    [viewEdited setHidden:YES];
}

#pragma mark SYNC NOTES

+ (void) SyncNoteData{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if (appDelegate.isUpdateAvailableForNote == false) {
//        return;
//    }
//    appDelegate.isUpdateAvailableForNote = false;
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
//    int syncNote = [[userDef objectForKey:@"syncNote"] intValue];
//    if (syncNote == 1) {
//        return;
//    }
//    [userDef setObject:[NSNumber numberWithInt:1] forKey:@"syncNote"];
//    [userDef synchronize];
    // get current version
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    VersionObj *objVersion = [[VersionObj alloc] init];
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
    }
    
    //get array which have update (add,edit,delete)
    //get all note
    NSMutableArray * noteArray = [[NSMutableArray alloc] init];
    NSMutableArray * noteArrayChange = [[NSMutableArray alloc] init];
    NSMutableArray * noteArrayDeleted = [[NSMutableArray alloc] init];
    @synchronized(self)
    {
        noteArray = [sqliteManager getNotes];
    }
    
    //get array note having change
    for (int i = 0 ; i < noteArray.count; i++) {
        NoteObj *noteObj = [[NoteObj alloc] init];
        noteObj = [noteArray objectAtIndex:i];
        if (noteObj.flag >0) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInt:noteObj.noteId] forKey:@"clientid"];
            [dict setObject:noteObj.title forKey:@"title"];
//            [dict setObject:noteObj.dateTime forKey:@"time"];
            [dict setObject:noteObj.content forKey:@"content"];
            [dict setObject:[NSNumber numberWithInt:noteObj.ownerUserId] forKey:@"ownerid"];
            [dict setObject:[NSNumber numberWithInt:noteObj.tripId] forKey:@"tripid"];
            [dict setObject:[NSNumber numberWithInt:noteObj.serverId] forKey:@"serverid"];
            [dict setObject:[NSNumber numberWithInt:noteObj.flag] forKey:@"flag"];
            
            NSString *strDate = noteObj.dateTime;
            NSLog(@"datetime: %@",strDate);
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"M-d-yyyy HH:mm:ss"];
            NSDate *dateNS = [dateFormat dateFromString:strDate];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
            strDate = [dateFormat stringFromDate:dateNS];
            strDate = [strDate stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
            [dict setObject:strDate forKey:@"time"];
            [noteArrayChange addObject:dict];
        }
        if (noteObj.flag == 3) {
            [noteArrayDeleted addObject:noteObj];
        }
    }
    //sync note data
    //    if (noteArrayChange.count > 0) {
    //set json_obj to post on server
    int tripid = [[userDef objectForKey:@"userTripId"] intValue];
    int noteVersion = objVersion.noteVersion;
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc] init];
    [dictPost setObject:[NSNumber numberWithInt:tripid] forKey:@"tripid"];
    [dictPost setObject:[NSNumber numberWithInt:noteVersion] forKey:@"client_ver"];
    [dictPost setObject:noteArrayChange forKey:@"data"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *kURLString = [NSString stringWithFormat:@"%@/sync_note.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [request startSynchronous];
        
        NSError *error2 = [request error];
        if (!error2) {
            NSLog(@"NO error");
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
//            NSLog(@"note %@",dict);
            if ([[dict objectForKey:@"success"] intValue] == 0) {
                if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
                    //                    [delegate showAlert:[dict objectForKey:@"message"]];
                }
            }else{
                
                //update note version in table Versions
                dispatch_async(dispatch_get_main_queue(), ^{
                    int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                    objVersion.noteVersion = newVersion;
                    @synchronized(self)
                    {
                        [sqliteManager updateVersion:objVersion];
                    }
                });
                
                //update information for record in local which updated on server
                NSMutableArray *arrayCommittedData = [[NSMutableArray alloc] init];
                arrayCommittedData = [dict objectForKey:@"committed_id"];
                if (arrayCommittedData.count >0) {
                    for (int k = 0; k < arrayCommittedData.count ; k++) {
                        NSDictionary *dictCommitted = [arrayCommittedData objectAtIndex:k];
                        int clientId = [[dictCommitted objectForKey:@"clientid"] intValue];
                        int serverId = [[dictCommitted objectForKey:@"serverid"] intValue];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager updateNoteFromServer:clientId withServerId:serverId];
                            }
                        });
                        for (int e = 0; e < noteArrayDeleted.count ; e++) {
                            NoteObj *objNote = [[NoteObj alloc] init];
                            objNote = [noteArrayDeleted objectAtIndex:e];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                @synchronized(self)
                                {
                                    [sqliteManager deleteNote:objNote.noteId];
                                }
                            });
                        }
                    }
                }
                
                //get array updated from sever
                NSMutableArray *arrayCurrentNote = [[NSMutableArray alloc] init];
                @synchronized(self){
                    arrayCurrentNote = [sqliteManager getNotes];
                }
                NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
                arrayUpdateData = [dict objectForKey:@"updated_data"];
                for (int j = 0 ; j < arrayUpdateData.count; j++) {
                    NoteObj *objNote = [[NoteObj alloc] init];
                    NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
                    
                    objNote.title  = [dictResponse objectForKey:@"title"];
//                    objNote.dateTime = [dictResponse objectForKey:@"time"];
                    objNote.content  = [dictResponse objectForKey:@"content"];
                    objNote.ownerUserId = [[dictResponse objectForKey:@"ownerid"] intValue];
                    objNote.tripId      = [[dictResponse objectForKey:@"tripid"] intValue];
                    objNote.serverId    = [[dictResponse objectForKey:@"serverid"] intValue];
                    objNote.flag        = 0;
                    
                    NSString *strDate = [dictResponse objectForKey:@"time"];
                    strDate = [strDate stringByReplacingOccurrencesOfString:@"+" withString:@"GMT+"];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
                    NSDate *expiresDate = [dateFormat dateFromString:strDate];
                    [dateFormat setDateFormat:@"M-d-yyyy HH:mm:ss"];
                    strDate = [dateFormat stringFromDate:expiresDate];
                    objNote.dateTime = strDate;
                    
                    BOOL isExist = NO;
                    for (int k = 0 ; k < arrayCurrentNote.count; k++) {
                        PackingTitleObj *obj = [arrayCurrentNote objectAtIndex:k];
                        if ([[dictResponse objectForKey:@"serverid"] intValue] == obj.serverId) {
                            isExist = YES;
                            break;
                        }
                    }
                    
                    if ([[dictResponse objectForKey:@"flag"] intValue] == 1) {
                        if (isExist) {
                            continue;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager addNoteInfor:objNote];
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"syncNoteSuccess"
                                                                                object:nil];
                        });
                    }else if ([[dictResponse objectForKey:@"flag"] intValue] == 2) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager updateNote:objNote];
                            }
                        });
                        objNote.noteId = [[dictResponse objectForKey:@"clientid"] intValue];
                    }else if ([[dictResponse objectForKey:@"flag"] intValue] == 3) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager deleteNote:objNote.noteId];
                            }
                        });
                        objNote.noteId = [[dictResponse objectForKey:@"clientid"] intValue];
                    }
                }
                
//                appDelegate.isUpdateAvailableForNote = true;
                [userDef setObject:@"0" forKey:@"syncNote"];
                [userDef synchronize];
            }
        }
    }
    //    }
}
//update note version
+ (void)UpdateNoteVersion:(VersionObj*)objVersion{
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        int newVer = objVersion.noteVersion;
        int userId = objVersion.userId;
        
        [sqliteManager updateVersionFromServer:@"noteversion" withVersion:newVer andUserId:userId];
    }
}

#pragma mark SYNC EXPENSE

+ (void) SyncExpenseData{
    NSLog(@"sync expense =========================================================");
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    int synEx = [[userDef objectForKey:@"syncExpense"] intValue];
     NSLog(@"synEx %d",synEx);
    if (synEx == 1) {
        return;
    }
    [userDef setObject:@"1" forKey:@"syncExpense"];
    [userDef synchronize];
    int synEx1 = [[userDef objectForKey:@"syncExpense"] intValue];
    NSLog(@"synEx1 %d",synEx1);
    // get current version
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    VersionObj *objVersion = [[VersionObj alloc] init];
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
    }
    
    
    //get array which have update (add,edit,delete)
    //get all expense
    NSMutableArray * expenseArray = [[NSMutableArray alloc] init];
    NSMutableArray * expenseArrayChange = [[NSMutableArray alloc] init];
    NSMutableArray * expenseArrayDeleted = [[NSMutableArray alloc] init];
    @synchronized(self)
    {
        expenseArray = [sqliteManager getAllExpenses];
    }
    
    //get array expense having change
    for (int i = 0 ; i < expenseArray.count; i++) {
        ExpenseObj *expObj = [[ExpenseObj alloc] init];
        expObj = [expenseArray objectAtIndex:i];
        if (expObj.flag >0) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInt:expObj.expenseId] forKey:@"clientid"];
            [dict setObject:[NSNumber numberWithInt:expObj.cateId] forKey:@"cateid"];
            [dict setObject:expObj.dateTime forKey:@"time"];
            [dict setObject:expObj.item forKey:@"item"];
            [dict setObject:expObj.money forKey:@"money"];
            [dict setObject:[NSNumber numberWithInt:expObj.ownerUserId] forKey:@"ownerid"];
            [dict setObject:[NSNumber numberWithInt:expObj.tripId] forKey:@"tripid"];
            [dict setObject:[NSNumber numberWithInt:expObj.serverId] forKey:@"serverid"];
            [dict setObject:[NSNumber numberWithInt:expObj.flag] forKey:@"flag"];
            
            [expenseArrayChange addObject:dict];
        }
        if (expObj.flag == 3) {
            [expenseArrayDeleted addObject:expObj];
        }
    }
    //sync expense data
    //    if (noteArrayChange.count > 0) {
    //set json_obj to post on server
    int userid = [[userDef objectForKey:@"userId"] intValue];
    int noteVersion = objVersion.expenseVersion;
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc] init];
    [dictPost setObject:[NSNumber numberWithInt:userid] forKey:@"ownerid"];
    [dictPost setObject:[NSNumber numberWithInt:noteVersion] forKey:@"client_ver"];
    [dictPost setObject:expenseArrayChange forKey:@"data"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *kURLString = [NSString stringWithFormat:@"%@/sync_expense.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [request startSynchronous];
        
        NSError *error2 = [request error];
        if (!error2) {
            NSLog(@"NO error");
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"expense %@",dict);
            if ([[dict objectForKey:@"success"] intValue] == 0) {
                if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
                    //                    [delegate showAlert:[dict objectForKey:@"message"]];
                }
            }else{
                //update expense version in table Versions
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
                        int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                        objVersion.expenseVersion = newVersion;
                        [sqliteManager updateVersion:objVersion];
                    }
                });
                
                
                //update information for record in local which updated on server
                NSMutableArray *arrayCommittedData = [[NSMutableArray alloc] init];
                arrayCommittedData = [dict objectForKey:@"committed_id"];
                if (arrayCommittedData.count >0) {
                    [userDef setObject:@"0" forKey:@"syncExpense"];
                    [userDef synchronize];
                    for (int k = 0; k < arrayCommittedData.count ; k++) {
                        NSDictionary *dictCommitted = [arrayCommittedData objectAtIndex:k];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                NSLog(@"========================== chua set ve 0=================");
                                int clientId = [[dictCommitted objectForKey:@"clientid"] intValue];
                                int serverId = [[dictCommitted objectForKey:@"serverid"] intValue];
                                [sqliteManager updateExpenseFromServer:clientId withServerId:serverId];
                            }
                            [userDef setObject:@"0" forKey:@"syncExpense"];
                            [userDef synchronize];
                        });
                        for (int e = 0; e < expenseArrayDeleted.count ; e++) {
                            ExpenseObj *objExp = [[ExpenseObj alloc] init];
                            objExp = [expenseArrayDeleted objectAtIndex:e];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                @synchronized(self)
                                {
                                    [sqliteManager deleteExpense:objExp.expenseId];
                                }
                            });
                        }
                    }
                }
                
                //get array updated from sever
                NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
                arrayUpdateData = [dict objectForKey:@"updated_data"];
                for (int j = 0 ; j < arrayUpdateData.count; j++) {
                    ExpenseObj *objExp = [[ExpenseObj alloc] init];
                    NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
                    
                    objExp.cateId = [[dictResponse objectForKey:@"cateid"] intValue];
                    objExp.item  = [dictResponse objectForKey:@"item"];
                    objExp.dateTime = [dictResponse objectForKey:@"time"];
                    objExp.money  = [dictResponse objectForKey:@"money"];
                    objExp.ownerUserId = [[dictResponse objectForKey:@"ownerid"] intValue];
                    objExp.tripId      = [[dictResponse objectForKey:@"tripid"] intValue];
                    objExp.serverId    = [[dictResponse objectForKey:@"serverid"] intValue];
                    objExp.flag        = 0;
                    
                    if ([[dictResponse objectForKey:@"flag"] intValue] == 1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager addExpenseInfor:objExp];
                            }
                        });
                    }else if ([[dictResponse objectForKey:@"flag"] intValue] == 2) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            objExp.expenseId = [[dictResponse objectForKey:@"clientid"] intValue];
                            @synchronized(self)
                            {
                                [sqliteManager updateExpense:objExp];
                            }
                        });
                    }
                }
                NSLog(@"========================== set ve 0 roi  =================");
//                [userDef setObject:@"0" forKey:@"syncExpense"];
//                [userDef synchronize];
            }
        }
    }
    //    }
}

#pragma mark SYNC PACKING ITEM

+ (void) SyncPackingItemData{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if ([[userDef objectForKey:@"syncPackingItem"] isEqualToString:@"1"]) {
        return;
    }
    [userDef setObject:@"1" forKey:@"syncPackingItem"];
    [userDef synchronize];
    // get current version
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    VersionObj *objVersion = [[VersionObj alloc] init];
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
    }
    
    //get array which have update (add,edit,delete)
    //get all expense
    NSMutableArray * packingTitleArray = [[NSMutableArray alloc] init];
    NSMutableArray * packingTitleArrayChange = [[NSMutableArray alloc] init];
    NSMutableArray * packingTitleArrayDeleted = [[NSMutableArray alloc] init];
    @synchronized(self)
    {
        packingTitleArray = [sqliteManager getPackingItems:0];
    }
    
    //get array expense having change
    for (int i = 0 ; i < packingTitleArray.count; i++) {
        PackingItemObj *packObj = [[PackingItemObj alloc] init];
        packObj = [packingTitleArray objectAtIndex:i];
        if (packObj.flag >0) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInt:packObj.itemId] forKey:@"clientid"];
            [dict setObject:packObj.itemName forKey:@"item"];
            [dict setObject:[NSNumber numberWithInt:packObj.isCheck] forKey:@"ischecked"];
            [dict setObject:[NSNumber numberWithInt:packObj.packingId] forKey:@"listid"];
            [dict setObject:[NSNumber numberWithInt:packObj.serverId] forKey:@"serverid"];
            [dict setObject:[NSNumber numberWithInt:packObj.flag] forKey:@"flag"];
            [packingTitleArrayChange addObject:dict];
        }
        if (packObj.flag == 3) {
            [packingTitleArrayDeleted addObject:packObj];
        }
    }
    //sync expense data
    //    if (noteArrayChange.count > 0) {
    //set json_obj to post on server
    int userid = [[userDef objectForKey:@"userId"] intValue];
    int packingTitleVersion = objVersion.packingItemVersion;
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc] init];
    [dictPost setObject:[NSNumber numberWithInt:userid] forKey:@"ownerid"];
    [dictPost setObject:[NSNumber numberWithInt:packingTitleVersion] forKey:@"client_ver"];
    [dictPost setObject:packingTitleArrayChange forKey:@"data"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *kURLString = [NSString stringWithFormat:@"%@/sync_packingitem.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [request startSynchronous];
        
        NSError *error2 = [request error];
        if (!error2) {
            NSLog(@"NO error");
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
//            NSLog(@"packingItem :%@",dict);
            if ([[dict objectForKey:@"success"] intValue] == 0) {
                if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
                    //                    [delegate showAlert:[dict objectForKey:@"message"]];
                }
            }else{
                //update expense version in table Versions
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
                        int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                        objVersion.packingItemVersion = newVersion;
                        [sqliteManager updateVersion:objVersion];
                    }
                });
                
                
                //update information for record in local which updated on server
                NSMutableArray *arrayCommittedData = [[NSMutableArray alloc] init];
                arrayCommittedData = [dict objectForKey:@"committed_id"];
                if (arrayCommittedData.count >0) {
                    for (int k = 0; k < arrayCommittedData.count ; k++) {
                        NSDictionary *dictCommitted = [arrayCommittedData objectAtIndex:k];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                int clientId = [[dictCommitted objectForKey:@"clientid"] intValue];
                                int serverId = [[dictCommitted objectForKey:@"serverid"] intValue];
                                [sqliteManager updatePackingItemFromServer:clientId withServerId:serverId];
                            }
                        });
                        for (int e = 0; e < packingTitleArrayDeleted.count ; e++) {
                            PackingItemObj *objPackingItem = [packingTitleArrayDeleted objectAtIndex:e];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                @synchronized(self)
                                {
                                    [sqliteManager deletePackingItem:objPackingItem.itemId];
                                }
                            });
                        }
                    }
                }
                
                //get array updated from sever
                NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
                NSMutableArray *arrayPackingItem = [[NSMutableArray alloc] init];
                @synchronized(self){
                    arrayPackingItem = [sqliteManager getPackingItems:0];
                }
                arrayUpdateData = [dict objectForKey:@"updated_data"];
                for (int j = 0 ; j < arrayUpdateData.count; j++) {
                    PackingItemObj *objPackingItem = [[PackingItemObj alloc] init];
                    NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
                    BOOL isExist = NO;
                    for (int k = 0 ; k < arrayPackingItem.count; k++) {
                        PackingTitleObj *obj = [arrayPackingItem objectAtIndex:k];
                        if ([[dictResponse objectForKey:@"serverid"] intValue] == obj.serverId) {
                            isExist = YES;
                            break;
                        }
                    }
                    objPackingItem.itemName  = [dictResponse objectForKey:@"item"];
                    objPackingItem.isCheck   = [[dictResponse objectForKey:@"ischecked"] intValue];
                    objPackingItem.packingId = [[dictResponse objectForKey:@"listid"] intValue];
                    objPackingItem.serverId  = [[dictResponse objectForKey:@"serverid"] intValue];
                    objPackingItem.flag      = 0;
                    
                    if ([[dictResponse objectForKey:@"flag"] intValue] == 1) {
                        if (isExist) {
                            continue;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager addPackingItemInfor:objPackingItem];
                            }
                        });
                    }else if ([[dictResponse objectForKey:@"flag"] intValue] == 2) {
                        if (isExist) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                objPackingItem.packingId = [[dictResponse objectForKey:@"clientid"] intValue];
                                @synchronized(self)
                                {
                                    [sqliteManager updatePackingItem:objPackingItem];
                                }
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                @synchronized(self)
                                {
                                    [sqliteManager addPackingItemInfor:objPackingItem];
                                }
                            });
                        }
                        
                    }
                }
                [userDef setObject:@"0" forKey:@"syncPackingItem"];
                [userDef synchronize];
            }
        }
    }
    //    }
}

#pragma mark SYNC PACKING TITLE

+ (void) SyncPackingTitleData{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if ([[userDef objectForKey:@"syncPackingTitle"] isEqualToString:@"1"]) {
        return;
    }
    [userDef setObject:@"1" forKey:@"syncPackingTitle"];
    [userDef synchronize];
    // get current version
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    VersionObj *objVersion = [[VersionObj alloc] init];
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
    }
    
    //get array which have update (add,edit,delete)
    //get all expense
    NSMutableArray * packingTitleArray = [[NSMutableArray alloc] init];
    NSMutableArray * packingTitleArrayChange = [[NSMutableArray alloc] init];
    NSMutableArray * packingTitleDeleted= [[NSMutableArray alloc] init];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    @synchronized(self)
    {
        packingTitleArray = [sqliteManager getPackingTitle];
    }
    //    });
    
    
    //get array expense having change
    for (int i = 0 ; i < packingTitleArray.count; i++) {
        PackingTitleObj *packObj = [[PackingTitleObj alloc] init];
        packObj = [packingTitleArray objectAtIndex:i];
        if (packObj.flag >0) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInt:packObj.packingId] forKey:@"clientid"];
            [dict setObject:packObj.title forKey:@"title"];
            [dict setObject:[NSNumber numberWithInt:packObj.ownerUserId] forKey:@"ownerid"];
            [dict setObject:[NSNumber numberWithInt:packObj.serverId] forKey:@"serverid"];
            [dict setObject:[NSNumber numberWithInt:packObj.flag] forKey:@"flag"];
            [dict setObject:[NSNumber numberWithInt:[[userDef objectForKey:@"userTripId"] intValue]] forKey:@"tripid"];
            
            [packingTitleArrayChange addObject:dict];
        }
        if (packObj.flag == 3) {
            [packingTitleDeleted addObject:packObj];
        }
    }
    //sync expense data
    //    if (noteArrayChange.count > 0) {
    //set json_obj to post on server
    int userid = [[userDef objectForKey:@"userId"] intValue];
    int packingTitleVersion = objVersion.packingTitleVersion;
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc] init];
    [dictPost setObject:[NSNumber numberWithInt:userid] forKey:@"ownerid"];
    [dictPost setObject:[NSNumber numberWithInt:packingTitleVersion] forKey:@"client_ver"];
    [dictPost setObject:packingTitleArrayChange forKey:@"data"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *kURLString = [NSString stringWithFormat:@"%@/sync_packingtitle.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [request startSynchronous];
        
        NSError *error2 = [request error];
        if (!error2) {
            NSLog(@"NO error");
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"packingTitle :%@",dict);
            if ([[dict objectForKey:@"success"] intValue] == 0) {
                if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
                    //                    [delegate showAlert:[dict objectForKey:@"message"]];
                }
            }else{
                //update expense version in table Versions
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
                        int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                        objVersion.packingTitleVersion = newVersion;
                        [sqliteManager updateVersion:objVersion];
                    }
                });
                
                
                //update information for record in local which updated on server
                NSMutableArray *arrayCommittedData = [[NSMutableArray alloc] init];
                arrayCommittedData = [dict objectForKey:@"committed_id"];
                if (arrayCommittedData.count >0) {
                    for (int k = 0; k < arrayCommittedData.count ; k++) {
                        NSDictionary *dictCommitted = [arrayCommittedData objectAtIndex:k];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                int clientId = [[dictCommitted objectForKey:@"clientid"] intValue];
                                int serverId = [[dictCommitted objectForKey:@"serverid"] intValue];
                                [sqliteManager updatePackingTitleFromServer:clientId withServerId:serverId];
                                NSMutableArray *arrayPackingItem = [[NSMutableArray alloc] init];
                                arrayPackingItem = [sqliteManager getPackingItems:clientId];
                                for (int j = 0;  j < arrayPackingItem.count ; j++) {
                                    PackingItemObj *packObj = [[PackingItemObj alloc] init];
                                    packObj = [arrayPackingItem objectAtIndex:j];
                                    packObj.packingId = serverId;
                                    [sqliteManager updatePackingItem:packObj];
                                }
                                for (int e = 0; e < packingTitleDeleted.count ; e++) {
                                    PackingTitleObj *objPackingTitle = [packingTitleDeleted objectAtIndex:e];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        @synchronized(self)
                                        {
                                            [sqliteManager deletePackingTitle:objPackingTitle.packingId];
                                        }
                                    });
                                }
                            }
                        });
                    }
                }
                
                //get array updated from sever
                NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
                NSMutableArray *arrayPacking = [[NSMutableArray alloc] init];
                @synchronized(self){
                    arrayPacking = [sqliteManager getPackingTitle];
                }
                arrayUpdateData = [dict objectForKey:@"updated_data"];
                for (int j = 0 ; j < arrayUpdateData.count; j++) {
                    PackingTitleObj *objPackingTitle = [[PackingTitleObj alloc] init];
                    NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
                    BOOL isExist = NO;
                    for (int k = 0 ; k < arrayPacking.count; k++) {
                        PackingTitleObj *obj = [arrayPacking objectAtIndex:k];
                        if ([[dictResponse objectForKey:@"serverid"] intValue] == obj.serverId) {
                            isExist = YES;
                            break;
                        }
                    }
                    objPackingTitle.title  = [dictResponse objectForKey:@"title"];
                    objPackingTitle.ownerUserId = [[dictResponse objectForKey:@"ownerid"] intValue];
                    objPackingTitle.serverId    = [[dictResponse objectForKey:@"serverid"] intValue];
                    objPackingTitle.flag        = 0;
                    
                    if ([[dictResponse objectForKey:@"flag"] intValue] == 1) {
                        if (isExist) {
                            continue;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager addPackingTitleInfor:objPackingTitle];
                            }
                        });
                    }else if ([[dictResponse objectForKey:@"flag"] intValue] == 2) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            objPackingTitle.packingId = [[dictResponse objectForKey:@"clientid"] intValue];
                            @synchronized(self)
                            {
                                [sqliteManager updatePackingTitle:objPackingTitle];
                            }
                        });
                    }
                }
                [userDef setObject:@"0" forKey:@"syncPackingTitle"];
                [userDef setObject:@"0" forKey:@"syncPackingItem"];
                [userDef synchronize];
                
                // sync packing item
                [TripDetailVC SyncPackingItemData];
            }
        }
    }
    //    }
}
#pragma mark Sync Photo
+ (void) syncPhoto{
    
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    VersionObj *objVersion = [[VersionObj alloc] init];
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[NSNumber numberWithInt:objVersion.photoVersion] forKey:@"client_ver"];
    [_params setObject:[NSNumber numberWithInt:[[userDefault objectForKey:@"userId"] intValue]] forKey:@"ownerid"];
    [_params setObject:[NSNumber numberWithInt:0] forKey:@"flag"];
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'
    //    NSString *FileParamConstant = @"photourl";
    
    //Setup request URL
    NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/sync_photo.php",SERVER_LINK]];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    //    NSString *strImageName = [Common getFilePath:obj.urlPhoto];
    //    NSData *imageData = [NSData dataWithContentsOfFile:strImageName];
    //    if (imageData) {
    //        printf("appending image data\n");
    //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\'%@\'; filename=\"images.png\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:imageData];
    //        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    NSURLResponse *response = nil;
    NSError *error=nil;
    NSData *data=[[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error]];
    
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//    NSLog(@"sync photo : %@",dict);
    
    //    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    NSString *kURLString = [NSString stringWithFormat:@"%@/login.php",SERVER_LINK];
    //    NSURL *url = [NSURL URLWithString:kURLString];
    //    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //    [request setPostValue:[NSNumber numberWithInt:[[userDefault objectForKey:@"userId"] intValue]] forKey:@"ownerid"];
    //    [request setPostValue:[NSNumber numberWithInt:objVersion.photoVersion] forKey:@"client_ver"];
    //    [request setPostValue:[NSNumber numberWithInt:0] forKey:@"flag"];
    //    [request setDelegate:self];
    //    [request startSynchronous];
    //
    //    NSError *error = [request error];
    //    if (!error) {
    //        NSLog(@"NO error");
    //        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //        NSData *response = [request responseData];
    //        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
    //        NSLog(@"%@",dict);
    //    }
    
    if ([[dict objectForKey:@"success"] intValue] == 0) {
        if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
            //                    [delegate showAlert:[dict objectForKey:@"message"]];
        }
    }else{
        //update expense version in table Versions
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(self)
            {
                int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                objVersion.photoVersion = newVersion;
                [sqliteManager updateVersion:objVersion];
            }
        });
        
        //update information for record in local which updated on server
        NSDictionary *dictCommitted = [dict objectForKey:@"committed_id"];
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(self)
            {
                int clientId = [[dictCommitted objectForKey:@"clientid"] intValue];
                int serverId = [[dictCommitted objectForKey:@"serverid"] intValue];
                NSString *imageName = [[dictCommitted objectForKey:@"photourl"] stringByReplacingOccurrencesOfString:@"/" withString:@""];
                [sqliteManager updatePhotoFromServer:clientId withServerId:serverId];
//                [Common saveImageToLocal:[dictCommitted objectForKey:@"photourl"]];
                [sqliteManager updatePhotoUrlFromServer:clientId withPhotoUrl:imageName];
            }
        });
        
        //get array updated from sever
        NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
        NSMutableArray *arrayPhoto = [[NSMutableArray alloc] init];
        @synchronized(self){
            arrayPhoto = [sqliteManager getPhotoItems:0 andReceipt:0];
        }
        arrayUpdateData = [dict objectForKey:@"updated_data"];
        for (int j = 0 ; j < arrayUpdateData.count; j++) {
            PhotoObj *objPhoto = [[PhotoObj alloc] init];
            NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
            BOOL isExist = NO;
            for (int k = 0 ; k < arrayPhoto.count; k++) {
                PhotoObj *obj = [arrayPhoto objectAtIndex:k];
                if ([[dictResponse objectForKey:@"serverid"] intValue] == obj.serverId) {
                    isExist = YES;
                    break;
                }
            }
            
            objPhoto.caption  = [dictResponse objectForKey:@"caption"];
            NSString *imageName = [[dictResponse objectForKey:@"photourl"] stringByReplacingOccurrencesOfString:@"/" withString:@""];
            objPhoto.urlPhoto = imageName;
            objPhoto.isReceipt = [[dictResponse objectForKey:@"isreceipt"] intValue];
            objPhoto.tripId = [[dictResponse objectForKey:@"tripid"] intValue];
            objPhoto.ownerUserId = [[dictResponse objectForKey:@"ownerid"] intValue];
            objPhoto.serverId    = [[dictResponse objectForKey:@"serverid"] intValue];
            objPhoto.flag        = 0;
            
            if ([[dictResponse objectForKey:@"flag"] intValue] == 1) {
                if (isExist) {
                    continue;
                }
                [Common saveImageToLocal:[dictResponse objectForKey:@"photourl"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
                        [sqliteManager addPhotoInfor:objPhoto];
//                        [Common saveImageToLocal:[dictResponse objectForKey:@"photourl"]];
                    }
                });
                
            }
            else if ([[dictResponse objectForKey:@"flag"] intValue] == 3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
                        [sqliteManager deletePhoto:objPhoto.photoId];
//                        [Common removeImage:imageName];
                    }
                });
                [Common removeImage:imageName];
            }
        }
    }
    
}

#pragma mark SYNC USERS

+ (void) syncUsers{
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"syncUser"] isEqualToString:@"1"]) {
        return;
    }
    [userDefault setObject:@"1" forKey:@"syncUser"];
    [userDefault synchronize];
    VersionObj *objVersion = [[VersionObj alloc] init];
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[NSNumber numberWithInt:objVersion.userVersion] forKey:@"client_ver"];
    [_params setObject:[NSNumber numberWithInt:[[userDefault objectForKey:@"userTripId"] intValue]] forKey:@"tripid"];
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'
    //    NSString *FileParamConstant = @"photourl";
    
    //Setup request URL
    NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/get_trip_users.php",SERVER_LINK]];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    NSURLResponse *response = nil;
    NSError *error=nil;
    NSData *data=[[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error]];
    
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//    NSLog(@"sync user : %@",dict);
    
    if ([[dict objectForKey:@"success"] intValue] == 0) {
        if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
            //                    [delegate showAlert:[dict objectForKey:@"message"]];
        }
    }else{
        //update expense version in table Versions
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(self)
            {
                int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                objVersion.userVersion = newVersion;
                [sqliteManager updateVersion:objVersion];
            }
        });
        NSMutableArray *arrayUser = [[NSMutableArray alloc] init];
        @synchronized(self){
            arrayUser = [sqliteManager getUserInfor:[[userDefault objectForKey:@"userTripId"] intValue]];//[sqliteManager getPhotoItems: andReceipt:0];
        }
        //get array updated from sever
        NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
        arrayUpdateData = [dict objectForKey:@"updated_data"];
        for (int j = 0 ; j < arrayUpdateData.count; j++) {
            User *objUser = [[User alloc] init];
            NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
            
            BOOL isExist = NO;
            for (int k = 0 ; k < arrayUser.count; k++) {
                User *obj = [arrayUser objectAtIndex:k];
                if ([[dictResponse objectForKey:@"userid"] intValue] == obj.userInTripId) {
                    isExist = YES;
                    objUser.userId = obj.userId;
                    break;
                }
            }
            
            objUser.userInTripId  = [[dictResponse objectForKey:@"userid"] intValue];
            NSString *imageName = [[dictResponse objectForKey:@"avatarurl"] substringFromIndex:1];
            objUser.avatarUrl = imageName;
            objUser.name = [dictResponse objectForKey:@"username"];
            objUser.tripId = [[userDefault objectForKey:@"userTripId"] intValue];
            
            if (isExist) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
                        [sqliteManager createTable:@"Users"];
                        [sqliteManager updateUserInfor:objUser];
                    }
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
                        [sqliteManager createTable:@"Users"];
                        [sqliteManager saveUser:objUser];
                    }
                });
            }
            
        }
    }
    [userDefault setObject:@"0" forKey:@"syncUser"];
    [userDefault synchronize];
}

#pragma mark SYNC CATEGORIES

+ (void) SyncCategoryData{
    NSLog(@"Category =========================================================");
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    int syncCate = [[userDef objectForKey:@"syncCategory"] intValue];
    NSLog(@"synEx %d",syncCate);
    if (syncCate == 1) {
        return;
    }
    [userDef setObject:@"1" forKey:@"syncCategory"];
    [userDef synchronize];
    // get current version
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    VersionObj *objVersion = [[VersionObj alloc] init];
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
    }
    
    
    //get array which have update (add,edit,delete)
    //get all expense
    NSMutableArray * categoryArray        = [[NSMutableArray alloc] init];
    NSMutableArray * categoryArrayChange  = [[NSMutableArray alloc] init];
    NSMutableArray * categoryArrayDeleted = [[NSMutableArray alloc] init];
    @synchronized(self)
    {
        categoryArray = [sqliteManager getCategoryList];
    }
    
    //get array expense having change
    for (int i = 0 ; i < categoryArray.count; i++) {
        CategoryObj *expObj = [categoryArray objectAtIndex:i];
        if (expObj.flag >0) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInt:expObj.categoryId] forKey:@"clientid"];
            [dict setObject:expObj.title forKey:@"name"];
            [dict setObject:[NSNumber numberWithInt:expObj.ownerUserId] forKey:@"user_id"];
            [dict setObject:[NSNumber numberWithInt:expObj.serverId] forKey:@"serverid"];
            [dict setObject:[NSNumber numberWithInt:expObj.flag] forKey:@"flag"];
            
            [categoryArrayChange addObject:dict];
        }
        if (expObj.flag == 3) {
            [categoryArrayDeleted addObject:expObj];
        }
    }
    //sync expense data
    //    if (noteArrayChange.count > 0) {
    //set json_obj to post on server
    int userid = [[userDef objectForKey:@"userId"] intValue];
    int noteVersion = objVersion.categoryVersion;
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc] init];
    [dictPost setObject:[NSNumber numberWithInt:userid] forKey:@"ownerid"];
    [dictPost setObject:[NSNumber numberWithInt:noteVersion] forKey:@"client_ver"];
    [dictPost setObject:categoryArrayChange forKey:@"data"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *kURLString = [NSString stringWithFormat:@"%@/sync_expense_categories.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [request startSynchronous];
        
        NSError *error2 = [request error];
        if (!error2) {
            NSLog(@"NO error");
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"category %@",dict);
            if ([[dict objectForKey:@"success"] intValue] == 0) {
                if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
                    //                    [delegate showAlert:[dict objectForKey:@"message"]];
                }
            }else{
                //update expense version in table Versions
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
                        int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                        objVersion.categoryVersion = newVersion;
                        [sqliteManager updateVersion:objVersion];
                    }
                });
                
                
                //update information for record in local which updated on server
                NSMutableArray *arrayCommittedData = [[NSMutableArray alloc] init];
                arrayCommittedData = [dict objectForKey:@"committed_id"];
                if (arrayCommittedData.count >0) {
                    [userDef setObject:@"0" forKey:@"syncCategory"];
                    [userDef synchronize];
                    for (int k = 0; k < arrayCommittedData.count ; k++) {
                        NSDictionary *dictCommitted = [arrayCommittedData objectAtIndex:k];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                int clientId = [[dictCommitted objectForKey:@"clientid"] intValue];
                                int serverId = [[dictCommitted objectForKey:@"serverid"] intValue];
                                [sqliteManager updateCategoryFromServer:clientId withServerId:serverId];
                            }
                            [userDef setObject:@"0" forKey:@"syncCategory"];
                            [userDef synchronize];
                        });
                        for (int e = 0; e < categoryArrayDeleted.count ; e++) {
                            CategoryObj *objExp = [categoryArrayDeleted objectAtIndex:e];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                @synchronized(self)
                                {
                                    [sqliteManager deleteCategory:objExp.categoryId];
                                }
                            });
                        }
                    }
                }
                
                NSMutableArray *arrayCategory= [[NSMutableArray alloc] init];
                @synchronized(self){
                    arrayCategory = [sqliteManager getCategoryList];//[sqliteManager getPhotoItems: andReceipt:0];
                }
                //get array updated from sever
                NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
                arrayUpdateData = [dict objectForKey:@"updated_data"];
                for (int j = 0 ; j < arrayUpdateData.count; j++) {
                    CategoryObj *objExp = [[CategoryObj alloc] init];
                    NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
                    
                    BOOL isExist = NO;
                    for (int k = 0 ; k < arrayCategory.count; k++) {
                        CategoryObj *obj = [arrayCategory objectAtIndex:k];
                        if ([[dictResponse objectForKey:@"serverid"] intValue] == obj.serverId) {
                            isExist = YES;
                            break;
                        }
                    }
                    
                    objExp.title  = [dictResponse objectForKey:@"name"];
                    objExp.ownerUserId = [[USER_DEFAULT objectForKey:@"userId"] intValue];
                    objExp.serverId    = [[dictResponse objectForKey:@"serverid"] intValue];
                    objExp.flag        = 0;
                    
                    if ([[dictResponse objectForKey:@"flag"] intValue] == 1) {
                        if (isExist) {
                            continue;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager addCategoryInfor:objExp];
                            }
                        });
                    }else if ([[dictResponse objectForKey:@"flag"] intValue] == 2) {
                        if (isExist) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                objExp.categoryId = [[dictResponse objectForKey:@"clientid"] intValue];
                                @synchronized(self)
                                {
                                    [sqliteManager updateCategory:objExp];
                                }
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                @synchronized(self)
                                {
                                    [sqliteManager addCategoryInfor:objExp];
                                }
                            });
                        }
                    }
                }
                NSLog(@"========================== set syncCategory ve 0  =================");
                [userDef setObject:@"0" forKey:@"syncCategory"];
                [userDef synchronize];
            }
        }
    }
    //    }
}

#pragma mark - send slide show to email, facebook
- (IBAction)sendSlideShowToFacebook:(id)sender {
    SendSlideShowVC *sendSlide = [[SendSlideShowVC alloc]init];
    sendSlide.type = 2;
    [self.navigationController pushViewController:sendSlide animated:YES];
    
}
- (IBAction)sendSlideShowToEmail:(id)sender {
    SendSlideShowVC *sendSlide = [[SendSlideShowVC alloc]init];
    sendSlide.type=1;
    [self.navigationController pushViewController:sendSlide animated:YES];
}

@end
