//
//  ConfirmInvitationVC.m
//  Fun Spot App
//
//  Created by MAC on 8/27/14.
//
//

#import "ConfirmInvitationVC.h"
#import "IntroViewController.h"
#import "TripDetailVC.h"

@interface ConfirmInvitationVC ()

@end

@implementation ConfirmInvitationVC
@synthesize dictInforUser;

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
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = YES;
    bgImgLogOur.layer.cornerRadius = 5.0;
    [self reloadInforUserInfor];
}
- (void) reloadInforUserInfor{
    if ([[dictInforUser objectForKey:@"type"] intValue] == 1) {
        lblTitleInvitation.text = [NSString stringWithFormat:@"%@ has invited you to join their trip %@. Would you like to join %@?", [dictInforUser objectForKey:@"inviter_name"],[dictInforUser objectForKey:@"tripname"],[dictInforUser objectForKey:@"tripname"]];
//        [btnUserInvite setTitle:[NSString stringWithFormat:@"%@ has invited you to join %@. Would you like to join %@?", [dictInforUser objectForKey:@"inviter_name"],[dictInforUser objectForKey:@"tripname"],[dictInforUser objectForKey:@"tripname"]] forState:UIControlStateNormal];
        lblTripName.text = [NSString stringWithFormat:@"If you have a trip currently in progress, this will delete that information and you will be joined into %@",[dictInforUser objectForKey:@"tripname"]];
        
        NSString *str = [dictInforUser objectForKey:@"inviter_avatar"];
        if ([[str substringToIndex:1] isEqualToString:@"."]) {
            str = [str stringByReplacingOccurrencesOfString:@"./" withString:@"/"];
        }
        NSString *strImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_LINK,str];
        [btnAvatarUserInvite loadImageFromURL:[NSURL URLWithString:strImageUrl]];
    }else{
        btnAccept.hidden = YES;
        [btnDecline setTitle:@"Ok" forState:UIControlStateNormal];
        CGRect rect = btnDecline.frame;
        rect.origin.x = (320 - rect.size.width)/2;
        btnDecline.frame =rect;
        
        lblTitleInvitation.text = [NSString stringWithFormat:@"%@ sent you an alert:", [dictInforUser objectForKey:@"sender_name"]];
//        [btnUserInvite setTitle:[NSString stringWithFormat:@"%@ sent you an alert:", [dictInforUser objectForKey:@"sender_name"]] forState:UIControlStateNormal];
        
        lblTripName.text =  [dictInforUser objectForKey:@"content"];
        
        NSString *str = [dictInforUser objectForKey:@"sender_avatar"];
        if ([[str substringToIndex:1] isEqualToString:@"."]) {
            str = [str stringByReplacingOccurrencesOfString:@"./" withString:@"/"];
        }
        NSString *strImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_LINK,str];
        [btnAvatarUserInvite loadImageFromURL:[NSURL URLWithString:strImageUrl]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) afterLogout{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *kURLString = [NSString stringWithFormat:@"%@/remove_gcm.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[userDefault objectForKey:@"userDeviceToken"] forKey:@"gcmid"];
    
    //userid (của người mời), email(của người được mời)
    [request setDelegate:self];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
//        NSLog(@"NO error");
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        NSData *response = [request responseData];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
//        NSLog(@"%@",dict);
//        if (dict == nil) {
//            //            [delegate showAlert:@"Server is not connected"];
//            return;
//        }
//        if ([[dict objectForKey:@"success"] intValue] == 0) {
//            [delegate showAlert:[dict objectForKey:@"message"]];
//        }else{
//            [delegate showAlert:[dict objectForKey:@"message"]];
//        }
    }
}
- (IBAction)btnYesClick:(id)sender {
    [self sendReplyInvitation:1];
    // delete all expenses of user
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        [sqliteManager deleteExpense:[[USER_DEFAULT objectForKey:@"userTripId"] intValue]];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[dictInforUser objectForKey:@"tripid"] forKey:@"userTripId"];
    [userDefault setObject:[dictInforUser objectForKey:@"tripname"] forKey:@"userTripName"];
    [userDefault setObject:@"1" forKey:@"addingTrip"];
    [userDefault synchronize];
    [self getTripInformation];
    [self addUser];
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[IntroViewController class]]) {
            [self.parentViewController.navigationController popToViewController:viewController animated:YES];
            [self performSelector:@selector(pushView:) withObject:viewController afterDelay:0.6];
            break;
        }
    }
    //remove child view
    UIViewController *vc = [self.parentViewController.childViewControllers lastObject];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}
