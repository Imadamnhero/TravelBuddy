//
//  AddTripVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/14/14.
//
//

#import "AddTripVC.h"
#import "InviteGroupVC.h"
#import "TripDetailVC.h"
#import "TripObj.h"

@interface AddTripVC ()

@end

@implementation AddTripVC
@synthesize isFromLogin;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    float main_top = 0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        main_top = 0;
    }
    tfTripName.delegate = self;
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    
    selectedBegin = [NSDate date];
    selectedEnd = [NSDate date];
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setYear:1];
    NSCalendar* calendar1 = [NSCalendar currentCalendar];
    selectedEnd = [calendar1 dateByAddingComponents:dateComponents toDate:selectedEnd options:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [mainScroll setContentSize:CGSizeMake(320, 568)];
    btnAddTrip.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 4);
    btnCancelTrip.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    bgImageBudget.layer.cornerRadius = bgImageDates.layer.cornerRadius = bgImageGroup.layer.cornerRadius = bgImageName.layer.cornerRadius = bgImageTripName.layer.cornerRadius = 5.0;
    if (![isFromLogin isEqualToString:@"true"]) {
        [delegate showAlert:@"You have not added trip yet"];
    }
    
    [tfFromDate setFont:[UIFont fontWithName:@"MyriadPro-It" size:15]];
    [tfToDate setFont:[UIFont fontWithName:@"MyriadPro-It" size:15]];
    
    [tfBudget setFont:[UIFont fontWithName:@"MyriadPro-It" size:15]];
    [tfTripName setFont:[UIFont fontWithName:@"MyriadPro-It" size:15]];
}
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)btnInviteUserClick:(id)sender {
    InviteGroupVC *inviteGroupController = [[InviteGroupVC alloc] initWithNibName:@"InviteGroupVC" bundle:nil];
    [self.navigationController pushViewController:inviteGroupController animated:YES];
}

