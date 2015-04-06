//
//  LeftTabBarViewController.m
//  Fun Spot App
//
//  Created by wang chenglei on 1/30/14.
//
//

#import "LeftTabBarViewController.h"
//#import "ANIHomeViewController.h"
//#import "StoreViewController.h"
//#import "ContactUsViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "ANICustomButton.h"
#import "UIColor-Expanded.h"
//#import "LocationViewController.h"
//#import "DiscountViewController.h"
//#import "ChooseApplicationListViewController.h"
//#import "ChooseThemeListViewController.h"
//#import "VideoListingViewController.h"
//#import "PlaceListViewController.h"
//#import "BrowserViewController.h"
#import "BaseNavigationController.h"
#import "PhotoViewController.h"
//#import "Language.h"
//#import "SettingScreenViewController.h"
//#import "AppDelegate.h"
//#import "NewsHomeViewController.h"
//#import "EventHomeViewController.h"
//#import "NewsViewController.h"
//#import "EventCategoryViewController.h"

#import "LoginControllerVC.h"
#import "EditAccountVC.h"
#import "AddPhotoVC.h"
#import "NoteVC.h"
#import "AlertVC.h"
#import "GroupVC.h"
#import "PackingVC.h"
#import "ExpenseVC.h"
#import "ReceiptVC.h"
#import "AddTripVC.h"
#import "TripDetailVC.h"
#import "DialogLogOutVC.h"
#import "SlideShowVC.h"
#import "ConfirmInvitationVC.h"

@interface LeftTabBarViewController ()
{
    AppDelegate *delegate;
}

@end

@implementation LeftTabBarViewController

@synthesize buttonTitles = _buttonTitles;
@synthesize buttonIcons = _buttonIcons;
@synthesize defaultButtonIcons = _defaultButtonIcons;
//@synthesize downloads = _downloads;
@synthesize eventPlaceArr = _eventPlaceArr;
@synthesize lefTabBarDelegate = _lefTabBarDelegate;

@synthesize m_parentView;
@synthesize m_parentViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        imageName = [[NSMutableArray alloc] init];
        self.buttonTitles = [[NSMutableArray alloc] init];
        self.buttonIcons = [[NSMutableArray alloc] init];
        self.defaultButtonIcons = [[NSMutableArray alloc] init];
        self.eventPlaceArr = [[NSMutableArray alloc] init];
        imageName = [[NSMutableArray alloc] init];
        self.eventPlaceArr = [[NSMutableArray alloc] init];

        delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLinkToggleButtonImage:(UIViewController *)parentViewController {
    self.m_parentViewController = parentViewController;
}

- (void)createButtons {
    
    strSelTabName = @"";
    
    [_defaultButtonIcons removeAllObjects];
    NSString *file = [[NSBundle mainBundle] pathForResource:@"MenuIcons" ofType:@"plist"];
    [_defaultButtonIcons addObjectsFromArray:[NSArray arrayWithContentsOfFile:file]];
    
    for (UIView *subView in [self.view subviews]) {
        [subView removeFromSuperview];
    }
    
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        delegate.funSpotDict = [sqliteManager readFun];
    }
    
    NSLog(@"egatae  = %@",delegate.funSpotDict);
    NSLog(@"Before _buttonTitles  = %@",_buttonTitles);
    
    [_buttonTitles removeAllObjects];
    NSString *buttonfile = [[NSBundle mainBundle] pathForResource:@"MenuButtons" ofType:@"plist"];
    [_buttonTitles addObjectsFromArray:[NSArray arrayWithContentsOfFile:buttonfile]];
    
    [_buttonIcons removeAllObjects];
    NSString *iconfile = [[NSBundle mainBundle] pathForResource:@"MenuIcons" ofType:@"plist"];
    [_buttonIcons addObjectsFromArray:[NSArray arrayWithContentsOfFile:iconfile]];
    
    // Home
    if ([[delegate.funSpotDict valueForKey:@"TabHomeTitle"] length] > 0) {
        _buttonTitles[0] = @"TabHomeTitle";
    }
    
    if ([[delegate.funSpotDict valueForKey:@"TabHomeLogo"] length] > 0) {
        _buttonIcons[0] = @"TabHomeLogo";
    }
    
    //Store
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowMag"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabStore"] length] > 0) {
            _buttonTitles[1] = @"TabStore";
        }
        
        if ([[delegate.funSpotDict valueForKey:@"TabLogoStore"] length] > 0) {
            _buttonIcons[1] = @"TabLogoStore";
        }
    } else {
        
    }
    
    //Store2
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowMag2"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabStore2"] length] > 0) {
            _buttonTitles[2] = @"TabStore2";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoStore2"] length] > 0) {
            _buttonIcons[2] = @"TabLogoStore2";
        }
    } else {
        
    }
    
    //Store3
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowMag3"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabStore3"] length] > 0) {
            _buttonTitles[3] = @"TabStore3";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoStore3"] length] > 0) {
            _buttonIcons[3] = @"TabLogoStore3";
        }
    } else {
        
    }
    
    //Location
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsMap"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabLocation"] length] > 0) {
            _buttonTitles[4] = @"TabLocation";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoLocation"] length] > 0) {
            _buttonIcons[4] = @"TabLogoLocation";
        }
    } else {
        
    }
    
    //Gallery
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsGallery"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabGallery"] length] > 0) {
            _buttonTitles[5] = @"TabGallery";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoGallery"] length] > 0) {
            _buttonIcons[5] = @"TabLogoGallery";
        }
    } else {
        
    }
    
    //Event
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowEvent"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabEvent"] length] > 0) {
            _buttonTitles[6] = @"TabEvent";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoEvent"] length] > 0) {
            _buttonIcons[6] = @"TabLogoEvent";
        }
    }
    
    //News
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowNews"] isEqualToString:@"true"]) {
        if([[delegate.funSpotDict valueForKey:@"TabNews"] length] > 0) {
            _buttonTitles[7] = @"TabNews";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoNews"] length] > 0) {
            _buttonIcons[7] = @"TabLogoNews";
        }
    } else {
    }
    
    //Contact
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsContact"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabContact"] length] > 0) {
            _buttonTitles[8] = @"TabContact";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoContact"] length] > 0) {
            _buttonIcons[8] = @"TabLogoContact";
        }
    } else {
        
    }
    
    //Coupon
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowCoupon"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabCoupon"] length] > 0) {
            _buttonTitles[9] = @"TabCoupon";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoCoupon"] length] > 0) {
            _buttonIcons[9] = @"TabLogoCoupon";
        }
    } else {
    }
    
    //PlaceIsShowPlace
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowPlace"] isEqualToString:@"true"]) {
        if([[delegate.funSpotDict valueForKey:@"TabPlace"] length] > 0) {
            _buttonTitles[10] = @"TabPlace";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoPlace"] length] > 0) {
            _buttonIcons[10] = @"TabLogoPlace";
        }
    } else {
    }
    
    //PlaceIsShowVideo
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowVideo"] isEqualToString:@"true"]) {
        if([[delegate.funSpotDict valueForKey:@"TabVideo"] length] > 0) {
            _buttonTitles[11] = @"TabVideo";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoVideo"] length] > 0) {
            _buttonIcons[11] = @"TabLogoVideo";
        }
    } else {
    }
    
    //PlaceIsShowSite
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowSite"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabSite"] length] > 0) {
            _buttonTitles[12] = @"TabSite";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoSite"] length] > 0) {
            _buttonIcons[12] = @"TabLogoSite";
        }
    } else {
    }
    
    //PlaceIsShowSite2
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowSite2"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabSite2"] length] > 0) {
            _buttonTitles[13] = @"TabSite2";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoSite2"] length] > 0) {
            _buttonIcons[13] = @"TabLogoSite2";
        }
    } else {
    }
    
    //PlaceIsShowSite3
    if ([[delegate.funSpotDict valueForKey:@"PlaceIsShowSite3"] isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabSite3"] length] > 0) {
            _buttonTitles[14] = @"TabSite3";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoSite"] length] > 0) {
            _buttonIcons[14] = @"TabLogoSite3";
        }
    } else {
        
    }
    
    //PlaceIsMother
