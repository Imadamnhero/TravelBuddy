//
//  AppDelegate.h
//  Restaurant app
//  Pradeep Sundriyal iMonkServices
//  OM JSR

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"
#import "LeftTabBarViewController.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    sqlite3             *database;
    NSString            *serviceKey;
    NSString            *langId;
    NSDictionary        *funSpotDict;
    NSString            *userLattitude;
    NSString            *userLongitude;
    CLLocationManager   *locationManager;
	CLLocation          *startingPoint;
    
    bool isUpdateAvailableForNews;
    bool isUpdateAvailableForCoupon;
    bool isUpdateAvailableForEvent;
    bool isUpdateAvailableForGallery;
    bool isUpdateAvailableForStore;
    bool isUpdateAvailable;
    bool isUpdateAvailableforPlaceVersion;
    bool isUpdateAvailableForPlaceVideos;
    
    NSString    *CurrentCode;
    NSString    *langCode;
    NSString    *deviceToken;
    NSDictionary *remoteNotif;
}

@property (strong, nonatomic) LeftTabBarViewController *leftTabBarViewCtrl;
@property (strong, nonatomic) NSOperationQueue *myQueue,*syncQueue;
@property (strong, nonatomic) NSOperationQueue *mainQueue;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSString *serviceKey;
@property (nonatomic, strong) NSString *langId, *deviceToken;
@property (nonatomic, strong) NSDictionary *funSpotDict;
@property (nonatomic, strong) NSString *userLattitude;
@property (nonatomic, strong) NSString *userLongitude;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *startingPoint;
@property (nonatomic, strong) NSString *CurrentCode,*langCode;
@property (nonatomic, strong) NSString *currentCountry;
@property (nonatomic, strong) NSMutableArray *arrayPhotoSyncing;
@property (nonatomic, strong) NSMutableArray *arrayColor;

@property (nonatomic) bool isUpdateAvailableForNews;
@property (nonatomic) bool isUpdateAvailableForCoupon;
@property (nonatomic) bool isUpdateAvailableForEvent;
@property (nonatomic) bool isUpdateAvailableForGallery;
@property (nonatomic) bool isUpdateAvailableForStore,isUpdateAvailable,isUpdateAvailableforPlaceVersion;
@property (nonatomic) bool isUpdateAvailableForPlaceVideos;
//
@property (nonatomic) bool isUpdateAvailableForNote;
- (void)showAlert:(NSString *)Message;
- (BOOL)connectedToNetwork;

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (UIImage *)thumbWithSideOfLength:(float)length :(UIImage *) mainImage;

- (void)loadHomePageBackgroundImage:(NSString*)imageURL;
- (NSString*)formatDateFromDateString:(NSString*)date;
@end