- (void) pushView:(UIViewController*)viewController{
    IntroViewController *vc = (IntroViewController*)viewController;
    [vc goMainScreen];
}
- (IBAction)btnNoClick:(id)sender {
    if ([[dictInforUser objectForKey:@"type"] intValue] == 1)
        [self sendReplyInvitation:0];
    UIViewController *vc = [self.parentViewController.childViewControllers lastObject];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}
- (void) endTrip{
    // delete all expenses of user 
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        [sqliteManager deleteExpense:[[USER_DEFAULT objectForKey:@"userTripId"] intValue]];
    }
    
    /*
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *kURLString = [NSString stringWithFormat:@"%@/end_trip.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[userDefault objectForKey:@"userId"] forKey:@"userid"];
    [request setPostValue:[userDefault objectForKey:@"userTripId"] forKey:@"tripid"];
    
    [request setDelegate:self];
    [request startSynchronous];
     */
}
//get Trip Information
-(void)getTripInformation{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *kURLString = [NSString stringWithFormat:@"%@/get_trip.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[userDefault objectForKey:@"userTripId"] forKey:@"tripid"];
    [request setPostValue:[userDefault objectForKey:@"userId"] forKey:@"userid"];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSLog(@"NO error");
        NSData *response = [request responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSLog(@"%@",dict);
        if ([dict objectForKey:@"success"] == 0) {
//            [delegate showAlert:@"This trip is not exist"];
        }else{
            
            //            //tripname, start_date, finish_date,trip_budget, ownerid
            TripObj *tripInfor     = [[TripObj alloc] init];
            tripInfor.tripId       = [[userDefault objectForKey:@"userTripId"] intValue];
            tripInfor.tripLocation = [dict objectForKey:@"tripname"];
            tripInfor.startDate    = [dict objectForKey:@"start_date"];
            tripInfor.finishDate   = [dict objectForKey:@"finish_date"];
            tripInfor.budget       = [dict objectForKey:@"budget"];
            if ([tripInfor.budget intValue] < 0) {
                tripInfor.budget = @"0";
            }
            tripInfor.ownerUserId  = [[dict objectForKey:@"ownerid"] intValue];
//            tripInfor.ownerUserId  = [[userDefault objectForKey:@"userId"] intValue];
            IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
            @synchronized(self)
            {
                [sqliteManager createTable:@"Trips"];
                [sqliteManager addTripInfor:tripInfor];
            }
        }
    }
}

-(void) addUser{
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc]  init];
    NSMutableArray *arrayUser = [[NSMutableArray alloc] init];
    @synchronized(self){
        arrayUser = [sqliteManager getUserInfor:[[USER_DEFAULT objectForKey:@"userTripId"] intValue]];//[sqliteManager getPhotoItems: andReceipt:0];
    }
    
    User *objUser = [[User alloc] init];
    
    objUser.userInTripId  = [[dictInforUser objectForKey:@"inviter_id"] intValue];
    NSString *imageName = [[dictInforUser objectForKey:@"inviter_avatar"] substringFromIndex:1];
    objUser.avatarUrl = imageName;
    objUser.name = [dictInforUser objectForKey:@"inviter_name"];
    objUser.tripId = [[dictInforUser objectForKey:@"tripid"] intValue];
    
    BOOL isExist = NO;
    for (int k = 0 ; k < arrayUser.count; k++) {
        User *obj = [arrayUser objectAtIndex:k];
        if ([[dictInforUser objectForKey:@"inviter_id"] intValue] == obj.userInTripId) {
            isExist = YES;
            objUser.userId = obj.userId;
            break;
        }
    }
    
    if (!isExist) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(self)
            {
                [sqliteManager createTable:@"Users"];
                [sqliteManager saveUser:objUser];
            }
        });
    }
}
- (void) sendReplyInvitation:(int)reply{
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    ///userid (của người mời), email(của người được mời), tripid
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[NSNumber numberWithInt:reply] forKey:@"reply"];
    [_params setObject:[dictInforUser objectForKey:@"tripid"] forKey:@"invited_tripid"];
    [_params setObject:[dictInforUser objectForKey:@"invited_user_id"] forKey:@"invited_user_id"];
    [_params setObject:[dictInforUser objectForKey:@"inviter_id"] forKey:@"inviter_id"];
    //- reply (=0 là cancel, =1 là ok), invited_tripid( tripid được mời vào),invited_user_id (id của người đc mời) và inviter_id (id của người mời)
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'
    //    NSString *FileParamConstant = @"";
    
    //Setup request URL
    NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/reply_invitation.php",SERVER_LINK]];
    
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
    NSLog(@"reply invitation : %@",dict);
    if (dict != nil) {
//        [delegate showAlert:@"Your invitation has been sent."];
    }else{
//        [delegate showAlert:@"Fail to send your invitation."];
    }
    
}
@end