//    if ([[delegate.funSpotDict valueForKey:@"PlaceIsMother"] isEqualToString:@"true"]) {
    if ([PLACEISMOTHER isEqualToString:@"true"]) {
        if ([[delegate.funSpotDict valueForKey:@"TabChoose"] length] > 0) {
            _buttonTitles[15] = @"TabChoose";
        }
        if ([[delegate.funSpotDict valueForKey:@"TabLogoChoose"] length] > 0) {
            _buttonIcons[15] = @"TabLogoChoose";
        }
    } else {
        
    }
    
    NSMutableArray *showButtons = [[NSMutableArray alloc] init];
    showButtons = _buttonTitles;
//    [showButtons addObject:@"true"];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowMag"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowMag2"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowMag3"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsMap"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsGallery"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowEvent"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowNews"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsContact"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowCoupon"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowPlace"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowVideo"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowSite"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowSite2"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsShowSite3"]];
//    [showButtons addObject:[delegate.funSpotDict valueForKey:@"PlaceIsMother"]];
//    [showButtons addObject:PLACEISMOTHER];
    
    UIImage *image = nil;
    UIColor *color = nil;
    
    color = [UIColor colorWithRed:71/255.0 green:71/255.0 blue:71/255.0 alpha:1.0];
//    color = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_nav"]];
//    if(!color) color = COLOR_BG;
    
    self.view.backgroundColor = color;
    
    UIScrollView *menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, self.view.frame.size.height-HEIGHT)];
    menuScrollView.tag = SCROLL_TAG;
    menuScrollView.backgroundColor = [UIColor whiteColor];
    
    float top = 0;
    
    for (int i=0 ; i<[_buttonTitles count]; i++) {
        CGRect frame = CGRectZero;
        
//        if ([showButtons[i] isEqualToString:@"true"]) {
            frame = CGRectMake(0, top, WIDTH, HEIGHT-1);
            top += HEIGHT;
//        } else {
//            frame = CGRectMake(-WIDTH, 0, 0, 0);
//        }
        
//        color = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_nav"]];
//        if(!color) color = COLOR_BG;
        color = [UIColor colorWithRed:71/255.0 green:71/255.0 blue:71/255.0 alpha:1.0];

        ANICustomButton *btn = [[ANICustomButton alloc] initWithFrame:frame image:image color:color];
        btn.data = _buttonTitles[i];
        btn.tag = LEFT_TAB_ITME_TAG+i;
        
        [btn setTitle:_buttonTitles[i] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:12.0f]];
//        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:10.0f]];
        [btn.titleLabel setTextAlignment:NSTextAlignmentLeft];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 0);
        
        color = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_nav_text"]];
        if(!color) color = COLOR_TEXT;
        
        [btn addTarget:self action:@selector(actionButton:) forControlEvents:UIControlEventTouchUpInside];
        [menuScrollView addSubview:btn];
    }
    
    menuScrollView.frame = CGRectMake(0, 0, WIDTH, top);
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    if (mainRect.size.height <= 480) {
        [menuScrollView setContentSize:CGSizeMake(menuScrollView.frame.size.width-100, top+HEIGHT)];
    }
    [self.view addSubview:menuScrollView];
    
    // Configuration Button
    CGRect frame = CGRectMake(0, self.view.frame.size.height-HEIGHT,WIDTH, HEIGHT);
    ANICustomButton *btn = [[ANICustomButton alloc]initWithFrame:frame image:nil color:[UIColor lightGrayColor]];
    btn.data = @"LOG OUT";
    btn.tag = 21000;
