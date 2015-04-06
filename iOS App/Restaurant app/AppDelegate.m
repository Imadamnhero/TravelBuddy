//
//  AppDelegate.m
//  Restaurant app
//
//PRADEEP SUNDRIYAL
//Code	3db1bef0-2550-4271-af77-42240fbbed8e
//Edited :  Rawat

#import "AppDelegate.h"
//#import "ANIHomeViewController.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "IMSSqliteManager.h"
#import "BaseNavigationController.h"
#import "IntroViewController.h"
#import "ConfirmInvitationVC.h"
#import "TripDetailVC.h"
#import <HockeySDK/HockeySDK.h>
//#import "UAConfig.h"
//#import "UAirship.h"
//#import "UAPush.h"
//#import "UAAnalytics.h"
//#import "ANIPlaceService.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize langId,serviceKey;
@synthesize funSpotDict;
@synthesize userLattitude;
@synthesize userLongitude;
@synthesize locationManager,startingPoint;
@synthesize isUpdateAvailableForNews;
@synthesize isUpdateAvailableForCoupon,isUpdateAvailableForEvent,isUpdateAvailableForGallery,isUpdateAvailableForStore;
@synthesize isUpdateAvailableforPlaceVersion,isUpdateAvailableForPlaceVideos;
@synthesize CurrentCode;
@synthesize langCode;
@synthesize deviceToken;
@synthesize isUpdateAvailable;
@synthesize leftTabBarViewCtrl;
@synthesize currentCountry;
@synthesize myQueue,mainQueue,syncQueue;
@synthesize isUpdateAvailableForNote;
@synthesize arrayPhotoSyncing,arrayColor;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0];
    
    [Common copyDatabaseIfNeeded];
    
    myQueue = [[NSOperationQueue alloc] init];
    [myQueue setMaxConcurrentOperationCount:1];
    
    syncQueue = [[NSOperationQueue alloc] init];
    [syncQueue setMaxConcurrentOperationCount:1];
    
    mainQueue = [NSOperationQueue mainQueue];

    langCode = @"FR";
    
    IntroViewController *viewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
    BaseNavigationController *navController = [[BaseNavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navController;

    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    // Display a UIAlertView warning developers that push notifications do not work in the simulator
    // You should remove this in your app.
    [self failIfSimulator];
    
//#ifdef __IPHONE_8_0
//    //Right, that is the point
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
//                                                                                         |UIRemoteNotificationTypeSound
//                                                                                         |UIRemoteNotificationTypeAlert) categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//#else
//    //register to receive notifications
//    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
//#endif
//    if (checkiOS8) {
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
//                                                                                             |UIRemoteNotificationTypeSound
//                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    }else{
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//    }
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (remoteNotif) {
//        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Alert1 launching"
//                                                            message:[NSString stringWithFormat:@"%@",remoteNotif]
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK1"
//                                                  otherButtonTitles:nil];
//        [someError show];
//    }
    isUpdateAvailableForNote = true;
    arrayPhotoSyncing = [[NSMutableArray alloc] init];
    [USER_DEFAULT setObject:@"0" forKey:@"mainSyncing"];
//    [USER_DEFAULT setObject:@"0" forKey:@"showAlertGuide"];
    [USER_DEFAULT synchronize];
    
    NSString *strings[6];
    strings[0] = @"d324ff";
    strings[1] = @"ffed24";
    strings[2] = @"24b6ff";
    strings[3] = @"2eff24";
    strings[4] = @"ff6224";
    strings[5] = @"242eff";
    arrayColor = [NSMutableArray arrayWithObjects:strings count:6];
    
    //code for hockey
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"70c76313971e3d3da53a4a4520fa42fd"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator
     authenticateInstallation];
    return YES;
}
#ifdef __IPHONE_8_0
//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
//{
//    //register to receive notifications
//    [application registerForRemoteNotifications];
//}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
        [self handlePushNotification:application withUserInfor:userInfo];
    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
    // Get a hex string from the device token with no spaces or < >
    
    self.deviceToken = [[NSString alloc] init];
    
    self.deviceToken = [[[[_deviceToken description]
                     stringByReplacingOccurrencesOfString: @"<" withString: @""]
                    stringByReplacingOccurrencesOfString: @">" withString: @""]
                   stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"deviceToken = %@",deviceToken);
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.deviceToken forKey:@"userDeviceToken"];
    [userDefault synchronize];
}

- (void)setPlaceApplicationRegisterDevice {
    
}

