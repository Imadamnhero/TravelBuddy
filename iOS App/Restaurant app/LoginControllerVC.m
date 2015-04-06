//
//  LoginControllerVC.m
//  Restaurant app
//
//

#import "LoginControllerVC.h"
#import "Common.h"
#import "AppDelegate.h"
#import "LeftTabBarViewController.h"
#import "ApplicationData.h"
#import "IMSSqliteManager.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "AddTripVC.h"
#import "TripDetailVC.h"
#import "VersionObj.h"

#define kConfigPlistName @"config"

@implementation LoginControllerVC

@synthesize homeScreenImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = @"StoreItem";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view endEditing:YES];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBarHidden = YES;
    isMemory = false;
    isAddAvatar = false;
//    Reachability *reach = [Reachability reachabilityForInternetConnection];
//    NetworkStatus netStatus = [reach currentReachabilityStatus];

    
//    if (netStatus == NotReachable) {
//        [Common showNetworkFailureAlert];
//    } else {
//        [self loadMainData];
//    }
    float main_top = 0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        main_top = 0;
    }
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    
    tfEmail.layer.cornerRadius    = 3.0;
    tfPassword.layer.cornerRadius = 3.0;
    
    bgImgAboutView.layer.cornerRadius    = 5.0;
    bgImgLoginView.layer.cornerRadius    = 5.0;
    bgImgSignUpView.layer.cornerRadius   = 5.0;