//    btn.m_titleLabel.text = @"LOG OUT";
    [btn setTitle:@"LOG OUT" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:10.0f]];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -55, 0, 0);
    [btn setBackgroundColor:[UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1.0]];
//    btn.m_iconImageView.image = [UIImage imageNamed:@"menu_logout.png"];
    btn.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 88);
    
    UIImage *img = [UIImage imageNamed:@"menu_logout.png"];
    [btn setImage:img forState:UIControlStateNormal];
    
    UIImage *imgPress = [UIImage imageNamed:@"menu_logout_press.png"];
    [btn setImage:imgPress forState:UIControlStateHighlighted];
    [btn setTitleColor:ColorHighlighted forState:UIControlStateHighlighted];
    
    [btn addTarget:self action:@selector(actionButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [_buttonIcons addObject:@"PlaceTabLogo"];
    [_buttonIcons addObject:@"PlaceBackLogo"];
    
    if (delegate.isUpdateAvailable) {
        [sqliteManager clearIcons];
        delegate.isUpdateAvailable = NO;
    }
    
    [self loadIconImages];
}

//Loading all the images Asynchronously

-( void)loadIconImages {
    for (int i=0;i<[_buttonIcons count];i++) {
        ANICustomButton *btn = (ANICustomButton *)[self.view viewWithTag:LEFT_TAB_ITME_TAG+i];
        btn.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 88);
        
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",_buttonIcons[i]]];
        [btn setImage:img forState:UIControlStateNormal];
        
        UIImage *imgPress = [UIImage imageNamed:[NSString stringWithFormat:@"%@_press.png",_buttonIcons[i]]];
        [btn setImage:imgPress forState:UIControlStateHighlighted];
        [btn setTitleColor:ColorHighlighted forState:UIControlStateHighlighted];
        
        if (![btn.data isEqualToString:@"MENU"]) {
            UIImage *imgSelect = [UIImage imageNamed:[NSString stringWithFormat:@"%@_select.png",_buttonIcons[i]]];
            [btn setImage:imgSelect forState:UIControlStateSelected];
            [btn setTitleColor:ColorSelected forState:UIControlStateSelected];
        }
        
        if ([btn.data isEqualToString:@"HOME"]) {
            [btn setSelected:YES];
        }
    }
    [self.lefTabBarDelegate leftTabBarIconDownloadDidFinished];
    return;
    
    
    NSMutableArray *iconImgArr ;
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    
    @synchronized(self){
        iconImgArr = [sqliteManager getIconImages];
    }
    
    NSLog(@"OCUnt %d",[iconImgArr count]);
    
    if ([iconImgArr count] > 0) {
        for (int i=0;i<[_buttonIcons count];i++) {
            NSData *imageData = nil;
            
            @synchronized(self) {
                NSLog(@"[_buttonIcons objectAtIndex:i] %@",_buttonIcons[i]);
                IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
                imageData = [sqliteManager getIconImage:[NSString stringWithFormat:@"MenuIcon_%@", _buttonIcons[i]]];
            }
            
            if (i == [_buttonIcons count]-1 || i == [_buttonIcons count]-2) {
                // toggle button icon And back button icon
            } else {
                if (imageData == nil) {
                    UIScrollView *menuScrollView = (UIScrollView *)[self.view viewWithTag:SCROLL_TAG];
                    
                    ANICustomButton *btn = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+i];
                    
                    NSLog(@"R %@",[NSString stringWithFormat:@"%@",_defaultButtonIcons[i]]);
                    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@",_defaultButtonIcons[i]]];
                    [btn.m_iconImageView setImage:img];
                    

                } else {
                    ANICustomButton *btn = (ANICustomButton *)[self.view viewWithTag:LEFT_TAB_ITME_TAG+i];
                    UIImage *icn = [UIImage imageWithData:imageData];
                    if (icn) {
                        [btn.m_iconImageView setImage:icn];
                    } else {
                        NSLog(@"R %@",[NSString stringWithFormat:@"%@",_defaultButtonIcons[i]]);
                        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@",_defaultButtonIcons[i]]];
                        [btn.m_iconImageView setImage:img];
                    }
                }
            }
        }
        
        if(self.lefTabBarDelegate && [self.lefTabBarDelegate respondsToSelector:@selector(leftTabBarIconDownloadDidFinished)]) {
            [self.lefTabBarDelegate leftTabBarIconDownloadDidFinished];
        } else {
            [self updateApplication];
        }

    } else {
        
        NSMutableArray *imageUrls = [NSMutableArray new];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @synchronized(self)
            {
                [sqliteManager createTable:@"IconImages"];
            }
        });
        
        NSLog(@"_buttonIcons %@",_buttonIcons);
        
        for(int i=0;i<[_buttonIcons count];i++) {
            NSString *imageURL = nil;
            
            if ([_buttonIcons[i] isEqualToString:@"Settings"]) {
                //UIImage *imgSetting = [UIImage imageNamed:@"Settings.png"];
                //[sqliteManager saveIconImage:[NSString stringWithFormat:@"MenuIcon_Settings"] Image:imgSetting];
            } else {
                if ([[delegate.funSpotDict valueForKey:_buttonIcons[i]] length] >0) {
                    imageURL = [delegate.funSpotDict valueForKey:_buttonIcons[i]];
                    [imageUrls addObject:imageURL];
                    [imageName addObject:_buttonIcons[i]];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @synchronized(self){
                            [sqliteManager saveIconImage:[NSString stringWithFormat:@"MenuIcon_%@",_buttonIcons[i]] Image:nil];
                        }
                    });
                }
            }
        }
        
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus = [reach currentReachabilityStatus];
        
        NSLog(@"imageUrls = %@",imageUrls);
        
        if (netStatus != NotReachable) {
            if ([imageUrls count] >0) {
                [MBProgressHUD showHUDAddedTo:delegate.window WithTitle:nil animated:YES];
//                _downloads = [[MultipleDownload alloc] initWithUrls: imageUrls];
//                _downloads.delegate = self;
            } else {
                [self didFinishAllDownload];
                //[self loadIconImages];
            }
        } else {
            //them vo khi chay offline
            [self.lefTabBarDelegate leftTabBarIconDownloadDidFinished];
//            [delegate showAlert:NSLocalizedString(@"NetworkAlert", @"")];
        }
    }
}

