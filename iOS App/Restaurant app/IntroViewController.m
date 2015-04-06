//
//  IntroViewController.m
//  Restaurant app
//
//

#import "IntroViewController.h"
//#import "ANIPlaceService.h"
#import "Common.h"
#import "AppDelegate.h"
//#import "ANIHomeViewController.h"
//#import "NewsHomeViewController.h"
//#import "EventHomeViewController.h"
#import "LeftTabBarViewController.h"
#import "ApplicationData.h"
#import "IMSSqliteManager.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
//#import "RegisterNewUserVC.h"
//#import "ProfileConnectViewController.h"
#import "LoginControllerVC.h"
#import "TripDetailVC.h"

#define kConfigPlistName @"config"

@implementation IntroViewController

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
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBarHidden = YES;
    isMemory = false;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];

    
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
//    arrayCountry = [[NSMutableArray alloc] init];
//    [self validateNotCommand];
    [self goMainScreen];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
//        [btnSelectCountry setTitle:[userDefault objectForKey:@"userCountry"] forState:UIControlStateNormal];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //Code for OK button
        [self goMainScreen];
    }
    
    if (buttonIndex == 1) {
        [self loadMainData];
        //Code for download button
    }
}

- (bool)isDataExist {
    
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    
    int tblCount = [sqliteManager funSpotTableCount];
    if (tblCount > 0)
        return TRUE;
    else
        return FALSE;
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
    if ([tfEmail.text isEqualToString:@""]) {
        [delegate showAlert:[delegate.funSpotDict objectForKey:@"alert_email"]];
        return;
    }
    if ([tfPassword.text isEqualToString:@""]) {
        [delegate showAlert:[delegate.funSpotDict objectForKey:@"alert_pwd"]];
        return;
    }
    if ([btnSelectCountry.titleLabel.text isEqualToString:[delegate.funSpotDict objectForKey:@"select_country"]]) {
        [delegate showAlert:[delegate.funSpotDict objectForKey:@"alert_country"]];
        return;
    }
    [self loginCommand];
}

- (IBAction)btnCancelClick:(id)sender {
    pickerView.hidden = YES;
}

- (IBAction)btnDoneClick:(id)sender {
    pickerView.hidden = YES;
    [btnSelectCountry setTitle:strCountry forState:UIControlStateNormal];
    delegate.currentCountry = strShotCountry;
}

- (IBAction)btnSignupClick:(id)sender {
//    RegisterNewUserVC *viewController = [[RegisterNewUserVC alloc]initWithNibName:@"RegisterNewUserVC" bundle:nil];
//    [self.navigationController pushViewController:viewController animated:NO];
}

- (IBAction)btnSelectCountryClick:(id)sender {
    [self.view endEditing:YES];
    pickerView.hidden = NO;
}

#pragma mark - LeftTabBarIconDownloadDelegate

- (void)leftTabBarIconDownloadDidFinished {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *str = [NSString stringWithFormat:@"%@",[userDefault objectForKey:@"addingTrip"]];
    if ([str isEqualToString:@"1"]) {
        TripDetailVC *viewController = [[TripDetailVC alloc]initWithNibName:@"TripDetailVC" bundle:nil];
        [self.navigationController pushViewController:viewController animated:NO];
    }else{
        LoginControllerVC *viewController = [[LoginControllerVC alloc]initWithNibName:@"LoginControllerVC" bundle:nil];
        [self.navigationController pushViewController:viewController animated:NO];
    }
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
            //
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
//                    ProfileConnectViewController *controller = [[ProfileConnectViewController alloc] initWithNibName:@"ProfileConnectViewController" bundle:nil];
//                    [self.navigationController pushViewController:controller animated:YES];
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if (([txt isKindOfClass:[UITextField class]] || [txt isKindOfClass:[UITextView class]])&& [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}

@end