//    arrayCountry = [[NSMutableArray alloc] init];
//    [self validateNotCommand];
//    [self goMainScreen];
    NSString *tem = btnSignUpClick.titleLabel.text;
    if (tem != nil && ![tem isEqualToString:@""]) {
        NSMutableAttributedString *temString=[[NSMutableAttributedString alloc]initWithString:tem];
        [temString addAttribute:NSUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:1]
                          range:(NSRange){0,[temString length]}];
        
        btnSignUpClick.titleLabel.attributedText = temString;
    }
    
    NSString *tem2 = btnSignInClick.titleLabel.text;
    
    if (tem2 != nil && ![tem2 isEqualToString:@""]) {
        NSMutableAttributedString *temString2=[[NSMutableAttributedString alloc]initWithString:tem2];
        [temString2 addAttribute:NSUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:1]
                          range:(NSRange){0,[temString2 length]}];
        
        btnSignInClick.titleLabel.attributedText = temString2;
    }
    btnDeleteAvatar.imageEdgeInsets   = UIEdgeInsetsMake(2, 2, 2, 2);
    btnCloseViewAbout.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    btnClose.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    btnHome.imageEdgeInsets  = UIEdgeInsetsMake(5, 5, 5, 5);
    isLoginViewShowing = TRUE;
    txtAboutContent.text = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\n\nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nNam liber te conscient to factor tum poen legum odioque civiuda.";
}
- (void)awakeFromNib{
    [self.view endEditing:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.view endEditing:YES];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *str = [NSString stringWithFormat:@"%@",[userDefault objectForKey:@"addingTrip"]];
    if ([str isEqualToString:@"1"]) {
        TripDetailVC *viewController = [[TripDetailVC alloc]initWithNibName:@"TripDetailVC" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        NSString *str = [userDefault objectForKey:@"isLogin"];
        if ([str isEqualToString:@"true"]) {
            btnSelectCountry.hidden = btnAddTripIcon.hidden = NO;
            btnHome.hidden = NO;
        }else{
            if (isLoginViewShowing) {
                viewLogin.hidden = NO;
                viewSignUp.hidden = YES;
                if ([[userDefault objectForKey:@"memoryUser"] isEqualToString:@"true"]) {
                    tfEmail.text = [userDefault objectForKey:@"userEmail"];
//                    tfPassword.text = [userDefault objectForKey:@"userPassword"];
                    [btnMemory setSelected:YES];
                    isMemory = true;
                }
            }else{
                viewLogin.hidden = YES;
                viewSignUp.hidden = NO;
            }
            btnHome.hidden = YES;
        }
//        if ([[userDefault objectForKey:@"memoryUser"] isEqualToString:@"true"]) {
//            tfEmail.text = [userDefault objectForKey:@"userEmail"];
//            tfPassword.text = [userDefault objectForKey:@"userPassword"];
//            [btnMemory setSelected:YES];
//            isMemory = true;
//            btnMemory.selected = YES;
////            btnSelectCountry.hidden = btnAddTripIcon.hidden = NO;
//            btnHome.hidden = NO;
//            viewLogin.hidden = NO;
//        }else{
//            if (isLoginViewShowing) {
//                viewLogin.hidden = NO;
//                viewSignUp.hidden = YES;
//            }else{
//                viewLogin.hidden = YES;
//                viewSignUp.hidden = NO;
//            }
//            btnHome.hidden = YES;
//        }
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
//LOAD MAIN DATA
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
- (IBAction)btnRememberSignUpClick:(id)sender{
    if (isMemorySignUp) {
        isMemorySignUp = false;
        [btnRememberSignUp setSelected:NO];
    }else{
        isMemorySignUp = YES;
        [btnRememberSignUp setSelected:YES];
    }
}

- (IBAction)btnMemoryClick:(id)sender {
    if (isMemory) {
        isMemory = false;
        [btnMemory setSelected:NO];
    }else{
        isMemory = YES;
        [btnMemory setSelected:YES];
    }
}

- (void)loadMainData {

    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];

//    ANIPlaceService *service = [ANIPlaceService service];
//    [service ProApplicationGetTraductionFile:self action:@selector(onMainDataload:) thelanguage:LANGCODE];
}

- (void)onMainDataload:(id)value
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (value == nil || value == [NSError class] || ![value isKindOfClass:[NSDictionary class]]) {
        [self loadMainData];
        NSLog(@"recall loadMainData in onMainDataload");
        return;
    }
    
    if (((NSDictionary*)value)[@"ProApplicationGetTraductionFileResult"] == nil ||
        [(NSDictionary*)value valueForKey:@"ProApplicationGetTraductionFileResult"] == NULL) {
        [self loadMainData];
        return;
    }
    
    NSDictionary *dictResponse = [(NSDictionary*)value valueForKey:@"ProApplicationGetTraductionFileResult"];
    NSLog(@"Main dictResponse %@",dictResponse);

    if (dictResponse[@"diffgram"] == nil || [dictResponse valueForKey:@"diffgram"] == NULL) {
        [self loadMainData];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"diffgram"];
    
    if (dictResponse[@"DocumentElement"] == nil || [dictResponse valueForKey:@"DocumentElement"] == NULL) {
        [self loadMainData];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"DocumentElement"];
    
    if (dictResponse[@"result"] == nil || [dictResponse valueForKey:@"result"] == NULL) {
        [self loadMainData];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"result"];
    
    delegate.langId = [dictResponse valueForKey:@"LangueId"];
//    NSMutableArray *tmpArray = (NSMutableArray*)dictResponse;
    
//    NSArray *keys = @[@"DeviseSigle",@"HorizontalMainPhoto",@"LangueId",@"Logo",@"MainPhoto",@"Placedelegate.CurrentCode",@"PlaceAppId",@"PlaceCouponVersion",@"PlaceEventVersion",@"PlaceGalleryVersion",@"PlaceIsShowNews",@"PlaceMainVersion",@"PlaceNewsVersion",@"PlaceStoreVersion",@"PlaceVideoVersion",@"PlacePlaceVersion",@"PlaceCouponVersion",@"PlaceType",@"PlaceIsShowCoupon",@"PlaceIsShowEvent",@"SplashScreen",@"Store",@"StoreLevel",@"VerticalMainPhoto",@"annuaire_mail",@"article_adresse",@"article_intro",@"article_latitude",@"article_longitude",@"article_tel",@"article_texte",@"article_titre",@"articleid",@"color_bg",@"color_nav",@"color_text",@"id",@"rowOrder",@"ville_cp",@"ville_nom",@"TabLogoChoose",@"TabLogoContact",@"TabLogoCoupon",@"TabLogoEvent",@"TabLogoGallery",@"TabLogoLocation",@"TabLogoNews",@"TabLogoPlace",@"TabLogoSite",@"TabLogoSite2",@"TabLogoSite3",@"TabLogoStore",@"TabLogoStore2",@"TabLogoStore3",@"TabLogoVideo",@"TabChoose",@"TabContact",@"TabCoupon",@"TabEvent",@"TabGallery",@"TabLocation",@"TabNews",@"TabPlace",@"TabSite",@"TabSite2",@"TabSite3",@"TabStore",@"TabStore2",@"TabStore3",@"TabVideo",@"VerticalMainPhoto",@"PlaceIsShowMag",@"PlaceIsShowMag2",@"PlaceIsShowMag3",@"PlaceIsMap",@"PlaceIsGallery",@"PlaceIsContact",@"PlaceIsShowPlace",@"PlaceIsShowSite",@"PlaceIsShowSite2",@"PlaceIsShowSite3",@"PlaceIsShowVideo",@"PlaceIsMother",@"color_text_home",@"color_bg_home",@"color_active",@"PlaceAppDM",@"PlaceAppFB",@"PlaceAppTW",@"PlaceAppYT",@"PlaceAppGP",@"PlaceAppLK",@"PlaceAppSite",@"PlaceAppSite2",@"PlaceAppSite3",@"PlaceIsChildMap",@"PlaceIsTitle",@"PlaceTabLogo",@"color_nav_text",@"PlaceIsLangue",@"PlaceIsAlert",@"StoreId1",@"StoreId2",@"StoreId3",@"PlaceHomeTypeId",@"StoreLevel",@"StoreLevel2",@"StoreLevel3",@"PlaceAppIsChooseTheme", @"map", @"topmap", @"PlaceBackLogo", @"TabHomeTitle", @"TabHomeLogo",@"PlaceAppMessage"];
    
    
//    NSArray *keys = @[@"create_account",@"select_country",@"email",@"password",@"log_in",@"alert_country",@"memorize",@"loyalty_program",@"memberships",@"event"];

    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    [sqliteManager createTable:@"Fun"];
    
    for (NSDictionary *dict1 in dictResponse) {
        @synchronized(self)
        {
            [sqliteManager addToFunKey:[dict1 valueForKey:@"name"] Value:([dict1 valueForKey:@"value"] != [NSNull null] ? [dict1 valueForKey:@"value"]  : @"")];
        }
    }
    
    @synchronized(self)
    {
        delegate.funSpotDict = [sqliteManager readFun];
    }
    [btnCreatNewAccount setTitle:[delegate.funSpotDict objectForKey:@"create_account"] forState:UIControlStateNormal];
    [btnCreatNewAccount setBackgroundColor:[UIColor lightGrayColor]];
    [btnCreatNewAccount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btnLogin setTitle:[delegate.funSpotDict objectForKey:@"log_in"] forState:UIControlStateNormal];
    [btnLogin setBackgroundColor:[UIColor lightGrayColor]];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btnSelectCountry setTitle:[delegate.funSpotDict objectForKey:@"select_country"] forState:UIControlStateNormal];
    [btnSelectCountry setBackgroundColor:[UIColor lightGrayColor]];
    [btnSelectCountry setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
//    lblMemorize.text = [delegate.funSpotDict objectForKey:@"memorize"];
//    tfEmail.placeholder = [delegate.funSpotDict objectForKey:@"email"];
//    tfPassword.placeholder = [delegate.funSpotDict objectForKey:@"password"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"memoryUser"] isEqualToString:@"true"]) {
        tfEmail.text = [userDefault objectForKey:@"userEmail"];
        tfPassword.text = [userDefault objectForKey:@"userPassword"];
        delegate.currentCountry = [userDefault objectForKey:@"userShotCountry"];
        strShotCountry = [userDefault objectForKey:@"userShotCountry"];
        [btnMemory setSelected:YES];
        isMemory = true;
    }
//    [btnCancel setTitle:[delegate.funSpotDict objectForKey:@"cancel"] forState:UIControlStateNormal];
//    if ([btnCancel.titleLabel.text isEqualToString:@""] || btnCancel.titleLabel.text == nil) {
//        [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
//    }
//    [btnDone setTitle:[NSString stringWithFormat:@"%@",[delegate.funSpotDict objectForKey:@"ok"]] forState:UIControlStateNormal];
//    if ([btnDone.titleLabel.text isEqualToString:@""] || btnDone.titleLabel.text == nil) {
//        [btnDone setTitle:@"Ok" forState:UIControlStateNormal];
//    }
   // [self loadTraductionFile];
}

