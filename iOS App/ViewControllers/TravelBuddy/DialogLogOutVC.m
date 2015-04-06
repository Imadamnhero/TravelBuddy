//
//  DialogLogOutVC.m
//  Fun Spot App
//
//  Created by MAC on 8/27/14.
//
//

#import "DialogLogOutVC.h"
#import "IntroViewController.h"

@interface DialogLogOutVC ()

@end

@implementation DialogLogOutVC

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
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = YES;
    bgImgLogOur.layer.cornerRadius = 5.0;
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
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    NSError *error = [request error];
//    if (!error) {
//        NSLog(@"NO error");
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        NSData *response = [request responseData];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
//        NSLog(@"%@",dict);
////        if (dict == nil) {
////            //            [delegate showAlert:@"Server is not connected"];
////            return;
////        }
////        if ([[dict objectForKey:@"success"] intValue] == 0) {
////            [delegate showAlert:[dict objectForKey:@"message"]];
////        }else{
////            [delegate showAlert:[dict objectForKey:@"message"]];
////        }
//    }
}
- (IBAction)btnYesClick:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    VersionObj *objVersion = [[VersionObj alloc] init];
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
        objVersion.categoryVersion = 0;
        objVersion.expenseVersion = 0;
        [sqliteManager updateVersion:objVersion];
    }
    
    @synchronized(self)
    {
        [sqliteManager dropTable:@"PremadeLists"];
        [sqliteManager dropTable:@"PremadeItems"];
        [sqliteManager dropTable:@"Categories"];
        [sqliteManager dropTable:@"Expenses"];
    }
//    NSOperationQueue *myQueue = [[NSOperationQueue alloc]init];
//    [myQueue addOperationWithBlock:^{
        [self afterLogout];
//    }];

    for (int i = delegate.arrayColor.count - 1 ; i > 5; i --) {
        [delegate.arrayColor removeObjectAtIndex:i];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"0" forKey:@"addingTrip"];
    [userDefault setObject:@"0" forKey:@"isLogin"];
    [userDefault synchronize];
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[IntroViewController class]]) {
            [self.parentViewController.navigationController popToViewController:viewController animated:YES];
            [self performSelector:@selector(pushView:) withObject:viewController afterDelay:0.6];
            break;
        }
    }
    
    UIViewController *vc = [self.parentViewController.childViewControllers lastObject];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}
- (void) pushView:(UIViewController*)viewController{
    IntroViewController *vc = (IntroViewController*)viewController;
    [vc goMainScreen];
}
- (IBAction)btnNoClick:(id)sender {
    UIViewController *vc = [self.parentViewController.childViewControllers lastObject];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}
@end
