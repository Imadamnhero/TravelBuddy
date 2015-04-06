//
//  BaseTableViewController.m
//  Fun Spot App
//
//  Created by  Rawat on 08/02/13.
//
//

#import "BaseTableViewController.h"
//#import "ANIHomeViewController.h"
//#import "LocationViewController.h"
#import "ImageGalleryViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController
@synthesize appDelagte = _appDelagte;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.appDelagte = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self setNavigationButons];
    
    UIColor *color = [UIColor colorWithHexString:(_appDelagte.funSpotDict)[@"color_bg"]];
    if(!color) color = COLOR_BG;
    self.tableView.backgroundColor = color;
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    UIColor *color = [UIColor colorWithHexString:(_appDelagte.funSpotDict)[@"color_nav"]];
    if(!color) color = COLOR_NAV;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationController.navigationBar.barTintColor = color;
    } else {
        self.navigationController.navigationBar.tintColor = color;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationButons
{
    NSData *imageData = nil;
    
    @synchronized(self) {
        IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
        imageData = [sqliteManager getIconImage:[NSString stringWithFormat:@"MenuIcon_%@", @"PlaceBackLogo"]];
    }
    
    UIImage *imageHome = [UIImage imageWithData:imageData];
    if (imageHome == NULL) {
        imageHome = [UIImage imageNamed:@"back_nav.png"];
    }
    
    // draw tint color
    
    UIColor *colornavtxt = [UIColor colorWithHexString:(_appDelagte.funSpotDict)[@"color_nav_text"]];
    if(!colornavtxt) colornavtxt = [UIColor whiteColor];
    
    UIButton *btnHome = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHome setImage:[Common colorizeImage:imageHome color:colornavtxt] forState:UIControlStateNormal];
    btnHome.frame= CGRectMake(0.0, 0.0, 30, 30);
    [btnHome addTarget:self action:@selector(actionHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnBarHome = [[UIBarButtonItem alloc]initWithCustomView:btnHome];
    self.navigationItem.leftBarButtonItem = btnBarHome;
    
    UIBarButtonItem *btnLoc = [[UIBarButtonItem alloc] initWithTitle:[_appDelagte.funSpotDict valueForKey:@"menu_location"] style:UIBarButtonItemStyleDone target:self action:@selector(actionLocation:)];
    
   // UIBarButtonItem *btnGallery = [[UIBarButtonItem alloc] initWithTitle:[_appDelagte.funSpotDict valueForKey:@"view_gallery"] style:UIBarButtonItemStyleDone target:self action:@selector(actionGallery:)];
    
    //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btnLoc, btnGallery, nil];
    //Marc ask to remove gallery button from all inner screens
    self.navigationItem.rightBarButtonItems = @[btnLoc];
}

// Button Action Home
- (void) actionHome:(id)sender
{
//    _appDelagte.window.rootViewController = nil;
//    
//    ANIHomeViewController *viewController = [[ANIHomeViewController alloc]initWithNibName:@"ANIHomeViewController" bundle:nil];
//    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
//    _appDelagte.window.rootViewController = navController;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) actionLocation:(id)sender
{
//    LocationViewController *loc = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
//    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:loc];
//    NSArray *locArr =  @[[_appDelagte.funSpotDict valueForKey:@"article_latitude"],[_appDelagte.funSpotDict valueForKey:@"article_longitude"]];
//    loc.placeCoords = locArr;

//    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void) actionGallery:(id)sender
{
    ImageGalleryViewController *imageGallery = [[ImageGalleryViewController alloc] initWithNibName:@"ImageGalleryViewController" bundle:nil];
    self.navigationItem.title =@"Back";
    [[self navigationController] pushViewController:imageGallery animated:YES];
}


//=========Error in netwrok request or Soap parser fault======//

- (void) onerror: (NSError*) error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

//- (void) onfault: (SoapFault*) fault
//{
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    UIColor *color = [UIColor colorWithHexString:(_appDelagte.funSpotDict)[@"color_bg"]];
    if(!color) color = COLOR_BG;
    [cell setBackgroundColor:color];
}

@end