//=========Get data for traduction file======//

- (void)loadTraductionFile {
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
    
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service PlaceApplicationGetTraductionFile:self action:@selector(onTraductionLoad:) thelanguage:[delegate langId] country:COUNTRYNAME];
}

- (void)onTraductionLoad:(id)value
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (value == nil || value == [NSError class] || ![value isKindOfClass:[NSDictionary class]]) {
        [self loadTraductionFile];
        NSLog(@"reset loadTraductionFile");
        return;
    }
    
    if (((NSDictionary*)value)[@"PlaceApplicationGetTraductionFileResult"] == nil ||
        [(NSDictionary*)value valueForKey:@"PlaceApplicationGetTraductionFileResult"] == NULL) {
        [self loadTraductionFile];
        return;
    }
    NSDictionary *dictResponse = [(NSDictionary*)value valueForKey:@"PlaceApplicationGetTraductionFileResult"];
    NSLog(@"Traduction dictResponse %@",dictResponse);
    
    if (dictResponse[@"diffgram"] == nil || [dictResponse valueForKey:@"diffgram"] == NULL) {
        [self loadTraductionFile];
        return;
    }
    dictResponse= [dictResponse valueForKey:@"diffgram"];
    
    if (dictResponse[@"DocumentElement"] == nil || [dictResponse valueForKey:@"DocumentElement"] == NULL) {
        [self loadTraductionFile];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"DocumentElement"];
    
    if (dictResponse[@"result"] == nil || [dictResponse valueForKey:@"result"] == NULL) {
        [self loadTraductionFile];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"result"];
    
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    for (NSDictionary *dict1 in dictResponse) {
        @synchronized(self)
        {
            [sqliteManager addToFunKey:[dict1 valueForKey:@"name"] Value:([dict1 valueForKey:@"value"] != [NSNull null] ? [dict1 valueForKey:@"value"]  : @"")];
        }
    }

    [self loadPicturesData];
}

//=========Get Picture file======//

- (void)loadPicturesData {
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
    
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service PlaceApplicationGetPictures:self action:@selector(onPicturesLoad:) theFunspotId:[[delegate.funSpotDict valueForKey:@"articleid"] intValue] country:COUNTRYNAME];
}

- (void)onPicturesLoad:(id)value
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (value == nil || value == [NSError class] || ![value isKindOfClass:[NSDictionary class]]) {
        [self loadPicturesData];
        NSLog(@"reset loadPictureData");
        return;
    }
    
    if (((NSDictionary*)value)[@"PlaceApplicationGetPicturesResult"] == nil ||
        [(NSDictionary*)value valueForKey:@"PlaceApplicationGetPicturesResult"] == NULL) {
        [self loadPicturesData];
        return;
    }
    NSDictionary *dictResponse = [(NSDictionary*)value valueForKey:@"PlaceApplicationGetPicturesResult"];
    NSLog(@"Pictures dictResponse %@",dictResponse);
    
    if (dictResponse[@"diffgram"] == nil || [dictResponse valueForKey:@"diffgram"] == NULL) {
        [self loadPicturesData];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"diffgram"];
    
    if (dictResponse[@"DocumentElement"] == nil || [dictResponse valueForKey:@"DocumentElement"] == NULL) {
        [self loadPicturesData];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"DocumentElement"];
    
    if (dictResponse[@"result"] == nil || [dictResponse valueForKey:@"result"] == NULL) {
        [self loadPicturesData];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"result"];
    
    if (dictResponse && [dictResponse isKindOfClass:[NSArray class]]) {
        IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
        
        for (NSDictionary *dict1 in dictResponse) {
            @synchronized(self)
            {
                [sqliteManager addToFunKey:[NSString stringWithFormat:@"image_%@",[dict1 valueForKey:@"rowOrder"]] Value:([dict1 valueForKey:@"artimg_nom"] != [NSNull null] ? [dict1 valueForKey:@"artimg_nom"] : @"")];
            }
        }
    } else if (dictResponse && [dictResponse isKindOfClass:[NSDictionary class]]) {
        
        IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
        @synchronized(self)
        {
            [sqliteManager addToFunKey:[NSString stringWithFormat:@"image_%@",[dictResponse valueForKey:@"rowOrder"]] Value:([dictResponse valueForKey:@"artimg_nom"] != [NSNull null] ? [dictResponse valueForKey:@"artimg_nom"] : @"")];
        }
    }

    [self goMainScreen];
    //[self GetPlaceApplicationRegisterDevice];
}