- (void) didFinishDownload:(NSNumber*)idx {
    
//    if ([_downloads dataAsImageAtIndex:[idx intValue]]) {
//        UIImage *image = [_downloads dataAsImageAtIndex:[idx intValue]];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @synchronized(self)
//            {
//                IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
//                [sqliteManager saveIconImage:[NSString stringWithFormat:@"MenuIcon_%@",imageName[[idx intValue]]] Image:image];
//            }
//        });
//    }
}

- (void) didFinishAllDownload {
    
	NSLog(@"Finished all download!");
    [MBProgressHUD hideAllHUDsForView:delegate.window animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self)
        {
            [self loadIconImages];
        }
    });
}

- (void)didFailDownloadWithError:(NSError *)error {
    
}

#pragma mark - Show / Hide LeftTabBar

- (void)showLeftTabBar:(UIView *)parentView show:(BOOL)bShow delegate:(UIViewController *)parentViewController rect:(CGRect)rect selected:(NSString *)selectedName {
    
    self.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    UIScrollView *menuScrollView = (UIScrollView *)[self.view viewWithTag:SCROLL_TAG];
    
    if (menuScrollView.frame.size.height > self.view.frame.size.height-HEIGHT) {
        menuScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    ANICustomButton *btn = (ANICustomButton *)[self.view viewWithTag:21000];
    btn.frame = CGRectMake(0, self.view.frame.size.height-HEIGHT, WIDTH, HEIGHT);
    
    if (bShow) {
        [parentView addSubview:self.view];
    } else {
        [self.view removeFromSuperview];
    }

    UIColor *color = nil;
    color = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_nav"]];
    if(!color) color = COLOR_BG;
    
    ANICustomButton *btnSel = NULL;
    
    if ([strSelTabName isEqualToString:@"Store"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+1];
    } else if ([strSelTabName isEqualToString:@"Store2"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+2];
    } else if ([strSelTabName isEqualToString:@"Store3"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+3];
    } else if ([strSelTabName isEqualToString:@"Event"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+6];
    } else if ([strSelTabName isEqualToString:@"News"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+7];
    } else if ([strSelTabName isEqualToString:@"Contact"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+8];
    } else if ([strSelTabName isEqualToString:@"Coupon"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+9];
    } else if ([strSelTabName isEqualToString:@"Place"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+10];
    } else if ([strSelTabName isEqualToString:@"Video"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+11];
    } else if ([strSelTabName isEqualToString:@"Choose"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+15];
    }
    [btnSel setBackgroundColor:color];

    if ([selectedName isEqualToString:@"Store"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+1];
    } else if ([selectedName isEqualToString:@"Store2"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+2];
    } else if ([selectedName isEqualToString:@"Store3"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+3];
    } else if ([selectedName isEqualToString:@"Event"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+6];
    } else if ([selectedName isEqualToString:@"News"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+7];
    } else if ([selectedName isEqualToString:@"Contact"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+8];
    } else if ([selectedName isEqualToString:@"Coupon"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+9];
    } else if ([selectedName isEqualToString:@"Place"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+10];
    } else if ([selectedName isEqualToString:@"Video"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+11];
    } else if ([selectedName isEqualToString:@"Choose"]) {
        btnSel = (ANICustomButton *)[menuScrollView viewWithTag:LEFT_TAB_ITME_TAG+15];
    }
    [btnSel setBackgroundColor:[UIColor greenColor]];

    self.m_parentView = parentView;
    self.m_parentViewController = parentViewController;
    strSelTabName = selectedName;
}

#pragma mark - Button Actions

- (void)actionButton:(id)sender {
    
    if ([self.m_parentViewController isKindOfClass:[EditAccountVC class]]) {
        EditAccountVC *viewCtrl = (EditAccountVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }else if ([self.m_parentViewController isKindOfClass:[AddPhotoVC class]]) {
        AddPhotoVC *viewCtrl = (AddPhotoVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[NoteVC class]]) {
        NoteVC *viewCtrl = (NoteVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[AlertVC class]]) {
        AlertVC *viewCtrl = (AlertVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[GroupVC class]]) {
        GroupVC *viewCtrl = (GroupVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[PackingVC class]]) {
        PackingVC *viewCtrl = (PackingVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[ExpenseVC class]]) {
        ExpenseVC *viewCtrl = (ExpenseVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[ReceiptVC class]]) {
        ReceiptVC *viewCtrl = (ReceiptVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[LoginControllerVC class]]) {
        LoginControllerVC *viewCtrl = (LoginControllerVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[AddTripVC class]]) {
        AddTripVC *viewCtrl = (AddTripVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[SlideShowVC class]]) {
        SlideShowVC *viewCtrl = (SlideShowVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    else if ([self.m_parentViewController isKindOfClass:[TripDetailVC class]]) {
        TripDetailVC *viewCtrl = (TripDetailVC *)self.m_parentViewController;
        [viewCtrl btnHomeClick:nil];
    }
    
    ANICustomButton *button = (ANICustomButton*)sender;
//    [button setSelected:YES];
//    UIScrollView *menuScrollView = (UIScrollView *)[self.view viewWithTag:SCROLL_TAG];
    
    for (int i=0;i<[_buttonIcons count];i++) {
        ANICustomButton *btn = (ANICustomButton *)[self.view viewWithTag:LEFT_TAB_ITME_TAG+i];
//        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//        if (![button.data isEqualToString:@"MENU"]) {
//            if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1 || [button.data isEqualToString:@"ACCOUNT"]){
//                if (btn.tag == button.tag)
//                    [btn setSelected:YES];
//                else
//                    [btn setSelected:NO];
//            }
//        }
        
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if (![[userDefault objectForKey:@"addingTrip"] intValue] == 1 && ![button.data isEqualToString:@"ACCOUNT"]) {
            btn = (ANICustomButton *)[self.view viewWithTag:LEFT_TAB_ITME_TAG+1];
            [btn setSelected:YES];
            btn = (ANICustomButton *)[self.view viewWithTag:LEFT_TAB_ITME_TAG+2];
            [btn setSelected:NO];
        }else{
            if (![button.data isEqualToString:@"MENU"]) {
                if (btn.tag == button.tag) {
                    [btn setSelected:YES];
                }else
                    [btn setSelected:NO];
            }
        }
    }
    NSLog(@"button Title %@",button.data);
    
    if ([button.data isEqualToString:@"HOME"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            if (![self.m_parentViewController isKindOfClass:[TripDetailVC class]]){
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                TripDetailVC *viewController = [[TripDetailVC alloc]initWithNibName:@"TripDetailVC" bundle:nil];
                [navCtrl pushViewController:viewController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]]) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                LoginControllerVC  *loginController = [[LoginControllerVC alloc] initWithNibName:@"LoginControllerVC" bundle:nil];
                [navCtrl pushViewController:loginController animated:YES];
            }
        }
    } else if ([button.data isEqualToString:@"ACCOUNT"]) {
        if (![self.m_parentViewController isKindOfClass:[EditAccountVC class]]) {
            UINavigationController *navCtrl = self.m_parentViewController.navigationController;
            [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            
            EditAccountVC *editAccController = [[EditAccountVC alloc] initWithNibName:@"EditAccountVC" bundle:nil];
            [navCtrl pushViewController:editAccController animated:YES];
        }
    } else if ([button.data isEqualToString:@"ADD PHOTO"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        AddPhotoVC *addPhotoController = [[AddPhotoVC alloc] initWithNibName:@"AddPhotoVC" bundle:nil];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            if (![self.m_parentViewController isKindOfClass:[AddPhotoVC class]] ||([self.m_parentViewController isKindOfClass:[AddPhotoVC class]] && addPhotoController.isAddPhoto == NO)) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                
                addPhotoController.isAddPhoto  = YES;
                addPhotoController.isTakePhoto = NO;
                [navCtrl pushViewController:addPhotoController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]])
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            AddTripVC *addPhotoController = [[AddTripVC alloc] initWithNibName:@"AddTripVC" bundle:nil];
            [navCtrl pushViewController:addPhotoController animated:YES];
        }
    } else if ([button.data isEqualToString:@"TAKE PHOTO"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            AddPhotoVC *addPhotoController = [[AddPhotoVC alloc] initWithNibName:@"AddPhotoVC" bundle:nil];
            if (![self.m_parentViewController isKindOfClass:[AddPhotoVC class]] ||([self.m_parentViewController isKindOfClass:[AddPhotoVC class]] && addPhotoController.isTakePhoto == NO)) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                addPhotoController.isAddPhoto  = NO;
                addPhotoController.isTakePhoto = YES;
                [navCtrl pushViewController:addPhotoController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]])
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            AddTripVC *addPhotoController = [[AddTripVC alloc] initWithNibName:@"AddTripVC" bundle:nil];
            [navCtrl pushViewController:addPhotoController animated:YES];
        }
        
    }else if ([button.data isEqualToString:@"NOTES"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            if (![self.m_parentViewController isKindOfClass:[NoteVC class]]) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                
                NoteVC *noteViewController = [[NoteVC alloc] initWithNibName:@"NoteVC" bundle:nil];
                [navCtrl pushViewController:noteViewController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]])
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            AddTripVC *addPhotoController = [[AddTripVC alloc] initWithNibName:@"AddTripVC" bundle:nil];
            [navCtrl pushViewController:addPhotoController animated:YES];
        }
        
    } else if ([button.data isEqualToString:@"ALERTS"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            if (![self.m_parentViewController isKindOfClass:[AlertVC class]]) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                
                AlertVC *alertViewController = [[AlertVC alloc] initWithNibName:@"AlertVC" bundle:nil];
                [navCtrl pushViewController:alertViewController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]])
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            AddTripVC *addPhotoController = [[AddTripVC alloc] initWithNibName:@"AddTripVC" bundle:nil];
            [navCtrl pushViewController:addPhotoController animated:YES];
        }
    } else if ([button.data isEqualToString:@"GROUP"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            if (![self.m_parentViewController isKindOfClass:[GroupVC class]]) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                
                GroupVC *groupViewController = [[GroupVC alloc] initWithNibName:@"GroupVC" bundle:nil];
                [navCtrl pushViewController:groupViewController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]])
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            AddTripVC *addPhotoController = [[AddTripVC alloc] initWithNibName:@"AddTripVC" bundle:nil];
            [navCtrl pushViewController:addPhotoController animated:YES];
        }
    } else if ([button.data isEqualToString:@"PACKING"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            if (![self.m_parentViewController isKindOfClass:[PackingVC class]]) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                
                PackingVC *packingAccController = [[PackingVC alloc] initWithNibName:@"PackingVC" bundle:nil];
                [navCtrl pushViewController:packingAccController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]])
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            AddTripVC *addPhotoController = [[AddTripVC alloc] initWithNibName:@"AddTripVC" bundle:nil];
            [navCtrl pushViewController:addPhotoController animated:YES];
        }
    } else if ([button.data isEqualToString:@"EXPENSES"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            if (![self.m_parentViewController isKindOfClass:[ExpenseVC class]]) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                
                ExpenseVC *expensesController = [[ExpenseVC alloc] initWithNibName:@"ExpenseVC" bundle:nil];
                [navCtrl pushViewController:expensesController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]])
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            AddTripVC *addPhotoController = [[AddTripVC alloc] initWithNibName:@"AddTripVC" bundle:nil];
            [navCtrl pushViewController:addPhotoController animated:YES];
        }
    }else if ([button.data isEqualToString:@"SLIDESHOW"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            if (![self.m_parentViewController isKindOfClass:[SlideShowVC class]]) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                
                SlideShowVC *ReceiptController = [[SlideShowVC alloc] initWithNibName:@"SlideShowVC" bundle:nil];
                [navCtrl pushViewController:ReceiptController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]])
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            AddTripVC *addPhotoController = [[AddTripVC alloc] initWithNibName:@"AddTripVC" bundle:nil];
            [navCtrl pushViewController:addPhotoController animated:YES];
        }
    } else if ([button.data isEqualToString:@"RECEIPTS"]) {
        UINavigationController *navCtrl = self.m_parentViewController.navigationController;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([[userDefault objectForKey:@"addingTrip"] intValue] == 1) {
            if (![self.m_parentViewController isKindOfClass:[ReceiptVC class]]) {
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
                
                ReceiptVC *ReceiptController = [[ReceiptVC alloc] initWithNibName:@"ReceiptVC" bundle:nil];
                [navCtrl pushViewController:ReceiptController animated:YES];
            }
        }else{
            if (![self.m_parentViewController isKindOfClass:[LoginControllerVC class]])
                [self.m_parentViewController.navigationController popViewControllerAnimated:NO];
            AddTripVC *addPhotoController = [[AddTripVC alloc] initWithNibName:@"AddTripVC" bundle:nil];
            [navCtrl pushViewController:addPhotoController animated:YES];
        }
    }else if ([button.data isEqualToString:@"LOG OUT"]) {
        DialogLogOutVC *viewController = [[DialogLogOutVC alloc]init];
        [self.m_parentViewController addChildViewController:viewController];
        viewController.view.frame = self.m_parentViewController.view.frame;
        [self.m_parentViewController.view addSubview:viewController.view];
        viewController.view.alpha = 0;
        [viewController didMoveToParentViewController:self];
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^
         {
             viewController.view.alpha = 1;
         }
        completion:nil];
        
    }else if([button.data isEqualToString:@"menu_location"] || [button.data isEqualToString:@"TabLocation"]) {
        @synchronized(self) {
            [self PlaceApplicationGetEventPlace:self];
        }
        
    } else if([button.data isEqualToString:@"menu_gallery"] || [button.data isEqualToString:@"TabGallery"] || [button.data isEqualToString:@"view_gallery"]) {
        IMSSqliteManager *sqlMngr = [[IMSSqliteManager alloc] init];
        @synchronized(self){
            if(delegate.isUpdateAvailableForGallery){
                [sqlMngr clearGalleryContent];
            }
        }
        
        PhotoViewController *pageZero = [PhotoViewController photoViewControllerForPageIndex:0];
        if (pageZero != nil) {
            // assign the first page to the pageViewController (our rootViewController)
            UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
            pageViewController.dataSource = self;
            pageViewController.automaticallyAdjustsScrollViewInsets = NO;
            
            [pageViewController setViewControllers:@[pageZero]
                                         direction:UIPageViewControllerNavigationDirectionForward
                                          animated:NO
                                        completion:NULL];

            BaseNavigationController *navController = [[BaseNavigationController alloc] initWithRootViewController:pageViewController];
            pageZero.title =@"adassdd";

            pageViewController.navigationItem.title  = [delegate.funSpotDict valueForKey:@"gallery"];
            
            UIColor *color = nil;
            color = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_nav"]];
            if(!color) color = COLOR_NAV;
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                pageViewController.navigationController.navigationBar.barTintColor = color;
            } else {
                pageViewController.navigationController.navigationBar.tintColor = color;
            }
            
            UIColor *colornavtxt = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_nav_text"]];
            if(!colornavtxt) colornavtxt = [UIColor whiteColor];
            pageViewController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: colornavtxt};

            UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:(delegate.funSpotDict)[@"ok"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissScreen:)];
            pageViewController.navigationItem.rightBarButtonItem = doneBtn;
            
            [self.m_parentViewController presentViewController:navController animated:YES completion:nil];
        }
        
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    return [PhotoViewController photoViewControllerForPageIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    return [PhotoViewController photoViewControllerForPageIndex:(index + 1)];
}

