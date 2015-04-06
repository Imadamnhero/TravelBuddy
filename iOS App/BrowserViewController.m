//
//  BrowserViewController.m
//  Fun Spot App
//
//  Created by PradeepSundriyal on 23/07/13.
//
//

#import "BrowserViewController.h"

@interface BrowserViewController ()

@property (nonatomic, strong, readonly) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *stopBarButtonItem;

- (IBAction)goBackClicked:(UIBarButtonItem *)sender;
- (IBAction)goForwardClicked:(UIBarButtonItem *)sender;
- (IBAction)reloadClicked:(UIBarButtonItem *)sender;
- (IBAction)cancelClicked:(UIBarButtonItem *)sender;

@end

@implementation BrowserViewController

@synthesize URL, toolBar;
@synthesize backBarButtonItem, forwardBarButtonItem, refreshBarButtonItem, stopBarButtonItem;
@synthesize isFromTab;
@synthesize webView = _webView;

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
    
    delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    UIColor *colornav = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_nav"]];
    if(!colornav) colornav = COLOR_NAV;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationController.navigationBar.barTintColor = colornav;
    } else {
        self.navigationController.navigationBar.tintColor = colornav;
    }
    
    UIColor *colorbg = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_bg"]];
    if(!colorbg) colorbg = COLOR_BG;
    _webView.backgroundColor = colorbg;
    
    NSLog(@"URL %@",URL);

    if (isFromTab) {
        URL = (delegate.funSpotDict)[@"PlaceAppSite"];
        self.navigationItem.hidesBackButton = YES;
        
        if ([(delegate.funSpotDict)[@"PlaceAppMessage"] length] > 0) {
            self.navigationItem.title = (delegate.funSpotDict)[@"PlaceAppMessage"];
        } else {
            self.navigationItem.title = (delegate.funSpotDict)[@"article_titre"];
        }
        
        UIColor *colornavtext = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_nav_text"]];
        if(!colornavtext) colornavtext = [UIColor whiteColor];
        
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: colornavtext};

    } else {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
    [toolBar setTintColor:COLOR_NAV];
}

- (void)loadURL:(NSString *)pageURL {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pageURL]]];
}

- (void)refreshView:(id)sender {
    [self loadURL:URL];
}

- (void)setNavigationButons{}

- (IBAction)goBackClicked:(UIBarButtonItem *)sender {
    [_webView goBack];
}

- (IBAction)goForwardClicked:(UIBarButtonItem *)sender {
    [_webView goForward];
}

- (IBAction)reloadClicked:(UIBarButtonItem *)sender {
    [_webView  reload];
}

- (IBAction)cancelClicked:(UIBarButtonItem *)sender {
    
    [_webView stopLoading];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
    NSLog(@"start");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"finish");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Error for WEBVIEW: %@", [error description]);

    NSString *errorReason;
    
    if (error.code==NSURLErrorTimedOut) {
        errorReason=@"URL Time Out Error ";
    } else if (error.code==NSURLErrorCannotFindHost) {
        errorReason=@"Cannot Find Host ";
    } else if (error.code==NSURLErrorCannotConnectToHost) {
        errorReason=@"Cannot Connect To Host";
    } else if (error.code==NSURLErrorNetworkConnectionLost) {
        errorReason=@"Network Connection Lost";
    } else if (error.code==NSURLErrorUnknown) {
        errorReason=@"Unknown Error";
    } else {
        errorReason=@"Loading Failed";
    }
    
//    UIAlertView *errorAlert=[[UIAlertView alloc]initWithTitle:errorReason message:@"Redirecting to the server failed. do you want to EXIT the app"  delegate:self cancelButtonTitle:@"EXIT" otherButtonTitles:@"RELOAD", nil];
//  [errorAlert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

@end