- (void)onerror:(NSError*)error
{
    //////////NSLog(@"ERROR");
}


- (void)checkForUpdates {

    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
    
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service PlaceApplicationIsUpdate:self action:@selector(onIsUpdateLoad:) thecode:delegate.CurrentCode country:COUNTRYNAME];
}

- (void)onIsUpdateLoad:(id)value {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if (value == nil || value == [NSError class] || ![value isKindOfClass:[NSDictionary class]]) {
        [self checkForUpdates];
        NSLog(@"reset checkForUpdates");
        return;
    }

    if (((NSDictionary*)value)[@"PlaceApplicationIsUpdateResult"] == nil ||
        [(NSDictionary*)value valueForKey:@"PlaceApplicationIsUpdateResult"] == NULL) {
        [self checkForUpdates];
        return;
    }
    NSDictionary *dictResponse = [(NSDictionary*)value valueForKey:@"PlaceApplicationIsUpdateResult"];
    
    if (dictResponse[@"diffgram"] == nil || [dictResponse valueForKey:@"diffgram"] == NULL) {
        [self checkForUpdates];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"diffgram"];
    
    if (dictResponse[@"DocumentElement"] == nil || [dictResponse valueForKey:@"DocumentElement"] == NULL) {
        [self checkForUpdates];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"DocumentElement"];
    
    if (dictResponse[@"result"] == nil || [dictResponse valueForKey:@"result"] == NULL) {
        [self checkForUpdates];
        return;
    }
    dictResponse = [dictResponse valueForKey:@"result"];
    
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    delegate.funSpotDict = [sqliteManager readFun];
    
    NSDictionary *responseDict = [sqliteManager readTimeofLastUpdate:@"PlaceMainVersion"];
    if ([responseDict count] == 0) {
        
        [sqliteManager createTable:@"Updates"];
        [sqliteManager addUpdates:@"PlaceMainVersion" Value:[dictResponse valueForKey:@"PlaceMainVersion"] status:TRUE];
    }
    
    if (![[responseDict valueForKey:@"PlaceMainVersion"] isEqualToString:[dictResponse valueForKey:@"PlaceMainVersion"]]) {
        
        NSString *alertMssg = @"Pour mettre à jour l'application cliquez ici";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:alertMssg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
        [alert show];
        return;
        
    } else {
        [self goMainScreen];
        return;
    }

    [self goMainScreen];
}
- (bool)isDataExist {
    
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    
    int tblCount = [sqliteManager funSpotTableCount];
    if (tblCount > 0)
        return TRUE;
    else
        return FALSE;
}

- (IBAction)btnClickToSignUp:(id)sender {
    viewLogin.hidden  = YES;
    viewSignUp.hidden = NO;
    isLoginViewShowing = FALSE;
}

- (IBAction)btnClickToSignIn:(id)sender {
    viewLogin.hidden  = NO;
    viewSignUp.hidden = YES;
    isLoginViewShowing = TRUE;
    [self btnDeleteAvatar:nil];
}

- (void)goMainScreen {
    delegate.leftTabBarViewCtrl = NULL;
    if (delegate.leftTabBarViewCtrl == NULL) {
        delegate.leftTabBarViewCtrl = [[LeftTabBarViewController alloc] initWithNibName:@"LeftTabBarViewController" bundle:nil];
        delegate.leftTabBarViewCtrl.lefTabBarDelegate = self;
        [delegate.leftTabBarViewCtrl createButtons];
    }
}

- (void)resetApplication {
    
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBarHidden = YES;
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if([self isDataExist]){
        if (netStatus != NotReachable)
            [self checkForUpdates];
        
    } else {
        if (netStatus == NotReachable) {
            [Common showNetworkFailureAlert];
        } else {
            [self loadMainData];
        }
    }
}