- (void)onDeviceDataLoad:(id)value {
    NSLog(@"onDeviceDataLoad:::class==%@===response==%@",[self class],value);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (remoteNotif) {
        NSDictionary *dictAps = [remoteNotif objectForKey:@"aps"];
        if (dictAps) {
            NSDictionary *dictBody = [dictAps objectForKey:@"data"];
            
            if ([[dictBody objectForKey:@"type"] intValue] == 1) {
                
                ConfirmInvitationVC *viewController = [[ConfirmInvitationVC alloc] initWithNibName:@"ConfirmInvitationVC" bundle:nil];
                viewController.dictInforUser = dictBody;
                
                [self.window.rootViewController addChildViewController:viewController];
                viewController.view.frame = self.window.rootViewController.view.frame;
                [self.window.rootViewController.view addSubview:viewController.view];
                viewController.view.alpha = 0;
                [viewController didMoveToParentViewController:self.window.rootViewController];
                
                [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^
                 {
                     viewController.view.alpha = 1;
                 }
                                 completion:nil];
                application.applicationIconBadgeNumber +=1;
            }
        }
        
        
//        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Alert Become Active"
//                                                            message:[NSString stringWithFormat:@"%@",remoteNotif]
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [someError show];
    }
    application.applicationIconBadgeNumber = 0;
    
}
- (void) handlePushNotification:(UIApplication *)application withUserInfor:(NSDictionary *)userInfo{
    NSDictionary *dictAps = [userInfo objectForKey:@"aps"];
    if (dictAps) {
        NSDictionary *dictBody = [dictAps objectForKey:@"data"];
        
        if ([[dictBody objectForKey:@"type"] intValue] == 1) {
            
            ConfirmInvitationVC *viewController = [[ConfirmInvitationVC alloc] initWithNibName:@"ConfirmInvitationVC" bundle:nil];
            viewController.dictInforUser = dictBody;
            
            [self.window.rootViewController addChildViewController:viewController];
            viewController.view.frame = self.window.rootViewController.view.frame;
            [self.window.rootViewController.view addSubview:viewController.view];
            viewController.view.alpha = 0;
            [viewController didMoveToParentViewController:self.window.rootViewController];
            
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^
             {
                 viewController.view.alpha = 1;
             }
                             completion:nil];
            application.applicationIconBadgeNumber +=1;
        }else if ([[dictBody objectForKey:@"type"] intValue] == 2) {
            
            if ([[dictBody objectForKey:@"reply"] intValue] == 1) {
                UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:[NSString stringWithFormat:@"Your invitation has been accepted by %@",[dictBody objectForKey:@"inviter_name"]]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [someError show];
                [TripDetailVC syncUsers];
            }else{
                UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:[NSString stringWithFormat:@"Your invitation has been declined by %@",[dictBody objectForKey:@"inviter_name"]]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [someError show];
            }
        }else if ([[dictBody objectForKey:@"type"] intValue] == 3 ){
            application.applicationIconBadgeNumber +=1;
            //                if (application.applicationState == UIApplicationStateActive ) {
            //                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            //                    localNotification.userInfo = userInfo;
            //                    localNotification.soundName = UILocalNotificationDefaultSoundName;
            //                    localNotification.alertBody = [dictBody objectForKey:@"content"];
            //                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
            //                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            //                }
            NSString *strAlert = [NSString stringWithFormat:@"%@ has sent an alert",[dictBody objectForKey:@"sender_name"]];
            UIAlertView *someError = [[UIAlertView alloc] initWithTitle:strAlert
                                                                message:[dictBody objectForKey:@"content"]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [someError show];
            
        }else {
            if ([[dictBody objectForKey:@"is_owner"] intValue] == 1 ){
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:@"0" forKey:@"addingTrip"];
                [userDefault synchronize];
                
                //            UIViewController *vc = [(BaseNavigationController *)self.window.rootViewController visibleViewController];
                //            [vc.navigationController popToRootViewControllerAnimated:YES];
                
                BaseNavigationController *nav = (BaseNavigationController *)self.window.rootViewController;
                for (UIViewController *viewController in nav.viewControllers) {
                    if ([viewController isKindOfClass:[IntroViewController class]]) {
                        [nav popToViewController:viewController animated:YES];
                        [self performSelector:@selector(pushView:) withObject:viewController afterDelay:0.6];
                        break;
                    }
                }
                
                UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:[dictBody objectForKey:@"message"]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [someError show];
            }else{
                UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:[NSString stringWithFormat:@"%@ has just left your trip",[dictBody objectForKey:@"user_name"]]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [someError show];
            }
            IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
            @synchronized(self)
            {
                [sqlManager deleteUser:[[dictBody objectForKey:@"user_id"] intValue]];
            }
            
        }
    }
    application.applicationIconBadgeNumber = 0;
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"userInfo %@",userInfo);
    [self handlePushNotification:application withUserInfor:userInfo];
}
- (void) pushView:(UIViewController*)viewController{
    IntroViewController *vc = (IntroViewController*)viewController;
    [vc goMainScreen];
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}
- (void)failIfSimulator {
    if ([[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location != NSNotFound) {
        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                             message:@"You will not be able to receive push notifications in the simulator."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        
        // Let the UI finish launching first so it doesn't complain about the lack of a root view controller
        // Delay execution of the block for 1/2 second.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [someError show];
        });
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    if (remoteNotif) {
//        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Alert2 launching"
//                                                            message:[NSString stringWithFormat:@"%@",remoteNotif]
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK2"
//                                                  otherButtonTitles:nil];
//        [someError show];
//    }
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
//    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (remoteNotificationPayload) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"notification" object:nil userInfo:remoteNotificationPayload];
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    if(sqlite3_close(database) != SQLITE_OK)
		NSAssert1(0, @"Error while closing the connection to the db. %s", sqlite3_errmsg(database));
}

- (BOOL)handleOpenURL:(NSURL*)url
{
    return YES;
}

//Databse Handling

- (void)showAlert:(NSString *)Message{
    
    UIAlertView *funSpoAlertView = [[UIAlertView alloc] initWithTitle:@"" message:Message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [funSpoAlertView show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	if (startingPoint == nil)
		self.startingPoint = newLocation;
    
	NSString *latitudeString = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.latitude];
	self.userLattitude = latitudeString;

	NSString *longitudeString = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.longitude];
	self.userLongitude = longitudeString;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	//NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
    
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied)
    {
        NSString *msg=@"You have disabled location services for FunSpot app.To perfrom location based search in future please enable location services for Fun Spot app from the Settings application by toggling the Location Services switch for Fun Spot in General";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
        alert.tag = 100;
        [alert show];
    }
}

//Method to check Network

- (BOOL)connectedToNetwork
{
    const char *host_name = "google.com";
    BOOL _isDataSourceAvailable = NO;
    Boolean success;
    
    //Creates a reachability reference to the specified
    //network host or node name.
    SCNetworkReachabilityRef reachability =
    SCNetworkReachabilityCreateWithName(NULL,host_name);
    
    //Determines if the specified network target is reachable
    //using the current network configuration.
    SCNetworkReachabilityFlags flags;
    
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    _isDataSourceAvailable = success &&
    (flags & kSCNetworkFlagsReachable) &&
    !(flags & kSCNetworkFlagsConnectionRequired);
    
    CFRelease(reachability);
    return _isDataSourceAvailable;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [self handleOpenURL:url];  
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)thumbWithSideOfLength:(float)length :(UIImage *) mainImage {

    UIImage *thumbnail;
    UIImageView *mainImageView = [[UIImageView alloc] initWithImage: mainImage];
    mainImageView.layer.cornerRadius = 4.0;

    BOOL widthGreaterThanHeight = (mainImage.size.width > mainImage.size.height);
    float sideFull = (widthGreaterThanHeight) ? mainImage.size.height : mainImage.size.width;
    
    CGRect clippedRect = CGRectMake(0, 0, sideFull, sideFull);
    UIGraphicsBeginImageContext(CGSizeMake(length, length));
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextClipToRect( currentContext, clippedRect);
    CGFloat scaleFactor = length/sideFull;
    
    if (widthGreaterThanHeight) {
        CGContextTranslateCTM(currentContext, -((mainImage.size.width - sideFull) / 2) * scaleFactor, 0);
    }
    else {
        CGContextTranslateCTM(currentContext, 0, -((mainImage.size.height - sideFull) / 2) * scaleFactor);
    }
    
    //this will automatically scale any CGImage down/up to the required thumbnail side (length) when the CGImage gets drawn into the context on the next line of code
    CGContextScaleCTM(currentContext, scaleFactor, scaleFactor);
    [mainImageView.layer renderInContext:currentContext];
    thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(thumbnail);
    //[imageData writeToFile:fullPathToThumbImage atomically:YES];
    thumbnail = [UIImage imageWithData:imageData];
    
    return thumbnail;
}
//format date
- (NSString*)formatDateFromDateString:(NSString*)date{
    NSString *strDate = @"";
    int day   = [[date substringWithRange:NSMakeRange(0, 2)] intValue];
    int month = [[date substringWithRange:NSMakeRange(3, 2)] intValue];
    int year  = [[date substringWithRange:NSMakeRange(6, 4)] intValue];
    strDate = [NSString stringWithFormat:@"%d-%d-%d",day,month,year];
    return strDate;
}
//Loading image asynchronously
- (void)loadHomePageBackgroundImage:(NSString*)imageURL {
    
    NSURL *url=[NSURL URLWithString:imageURL];
    [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:NULL];

    NSURLRequest * imageReq = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:imageReq
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *imageData,
                                               NSError *error)
     {
         
         if ([imageData length] >0 && error == nil) {
             // Save Image to database
             IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 @synchronized(self)
                 {
                     [sqliteManager createTable:@"AppImages"];
                 }
             });

             UIImage *homePageImage = [UIImage imageWithData:imageData];

             dispatch_async(dispatch_get_main_queue(), ^{
                 @synchronized(self)
                 {
                     [sqliteManager saveImage:@"MainPageImage" Image:homePageImage];
                 }
             });
             [[NSNotificationCenter defaultCenter] postNotificationName:kHomePageImageDownloaded object:homePageImage];
         }
     }];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

@end