- (void)dismissScreen :(id)sender{
    [self.m_parentViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)PlaceApplicationGetEventPlace:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service PlaceApplicationGetEventPlace:self action:@selector(onEventPlaceLoad:) theFunspotId:[[delegate.funSpotDict valueForKey:@"articleid"] intValue] country:COUNTRYNAME];
}

- (void)onEventPlaceLoad:(id)value {
    
//    NSLog(@"onEventPlaceLoad:::class==%@===response==%@",[self class],value);
//    
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    if (value && value!=[NSError class] && [value isKindOfClass:[NSDictionary class]]) {
//        
//        NSMutableArray *arrEventPlace = [[NSMutableArray alloc] init];
//        NSDictionary *dictResponse = [(NSDictionary*)value valueForKey:@"PlaceApplicationGetEventPlaceResult"];
//        
//        if ([dictResponse valueForKey:@"diffgram"] != [NSNull null]) {
//            dictResponse = [dictResponse valueForKey:@"diffgram"];
//            
//            if (dictResponse) {
//                if ([dictResponse valueForKey:@"DocumentElement"] != [NSNull null]) {
//                    
//                    dictResponse = [dictResponse valueForKey:@"DocumentElement"];
//                    if (dictResponse) {
//                        
//                        dictResponse = [dictResponse valueForKey:@"result"];
//                        if (dictResponse && [dictResponse isKindOfClass:[NSArray class]]) {
//                            
//                            for (NSDictionary *eventCatDict in dictResponse) {
//                                eventsPlace = [[EventPlace alloc] init];
//                                
//                                eventsPlace.adress = eventCatDict[@"adress"] != [NSNull null] ?eventCatDict[@"adress"] : @"NA";
//                                eventsPlace.city = eventCatDict[@"city"] != [NSNull null] ?eventCatDict[@"city"] : @"NA";
//                                eventsPlace.location = eventCatDict[@"location"] != [NSNull null] ?eventCatDict[@"location"] : @"NA";
//                                eventsPlace.latitude = eventCatDict[@"latitude"] != [NSNull null] ?eventCatDict[@"latitude"] : @"NA";
//                                eventsPlace.longitude = eventCatDict[@"longitude"] != [NSNull null] ?eventCatDict[@"longitude"] : @"NA";
//                                eventsPlace.zip = eventCatDict[@"zip"] != [NSNull null] ? [eventCatDict[@"zip"] integerValue] : 0;
//                                eventsPlace.typeadress = eventCatDict[@"typeadress"] != [NSNull null] ?eventCatDict[@"typeadress"] : @"NA";
//                                eventsPlace.rowOrder = [eventCatDict[@"rowOrder"] integerValue];
//                                
//                                [arrEventPlace addObject:eventsPlace];
//                            }
//                        } else {
//                            eventsPlace = [[EventPlace alloc] init];
//                            
//                            eventsPlace.adress = dictResponse[@"adress"] != [NSNull null] ?dictResponse[@"adress"] : @"NA";
//                            eventsPlace.city = dictResponse[@"city"] != [NSNull null] ?dictResponse[@"city"] : @"NA";
//                            eventsPlace.location = dictResponse[@"location"] != [NSNull null] ?dictResponse[@"location"] : @"NA";
//                            eventsPlace.latitude = dictResponse[@"latitude"] != [NSNull null] ?dictResponse[@"latitude"] : @"NA";
//                            eventsPlace.longitude = dictResponse[@"longitude"] != [NSNull null] ?dictResponse[@"longitude"] : @"NA";
//                            eventsPlace.zip = dictResponse[@"zip"] != [NSNull null]?[dictResponse[@"zip"] integerValue]:0;
//                            eventsPlace.typeadress = dictResponse[@"typeadress"] != [NSNull null] ?dictResponse[@"typeadress"] : @"NA";
//                            eventsPlace.rowOrder = [dictResponse[@"rowOrder"] integerValue];
//                            
//                            [arrEventPlace addObject:eventsPlace];
//                        }
//                        
//                        IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
//                        @synchronized(self)
//                        {
//                            [sqliteManager createTable:@"EventPlace"];
//                            [sqliteManager storeEventPlaces:arrEventPlace];
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    [self showCarte];
}

- (void)showCarte {
    
//    [self readEventsPlacefromDatabase];
//    
//    LocationViewController *viewcontroller = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
//    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:viewcontroller];
//    
//    viewcontroller.eventPlaceArr = _eventPlaceArr;
//    viewcontroller.navigationItem.title = [delegate.funSpotDict valueForKey:@"menu_location"];
//    
//    viewcontroller.mapType = @"MenuClass";
//    [self.m_parentViewController presentViewController:nav animated:YES completion:nil];
}

- (void)readEventsPlacefromDatabase {
    
    [_eventPlaceArr removeAllObjects];
    @synchronized(self)
    {
        IMSSqliteManager *_sqlManager = [[IMSSqliteManager alloc] init];
        self.eventPlaceArr = [_sqlManager readPlaceEvents];
    }
}

#pragma mark - Check Application Update

- (void)checkForUpdates {
    
    [MBProgressHUD showHUDAddedTo:self.m_parentViewController.view WithTitle:nil animated:YES];
    
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service PlaceApplicationIsUpdate:self action:@selector(onIsUpdateLoad:) thecode:delegate.CurrentCode country:COUNTRYNAME];
}