- (IBAction)btnLoginClick:(id)sender {
    [self.view endEditing:YES];
    if ([tfEmail.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input email"];
        return;
    }
    if(![self validateEmail:tfEmail.text]) {
        [delegate showAlert:@"Email is invalid!"];
        return;
    }
    if ([tfPassword.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input password"];
        return;
    }
    
//    if([tfPassword.text length]<6 || [tfPassword.text length]>15) {
//        [delegate showAlert:@"Password must have from 6 to 15 characters"];
//        return;
//    }
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
        [self performSelector:@selector(afterLogin) withObject:nil afterDelay:1.0];
    }
}
- (void) afterLogin{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //get user device token
    NSString *strDeviceToken = [NSString stringWithFormat:@"%@",[userDefault objectForKey:@"userDeviceToken"]];
//    if ([strDeviceToken isEqualToString:@"(null)"]) {
//        strDeviceToken = @"ac2879ec8ee563f77de11cdd92f57263ad3887dcf13a2b10e6bbe8218288c4d5";
//    }
    NSString *kURLString = [NSString stringWithFormat:@"%@/login.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:tfEmail.text forKey:@"email"];
    [request setPostValue:tfPassword.text forKey:@"password"];
    [request setPostValue:strDeviceToken forKey:@"gcm_reg"];
    [request setPostValue:[NSNumber numberWithInt:2] forKey:@"os"];
    //username, email, avatarurl, password
    [request setDelegate:self];
    [request setTimeOutSeconds:20];
    [request startSynchronous];

    NSError *error = [request error];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (!error) {
        NSLog(@"NO error");
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSData *response = [request responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSLog(@"%@",dict);
        if (dict == nil) {
            [delegate showAlert:@"Server is not connected"];
            return;
        }
        if ([[dict objectForKey:@"success"] intValue] == 0) {
            [delegate showAlert:[dict objectForKey:@"message"]];
        }else{
            [delegate showAlert:@"Login successful"];
            btnSelectCountry.hidden = btnAddTripIcon.hidden = NO;
            NSString *str = @"true";
            [userDefault setObject:tfEmail.text forKey:@"userEmail"];
            [userDefault setObject:tfPassword.text forKey:@"userPassword"];
            [userDefault setObject:[dict objectForKey:@"username"] forKey:@"userName"];
            [userDefault setObject:[dict objectForKey:@"userid"] forKey:@"userId"];
            [userDefault setObject:[[dict objectForKey:@"avatarurl"] substringFromIndex:1] forKey:@"userAvatarUrl"];
            [userDefault setObject:str forKey:@"isLogin"];
            [userDefault setObject:@"0" forKey:@"syncExpense"];
            [userDefault setObject:@"0" forKey:@"syncNote"];
            [userDefault setObject:@"0" forKey:@"syncPackingTitle"];
            [userDefault setObject:@"0" forKey:@"syncPackingItem"];
            [userDefault synchronize];
            viewLogin.hidden = YES;
            if (isMemory) {
                [userDefault setObject:@"true" forKey:@"memoryUser"];
            }else
                [userDefault setObject:@"false" forKey:@"memoryUser"];
            [userDefault synchronize];
            NSString *strtripId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"tripid"]];
            IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
            if ([strtripId intValue] > 0) {
                [userDefault setObject:[dict objectForKey:@"tripid"] forKey:@"userTripId"];
                [userDefault setObject:[dict objectForKey:@"tripname"] forKey:@"userTripName"];
                [userDefault setObject:@"1" forKey:@"addingTrip"];
                
                [userDefault synchronize];
                
                @synchronized(self)
                {
                    [sqliteManager createTable:@"Trips"];
                    [self getTripInformation];
                }
                TripDetailVC *viewController = [[TripDetailVC alloc]initWithNibName:@"TripDetailVC" bundle:nil];
                [self.navigationController pushViewController:viewController animated:YES];
            }else
                btnHome.hidden = NO;
            
            @synchronized(self)
            {
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
                // create all table
                [sqliteManager createTable:@"Notes"];
                [sqliteManager createTable:@"Groups"];
                [sqliteManager createTable:@"Photos"];
                [sqliteManager createTable:@"Expenses"];
                [sqliteManager createTable:@"Categories"];
                [sqliteManager createTable:@"PackingTitles"];
                [sqliteManager createTable:@"PackingItems"];
                [sqliteManager createTable:@"PremadeLists"];
                [sqliteManager createTable:@"PremadeItems"];
                [sqliteManager createTable:@"Users"];
                [sqliteManager createTable:@"Colors"];
            }
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getPremadeList];
                [self getPremadeItem];
//            });
            
        }
    }
    else
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
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
            [delegate showAlert:@"This trip is not exist"];
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

            IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
            @synchronized(self)
            {
                [sqliteManager createTable:@"Trips"];
                [sqliteManager addTripInfor:tripInfor];
            }
        }
    }
}
//get PremadeList
-(void)getPremadeList{
    NSString *kURLString = [NSString stringWithFormat:@"%@/get_premadelist.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSLog(@"NO error");
        /*
         {"success":1,"message":"Successfully","data":[{"id":"1","title":"Beach"},{"id":"2","title":"Camping"},{"id":"3","title":"Snow\/Cold"},{"id":"4","title":"Family Trip"},{"id":"5","title":"Business Trip"}]}
         */
        NSData *response = [request responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
//        NSLog(@"%@",dict);
        if ([dict objectForKey:@"success"] == 0) {
//            [delegate showAlert:@"This trip is not exist"];
        }else{
            NSMutableArray *arrayData = [[NSMutableArray alloc] init];
            arrayData = [dict objectForKey:@"data"];
            for (int i = 0;  i < arrayData.count ; i++) {
                NSDictionary *dictData = [arrayData objectAtIndex:i];
                PremadeListObj *premadeListInfor     = [[PremadeListObj alloc] init];
                premadeListInfor.title    = [dictData objectForKey:@"title"];
                premadeListInfor.serverId = [[dict objectForKey:@"id"] intValue];
                premadeListInfor.flag     = 0;
                
                IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
//                        [sqliteManager createTable:@"PremadeLists"];
                        [sqliteManager addPremadeListInfor:premadeListInfor];
                    }
                });
                
            }
        }
    }
}
//get PremadeItem
-(void)getPremadeItem{
    NSString *kURLString = [NSString stringWithFormat:@"%@/get_premadeitem.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSLog(@"NO error");
        /*
         "{
         ""success"": 1,
         ""message"": ""Successfully"",
         ""data"": [
         {
         ""id"": ""1"",
         ""item"": ""Shorts"",
         ""listid"": ""1""
         },{
         ""id"": ""2"",
         ""item"": ""Jeans"",
         ""listid"": ""1""
         }]}"
         */
        NSData *response = [request responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
//        NSLog(@"%@",dict);
        if ([dict objectForKey:@"success"] == 0) {
//            [delegate showAlert:@"This trip is not exist"];
        }else{
            NSMutableArray *arrayData = [[NSMutableArray alloc] init];
            arrayData = [dict objectForKey:@"data"];
            for (int i = 0;  i < arrayData.count ; i++) {
                NSDictionary *dictData = [arrayData objectAtIndex:i];
                PremadeItemObj *premadeItemInfor     = [[PremadeItemObj alloc] init];
                premadeItemInfor.itemName    = [dictData objectForKey:@"item"];
                premadeItemInfor.listId    = [[dictData objectForKey:@"listid"] intValue];
                premadeItemInfor.serverId = [[dict objectForKey:@"id"] intValue];
                premadeItemInfor.flag     = 0;
                
                IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self)
                    {
//                        [sqliteManager createTable:@"PremadeItems"];
                        [sqliteManager addPremadeItemInfor:premadeItemInfor];
                    }
                });
                
            }
        }
    }
}