- (IBAction)btnNextClick:(id)sender {
    if ([tfTripName.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input trip name"];
        return;
    }
    NSString* strTripname = [tfTripName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (strTripname.length == 0) {
        [delegate showAlert:@"Please input valid trip name"];
        return;
    }
    if ([tfFromDate.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input From-date"];
        return;
    }
    if ([tfToDate.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input To-date"];
        return;
    }
    if ([tfBudget.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input budget"];
        return;
    }
//    NSDateFormatter *df= [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"yyyy-MM-dd"];
//    
//    NSDate *dt1 = [[NSDate alloc] init];
//    
//    NSDate *dt2 = [[NSDate alloc] init];
//    
//    dt1=[df dateFromString:@"2011-02-25"];
//    
//    dt2=[df dateFromString:@"2011-03-25"];
    NSDate *newDate1 = [selectedEnd dateByAddingTimeInterval:60*60*24];
    if ([selectedBegin compare:newDate1] == NSOrderedDescending) {
        NSLog(@"date1 is later than date2");
        [delegate showAlert:@"The end date must be later than the start date"];
        return;
    }
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
        [self performSelector:@selector(afterClickNext) withObject:nil afterDelay:1.0];
    }
    
}
-(void)afterClickNext{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *kURLString = [NSString stringWithFormat:@"%@/add_trip.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    NSString *strBudget = [tfBudget.text substringFromIndex:2];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[userDefault objectForKey:@"userId"] forKey:@"userid"];
    [request setPostValue:tfTripName.text forKey:@"tripname"];
    [request setPostValue:tfFromDate.text forKey:@"start_date"];
    [request setPostValue:tfToDate.text forKey:@"finish_date"];
    [request setPostValue:[NSNumber numberWithDouble:[strBudget doubleValue]] forKey:@"trip_budget"];
    //userid,tripname,start_date, finish_date,trip_budget
    [request setDelegate:self];
    [request setTimeOutSeconds:20];
    [request startSynchronous];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSError *error = [request error];
    if (!error) {
        NSLog(@"NO error");
        
        NSData *response = [request responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSLog(@"%@",dict);
        if ([[dict objectForKey:@"success"] intValue] == 0) {
            [delegate showAlert:@"This trip is invalid"];
        }else{
            
            TripObj *tripInfor = [[TripObj alloc] init];
            tripInfor.tripId = [[dict objectForKey:@"tripid"] intValue];
            tripInfor.tripLocation = tfTripName.text;
            tripInfor.startDate    = tfFromDate.text;
            tripInfor.finishDate   = tfToDate.text;
            tripInfor.budget       = [tfBudget.text substringFromIndex:2];
            tripInfor.ownerUserId  = [[userDefault objectForKey:@"userId"] intValue];

            IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
            @synchronized(self)
            {
                [sqliteManager createTable:@"Trips"];
                [sqliteManager addTripInfor:tripInfor];
                
                [sqliteManager createTable:@"Versions"];
                VersionObj *objVersion = [[VersionObj alloc] init];
                objVersion.noteVersion = 0;
                objVersion.categoryVersion = 0;
                objVersion.expenseVersion = 0;
                objVersion.groupVersion = 0;
                objVersion.photoVersion = 0;
                objVersion.packingTitleVersion = 0;
                objVersion.packingItemVersion = 0;
                objVersion.premadeListVersion = 0;
                objVersion.premadeItemVersion = 0;
                objVersion.userId = [[userDefault objectForKey:@"userId"] intValue];
                
                [sqliteManager addVersionInfor:objVersion];
            }
            
            [delegate showAlert:[dict objectForKey:@"message"]];
            
            [userDefault setObject:[dict objectForKey:@"tripid"] forKey:@"userTripId"];
            [userDefault setObject:tfTripName.text forKey:@"userTripName"];
            [userDefault setObject:@"1" forKey:@"addingTrip"];
            [userDefault synchronize];
            
            TripDetailVC *tripDetailController = [[TripDetailVC alloc] initWithNibName:@"TripDetailVC" bundle:nil];
            tripDetailController.isFromAddTrip = YES;
            [self.navigationController pushViewController:tripDetailController animated:NO];
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
- (IBAction)btnCancelTripClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Choose Date picker

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    if (typeDate == 1) {
        selectedBegin = selectedDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        tfFromDate.text = [delegate formatDateFromDateString:[dateFormatter stringFromDate:selectedBegin]];
    }else
    {
        selectedEnd = selectedDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        tfToDate.text = [delegate formatDateFromDateString:[dateFormatter stringFromDate:selectedEnd]];
    }
}
- (void)dateSelected{
    
    if (typeDate == 1) {
        selectedBegin = datePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        tfFromDate.text = [delegate formatDateFromDateString:[dateFormatter stringFromDate:selectedBegin]];
    }else
    {
        selectedEnd = datePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        tfToDate.text = [delegate formatDateFromDateString:[dateFormatter stringFromDate:selectedEnd]];
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == tfFromDate) {
        [self.view endEditing:NO];
        typeDate = 1;
        [calendar removeFromSuperview];
        calendar = [[VRGCalendarView alloc] init];
        calendar.delegate=self;
        CGRect frame = calendar.frame;
        frame.origin.y = 0;
        [calendar setFrame:frame];
        
        [viewCalendar addSubview:calendar];
        viewCalendar.hidden = NO;
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"calshow://"]];
//        return NO;
//        if (checkiOS8) {
//            NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
//            
//            //for iOS 8
//            [calendar removeFromSuperview];
//            calendar = [[VRGCalendarView alloc] init];
//            calendar.delegate=self;
//            CGRect frame = calendar.frame;
//            frame.origin.y = -50;
//            frame.origin.x = -8;
//            [calendar setFrame:frame];
//            
//            UIAlertController* datePickerContainer = [UIAlertController alertControllerWithTitle: title
//                                                                                         message:nil
//                                                                                  preferredStyle: UIAlertControllerStyleActionSheet];
//            
//            [datePickerContainer.view addSubview:calendar];
//            [self presentViewController:datePickerContainer animated:YES completion:nil];
//            return NO;
//            [datePickerContainer.view addSubview:datePicker];
//            
//            datePicker.date = selectedBegin;
//            //Add autolayout constraints to position the datepicker
//            [datePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
//            
//            // Create a dictionary to represent the view being positioned
//            NSDictionary *labelViewDictionary = NSDictionaryOfVariableBindings(datePicker);
//            
//            NSArray* hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[datePicker]-|" options:0 metrics:nil views:labelViewDictionary];
//            [datePickerContainer.view addConstraints:hConstraints];
//            NSArray* vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[datePicker]" options:0 metrics:nil views:labelViewDictionary];
//            [datePickerContainer.view addConstraints:vConstraints];
//            
//            [datePickerContainer addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
//                [self dateSelected];
//            }]];
//            
//            [self presentViewController:datePickerContainer animated:YES completion:nil];
//        }
        return NO;
    }else if (textField == tfToDate) {
        [self.view endEditing:YES];
        typeDate = 2;
//        if (checkiOS8) {
            [calendar removeFromSuperview];
            calendar = [[VRGCalendarView alloc] init];
            calendar.delegate=self;
            CGRect frame = calendar.frame;
            frame.origin.y = 0;
            [calendar setFrame:frame];
           
            [viewCalendar addSubview:calendar];
            viewCalendar.hidden = NO;
            
//        }else{
//            _actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:selectedEnd target:self action:@selector(dateWasSelected:element:) origin:tfToDate];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//            dateFormatter.dateFormat = @"EEE MMM dd, yyyy";
//            _actionSheetPicker.title = [dateFormatter stringFromDate: [NSDate date]];
//            _actionSheetPicker.hideCancel = NO;
//            [_actionSheetPicker showActionSheetPicker];
//        }
        return NO;
    }
    return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == tfFromDate) {
//
    }else if (textField == tfToDate) {
       
    }else if (textField == tfBudget) {
        if (tfBudget.text.length == 0) {
            tfBudget.text = [NSString stringWithFormat:@"$ %@",tfBudget.text];
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == tfBudget) {
        if (tfBudget.text.length == 0) {
            tfBudget.text = [NSString stringWithFormat:@"$ "];
        }
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == tfBudget) {
        if ([tfBudget.text isEqualToString:@"$ "] || [tfBudget.text isEqualToString:@""]) {
            tfBudget.text = @"";
        }else{
            if (tfBudget.text.length < 2) {
                tfBudget.text=@"";
            }else if (![self validateDecimal:[tfBudget.text substringFromIndex:2]]) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Budget is invalid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                tfBudget.text=@"";
            }
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)hideLeftTabbar:(CGRect)rect{
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
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    ////NSLog(@"scrollViewDidScroll");
    // Update the page when more than 50% of the previous/next page is visible
    CGRect rect = self.itemsView.frame;
    if (rect.origin.x == 0) {
        [self hideLeftTabbar:rect];
    }
    [self.view endEditing:YES];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGRect rect = self.itemsView.frame;
    if (rect.origin.x == 0) {
        [self hideLeftTabbar:rect];
    }else
        [self.view endEditing:YES];
}
#pragma mark - VRGCalendarViewDelegate
-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
    NSLog(@"switch Month");
}
-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date andArr:(NSMutableArray*)_arr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat =@"M-d-yyyy";
    
    //get date selected and exchange to string
    NSString *strTime = [dateFormatter stringFromDate: date];
    if (typeDate == 1) {
        selectedBegin = date;
        tfFromDate.text = strTime;//[delegate formatDateFromDateString:[dateFormatter stringFromDate:selectedBegin]];
    }else
    {
        selectedEnd = date;
        tfToDate.text = strTime;//[delegate formatDateFromDateString:[dateFormatter stringFromDate:selectedEnd]];
    }
    viewCalendar.hidden = YES;
}
@end