- (void)onIsUpdateLoad:(id)value {
    
    [MBProgressHUD hideAllHUDsForView:self.m_parentViewController.view animated:YES];
    
    if (value == nil || value == [NSError class] || ![value isKindOfClass:[NSDictionary class]]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"web_connexion_problem"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];

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

        // update
        [self loadMainData];
        return;
    } else {
        self.lefTabBarDelegate = nil;
        [self createButtons];
        return;
    }
}

- (void)loadMainData {
    
    [MBProgressHUD showHUDAddedTo:self.m_parentViewController.view WithTitle:nil animated:YES];
    
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service PlaceApplicationGetMainDatasLangue:self action:@selector(onMainDataload:) thecode:delegate.CurrentCode thelangue:delegate.langCode country:COUNTRYNAME];
}

- (void)onMainDataload:(id)value
{
    [MBProgressHUD hideAllHUDsForView:self.m_parentViewController.view animated:YES];
    
    if (value == nil || value == [NSError class] || ![value isKindOfClass:[NSDictionary class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"web_connexion_problem"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (((NSDictionary*)value)[@"PlaceApplicationGetMainDatasLangueResult"] == nil ||
        [(NSDictionary*)value valueForKey:@"PlaceApplicationGetMainDatasLangueResult"] == NULL) {
        [self loadMainData];
        return;
    }
    
    NSDictionary *dictResponse = [(NSDictionary*)value valueForKey:@"PlaceApplicationGetMainDatasLangueResult"];
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
    
    NSArray *keys = @[@"DeviseSigle",@"HorizontalMainPhoto",@"LangueId",@"Logo",@"MainPhoto",@"Placedelegate.CurrentCode",@"PlaceAppId",@"PlaceCouponVersion",@"PlaceEventVersion",@"PlaceGalleryVersion",@"PlaceIsShowNews",@"PlaceMainVersion",@"PlaceNewsVersion",@"PlaceStoreVersion",@"PlaceVideoVersion",@"PlacePlaceVersion",@"PlaceCouponVersion",@"PlaceType",@"PlaceIsShowCoupon",@"PlaceIsShowEvent",@"SplashScreen",@"Store",@"StoreLevel",@"VerticalMainPhoto",@"annuaire_mail",@"article_adresse",@"article_intro",@"article_latitude",@"article_longitude",@"article_tel",@"article_texte",@"article_titre",@"articleid",@"color_bg",@"color_nav",@"color_text",@"id",@"rowOrder",@"ville_cp",@"ville_nom",@"TabLogoChoose",@"TabLogoContact",@"TabLogoCoupon",@"TabLogoEvent",@"TabLogoGallery",@"TabLogoLocation",@"TabLogoNews",@"TabLogoPlace",@"TabLogoSite",@"TabLogoSite2",@"TabLogoSite3",@"TabLogoStore",@"TabLogoStore2",@"TabLogoStore3",@"TabLogoVideo",@"TabChoose",@"TabContact",@"TabCoupon",@"TabEvent",@"TabGallery",@"TabLocation",@"TabNews",@"TabPlace",@"TabSite",@"TabSite2",@"TabSite3",@"TabStore",@"TabStore2",@"TabStore3",@"TabVideo",@"VerticalMainPhoto",@"PlaceIsShowMag",@"PlaceIsShowMag2",@"PlaceIsShowMag3",@"PlaceIsMap",@"PlaceIsGallery",@"PlaceIsContact",@"PlaceIsShowPlace",@"PlaceIsShowSite",@"PlaceIsShowSite2",@"PlaceIsShowSite3",@"PlaceIsShowVideo",@"PlaceIsMother",@"color_text_home",@"color_bg_home",@"color_active",@"PlaceAppDM",@"PlaceAppFB",@"PlaceAppTW",@"PlaceAppYT",@"PlaceAppGP",@"PlaceAppLK",@"PlaceAppSite",@"PlaceAppSite2",@"PlaceAppSite3",@"PlaceIsChildMap",@"PlaceIsTitle",@"PlaceTabLogo",@"color_nav_text",@"PlaceIsLangue",@"PlaceIsAlert",@"StoreId1",@"StoreId2",@"StoreId3",@"PlaceHomeTypeId",@"StoreLevel",@"StoreLevel2",@"StoreLevel3",@"PlaceAppIsChooseTheme", @"map", @"topmap", @"PlaceBackLogo", @"TabHomeTitle", @"TabHomeLogo",@"PlaceAppMessage"];
    
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    [sqliteManager createTable:@"Fun"];
    
    for (NSString *key in keys) {
        @synchronized(self)
        {
            [sqliteManager addToFunKey:key Value:(([dictResponse valueForKey:key] == [NSNull null] || ([[dictResponse valueForKey:key] isEqualToString:@"<null>"])) ? @"" : [dictResponse valueForKey:key])];
        }
    }
    
    NSDictionary *responseDict = [sqliteManager readTimeofLastUpdate:@"PlaceMainVersion"];
    if ([responseDict count] == 0) {
        
        [sqliteManager createTable:@"Updates"];
        [sqliteManager addUpdates:@"PlaceMainVersion" Value:[dictResponse valueForKey:@"PlaceMainVersion"] status:TRUE];
    }
    
    if (![[responseDict valueForKey:@"PlaceMainVersion"] isEqualToString:[dictResponse valueForKey:@"PlaceMainVersion"]]) {
        [sqliteManager  addUpdates:@"PlaceMainVersion" Value:[dictResponse valueForKey:@"PlaceMainVersion"] status:FALSE];
    }
    
    @synchronized(self)
    {
        delegate.funSpotDict = [sqliteManager readFun];
    }
    
    [self loadTraductionFile];
}

//=========Get data for traduction file======//

- (void)loadTraductionFile {
    
    [MBProgressHUD showHUDAddedTo:self.m_parentViewController.view WithTitle:nil animated:YES];
    
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service PlaceApplicationGetTraductionFile:self action:@selector(onTraductionLoad:) thelanguage:[delegate langId] country:COUNTRYNAME];
}

- (void)onTraductionLoad:(id)value
{
    [MBProgressHUD hideHUDForView:self.m_parentViewController.view animated:YES];
    
    if (value == nil || value == [NSError class] || ![value isKindOfClass:[NSDictionary class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"web_connexion_problem"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
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
    
    [MBProgressHUD showHUDAddedTo:self.m_parentViewController.view WithTitle:nil animated:YES];
    
//    ANIPlaceService *service = [ANIPlaceService service];
//    [service PlaceApplicationGetPictures:self action:@selector(onPicturesLoad:) theFunspotId:[[delegate.funSpotDict valueForKey:@"articleid"] intValue] country:COUNTRYNAME];
}

- (void)onPicturesLoad:(id)value
{
    [MBProgressHUD hideHUDForView:self.m_parentViewController.view animated:YES];
    
    if (value == nil || value == [NSError class] || ![value isKindOfClass:[NSDictionary class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"web_connexion_problem"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
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

    self.lefTabBarDelegate = nil;
    [self createButtons];
}

- (void)updateApplication {

}

@end