- (IBAction)btnCancelClick:(id)sender {
    pickerView.hidden = YES;
}

- (IBAction)btnDoneClick:(id)sender {
    pickerView.hidden = YES;
    [btnSelectCountry setTitle:strCountry forState:UIControlStateNormal];
    delegate.currentCountry = strShotCountry;
}

- (IBAction)btnCloseViewAboutClick:(id)sender {
    viewAbout.hidden = YES;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    if ([[userDefault objectForKey:@"memoryUser"] isEqualToString:@"true"]) {
//        btnSelectCountry.hidden = btnAddTripIcon.hidden = NO;
//    }else{
//        btnSelectCountry.hidden = btnAddTripIcon.hidden = YES;
//        if (isLoginViewShowing) {
//            viewLogin.hidden = NO;
//            viewSignUp.hidden = YES;
//        }else{
//            viewSignUp.hidden = NO;
//            viewLogin.hidden = YES;
//        }
//    }
    if ([[userDefault objectForKey:@"isLogin"] isEqualToString:@"true"]) {
        btnSelectCountry.hidden = btnAddTripIcon.hidden = NO;
        btnHome.hidden = NO;
    }else{
        if (isLoginViewShowing) {
            viewLogin.hidden = NO;
            viewSignUp.hidden = YES;
            if ([[userDefault objectForKey:@"memoryUser"] isEqualToString:@"true"]) {
                tfEmail.text = [userDefault objectForKey:@"userEmail"];
                tfPassword.text = [userDefault objectForKey:@"userPassword"];
                [btnMemory setSelected:YES];
                isMemory = true;
            }
        }else{
            viewLogin.hidden = YES;
            viewSignUp.hidden = NO;
        }
        btnHome.hidden = YES;
    }
}

- (IBAction)btnOpenViewAboutClick:(id)sender {
    btnSelectCountry.hidden = btnAddTripIcon.hidden = YES;
    viewSignUp.hidden = viewLogin.hidden = YES;
    viewAbout.hidden = NO;
}

- (IBAction)btnSignupClick:(id)sender {
//    RegisterNewUserVC *viewController = [[RegisterNewUserVC alloc]initWithNibName:@"RegisterNewUserVC" bundle:nil];
//    [self.navigationController pushViewController:viewController animated:NO];
}

- (IBAction)btnSelectCountryClick:(id)sender {
    AddTripVC *viewController = [[AddTripVC alloc]initWithNibName:@"AddTripVC" bundle:nil];
    viewController.isFromLogin = @"true";
    [self.navigationController pushViewController:viewController animated:YES];
}
- (BOOL)validateChar:(NSString *)character {
    NSString *charRegex = @"[A-Za-z]";
    NSPredicate *charTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", charRegex];
    return [charTest evaluateWithObject:character];
}
- (IBAction)btnCreateClick:(id)sender {
    [self.view endEditing:YES];
    if ([tfUserName.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input name"];
        return;
    }
//    NSString *strUserName = [tfUserName.text stringByTrimmingCharactersInSet:
//                             [NSCharacterSet whitespaceCharacterSet]];//[tfUserName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    if ([strUserName isEqualToString:@""]) {
//        [delegate showAlert:@"Please input valid name"];
//        tfUserName.text = @"";
//        return;
//    }
//    if([tfUserName.text length]<6 || [tfUserName.text length]>15) {
//        [delegate showAlert:@"Name must have from 6 to 15 characters"];
//        return;
//    }
    if ([tfEmailSignUp.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input email"];
        return;
    }
    if(![self validateEmail:tfEmailSignUp.text]) {
        [delegate showAlert:@"Email is invalid!"];
        return;
    }
    if ([tfPassSignUp.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input password"];
        return;
    }
    
//    if([tfPassSignUp.text length]<6 || [tfPassSignUp.text length]>15) {
//        [delegate showAlert:@"Password must have from 6 to 15 characters"];
//        return;
//    }
    
    if (!isAddAvatar) {
        [delegate showAlert:@"You have to add avatar"];
        return;
    }
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
//        [Common showNetworkFailureAlert];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
        [self performSelector:@selector(afterSignUp) withObject:nil afterDelay:1.0];
    }
    
}
- (void)afterSignUp{
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:tfUserName.text forKey:@"username"];
    [_params setObject:tfEmailSignUp.text forKey:@"email"];
    [_params setObject:tfPassSignUp.text forKey:@"password"];
    
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'
    NSString *FileParamConstant = @"avatarurl";
    
    //Setup request URL
    NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/add_user.php",SERVER_LINK]];
    
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
    NSData *imageData = UIImageJPEGRepresentation([self loadImage], 1.0);
    if (imageData) {
        printf("appending image data\n");
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\'%@\'; filename=\"avatar.png\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
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
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([[dict objectForKey:@"success"] intValue] == 1) {
        [delegate showAlert:[NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]]];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:tfUserName.text forKey:@"userName"];
        tfEmail.text = tfEmailSignUp.text;
        tfEmailSignUp.text = @"";
        tfPassword.text = tfPassSignUp.text;
        tfPassSignUp.text = @"";
        tfUserName.text = @"";
        viewLogin.hidden = NO;
        viewSignUp.hidden = YES;
        if (isMemorySignUp) {
            [userDefault setObject:tfEmailSignUp.text forKey:@"userEmail"];
            [userDefault setObject:@"true" forKey:@"memoryUser"];
            [userDefault synchronize];
            btnMemory.selected = YES;
            isMemory = true;
        }else{
            btnMemory.selected = NO;
            isMemory = false;
            [userDefault setObject:@"false" forKey:@"memoryUser"];
        }
        [userDefault synchronize];
    }else
        [delegate showAlert:[NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%@",httpResponse);
}

#pragma mark - LeftTabBarIconDownloadDelegate

- (void)leftTabBarIconDownloadDidFinished {
    
//    ANIHomeViewController *viewController = [[ANIHomeViewController alloc]initWithNibName:@"ANIHomeViewController" bundle:nil];
//    [self.navigationController pushViewController:viewController animated:NO];
//    return;
//    
//    if ([(delegate.funSpotDict)[@"PlaceHomeTypeId"] isEqualToString:@"SP"]) {
//        ANIHomeViewController *viewController = [[ANIHomeViewController alloc]initWithNibName:@"ANIHomeViewController" bundle:nil];
//        [self.navigationController pushViewController:viewController animated:NO];
//        
//    } else if ([(delegate.funSpotDict)[@"PlaceHomeTypeId"] isEqualToString:@"IM"]) {
//        ANIHomeViewController *viewController = [[ANIHomeViewController alloc]initWithNibName:@"ANIHomeViewController" bundle:nil];
//        [self.navigationController pushViewController:viewController animated:NO];
//        
//    }  else if ([(delegate.funSpotDict)[@"PlaceHomeTypeId"] isEqualToString:@"NW"]) {
//        NewsHomeViewController *viewController = [[NewsHomeViewController alloc]initWithNibName:@"NewsHomeViewController" bundle:nil];
//        [self.navigationController pushViewController:viewController animated:NO];
//        
//    }  else if ([(delegate.funSpotDict)[@"PlaceHomeTypeId"] isEqualToString:@"EV"]) {
//        EventHomeViewController *viewController = [[EventHomeViewController alloc]initWithNibName:@"EventHomeViewController" bundle:nil];
//        [self.navigationController pushViewController:viewController animated:NO];
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                        message:@"There is no content."
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil, nil];
//        [alert show];
//    }
}
#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [arrayCountry count];
}

#pragma mark UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //NSLog(@"pickerView didSelectRow:%i inComponent:%i", row, component);
    strCountry = [[arrayCountry objectAtIndex:row] objectForKey:@"pays_nom"];
    strShotCountry = [[arrayCountry objectAtIndex:row] objectForKey:@"paysid"];
    //    picker.hidden = YES;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[arrayCountry objectAtIndex:row] objectForKey:@"pays_nom"];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component     {
    return 21.0;
}

- (void) validateNotCommand{
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service ProApplicationGetCountry:self action:@selector(onloadValidateNotCommand:) thelanguage:delegate.langCode];
}
- (void) onloadValidateNotCommand: (id)value {
    
    if (value && value!=[NSError class] && [value isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dictResponse=[(NSDictionary*)value valueForKey:@"ProApplicationGetCountryResult"];
        
        dictResponse = [dictResponse valueForKey:@"diffgram"];
        if (dictResponse) {
            
            dictResponse = [dictResponse valueForKey:@"DocumentElement"];
            if(dictResponse) {
                
                dictResponse = [dictResponse valueForKey:@"result"];
                // if(dictResponse)
                NSLog(@"Response %@", dictResponse);
                if ([dictResponse valueForKey:@"result"] != [NSNull null]) {
                    arrayCountry =(NSMutableArray*) dictResponse;
                    strCountry = [[arrayCountry objectAtIndex:0] objectForKey:@"pays_nom"];
                    //picker View Country
                    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,30,320, 170)];
                    picker.delegate = self;
                    picker.dataSource = self;
                    picker.showsSelectionIndicator = YES;
                    [pickerView addSubview:picker];
                    [picker setBackgroundColor:[UIColor whiteColor]];
                }
            }
        }
    }
}
//method login
- (void) loginCommand{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service ProApplicationConnect:self action:@selector(onloadLoginCommand:) theemail:tfEmail.text thepassword:tfPassword.text country:delegate.currentCountry];
}
- (void) onloadLoginCommand: (id)value {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (value && value!=[NSError class] && [value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictResponse=[(NSDictionary*)value valueForKey:@"ProApplicationConnectResult"];
        if ([dictResponse valueForKey:@"diffgram"] != [NSNull null])
        {
            dictResponse = [dictResponse valueForKey:@"diffgram"];
            if (dictResponse) {
                
                dictResponse = [dictResponse valueForKey:@"DocumentElement"];
                if(dictResponse) {
                    dictResponse = [dictResponse valueForKey:@"result"];
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    [userDefault setObject:tfEmail.text forKey:@"userEmail"];
                    [userDefault setObject:tfPassword.text forKey:@"userPassword"];
                    [userDefault setObject:btnSelectCountry.titleLabel.text forKey:@"userCountry"];
                    [userDefault setObject:strShotCountry forKey:@"userShotCountry"];
                    [userDefault setObject:[dictResponse objectForKey:@"PlaceAppId"] forKey:@"PlaceAppId"];
                    [userDefault setObject:[dictResponse objectForKey:@"PlaceProgEvent"] forKey:@"PlaceProgEvent"];
                    [userDefault setObject:[dictResponse objectForKey:@"PlaceProgFidelity"] forKey:@"PlaceProgFidelity"];
                    [userDefault setObject:[dictResponse objectForKey:@"PlaceProgMember"] forKey:@"PlaceProgMember"];
                    [userDefault setObject:[dictResponse objectForKey:@"AppCode"] forKey:@"AppCode"];
                    [userDefault setObject:[dictResponse objectForKey:@"PlaceProgImageH"] forKey:@"PlaceProgImageH"];
                    [userDefault setObject:[dictResponse objectForKey:@"PlaceProgImageV"] forKey:@"PlaceProgImageV"];
                    if (isMemory) {
                        [userDefault setObject:@"true" forKey:@"memoryUser"];
                    }
                }else
                    [delegate showAlert:[delegate.funSpotDict objectForKey:@"alert_account"]];
            }else
                [delegate showAlert:[delegate.funSpotDict objectForKey:@"alert_account"]];
        }else
            [delegate showAlert:[delegate.funSpotDict objectForKey:@"alert_account"]];
    }
}
#pragma text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 150, self.view.frame.size.width, self.view.frame.size.height);
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 150, self.view.frame.size.width, self.view.frame.size.height);
}
#pragma mark UIImagePickerController
// get picture from library or take new picture
- (IBAction)btnTakeImageClick:(id)sender{
    [self.view endEditing:YES];
    viewPhoto.hidden = NO;
}

- (IBAction)btnCancelImageClick:(id)sender {
    viewPhoto.hidden = YES;
}

- (IBAction)btnSendEmailForgotClick:(id)sender {
    if ([tfEmailForgotPassword.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input email"];
        return;
    }
    if(![self validateEmail:tfEmailForgotPassword.text]) {
        [delegate showAlert:@"Email is invalid!"];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
    [self afterClickSendToEmail];
}

- (IBAction)btnCancelForgotPassClick:(id)sender {
    [self.view endEditing:YES];
    viewForgotPassword.hidden = YES;
    tfEmailForgotPassword.text = @"";
}
// send to email
-(void)afterClickSendToEmail{
    NSString *kURLString = [NSString stringWithFormat:@"%@/forgotpassword.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:tfEmailForgotPassword.text forKey:@"email"];
    
    [request setDelegate:self];
    [request startSynchronous];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //userid,tripname, name,start_date, finish_date,trip_budget
    NSError *error = [request error];
    if (!error) {
        NSLog(@"NO error");
        NSData *response = [request responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSLog(@"%@",dict);
        if ([[dict objectForKey:@"success"] intValue]== 0) {
            [delegate showAlert:[dict objectForKey:@"message"]];
        }else{
            [delegate showAlert:[NSString stringWithFormat:@"Your request was sent to %@",tfEmailForgotPassword.text]];
            tfEmailForgotPassword.text = @"";
            [self.view endEditing:YES];
            viewForgotPassword.hidden = YES;
        }
    }
}
- (IBAction)takePhotoClick:(id)sender {
    NSString *model = [[UIDevice currentDevice] model];
    
    if ([model isEqualToString:@"iPhone Simulator"]) {
        UIAlertView *funSpoAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Take Photo cannot be completed on simulator." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [funSpoAlertView show];
    }
    else
    {
        viewPhoto.hidden = YES;
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
        pickerImage.delegate = self;
        pickerImage.allowsEditing = YES;
        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerImage animated:YES completion:nil];
    }
}

- (IBAction)chooseFromLibClick:(id)sender {
    viewPhoto.hidden = YES;
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.delegate = self;
    pickerImage.allowsEditing = YES;
    pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:pickerImage animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)pickerImage
      didFinishPickingImage : (UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo
{
    btnDeleteAvatar.hidden = NO;
    isAddAvatar = TRUE;
    //    [asynImgPhoto setImage:image forState:UIControlStateNormal];
    [asynImgPhoto loadIMageFromImage:image];
    [self saveImageIntoFolder:image];
    [pickerImage dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)  pickerImage
{
    [pickerImage dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveImageIntoFolder: (UIImage*)image
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageNewUser.png"];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}
- (UIImage*)loadImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageNewUser.png"];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}
#pragma mark Alert View

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}
- (IBAction)btnForgotPasswordClick:(id)sender {
    [self.view endEditing:YES];
    viewForgotPassword.hidden = NO;
    [tfEmailForgotPassword becomeFirstResponder];
//    return;
//    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Forgot Password" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok",@"Cancel", nil];
//    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    dialog.tag = 1;
//    // Change keyboard type
//    [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeEmailAddress];
//    [[dialog textFieldAtIndex:0] setPlaceholder:@"E-mail address"];
//    [dialog show];
}

- (IBAction)btnDeleteAvatar:(id)sender {
    btnDeleteAvatar.hidden = YES;
    isAddAvatar = false;
    [asynImgPhoto loadIMageFromImage:[UIImage imageNamed:@"default_avatar.png"]];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 0){
            if(![self validateEmail:[[alertView textFieldAtIndex:0]text]]) {
                // user entered invalid email address
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                alert.tag = 2;
                [alert show];
            } else {
                // user entered valid email address
            }
        }
    }else{
        if (buttonIndex == 0){
            [self btnForgotPasswordClick:nil];
        }
    }
}

@end
