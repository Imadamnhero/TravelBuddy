//
//  PreviewSlideshow.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "PreviewSlideshow.h"
#import "FileHelper.h"

@interface PreviewSlideshow ()

@end

@implementation PreviewSlideshow
@synthesize image,strVideoLink,strImageLink;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) addSlideshowToLocalDatabase{
    IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
    @synchronized(self){
        [sqlManager saveSlideshow:strVideoLink photo:strImageLink];
    }
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
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    
    bgInviteFriend.layer.cornerRadius = 5.0;
    bgSendEmail.layer.cornerRadius    = 5.0;
    btnHome.imageEdgeInsets = UIEdgeInsetsMake(7, 12, 7, 8);
    [btnImagePlayVideo loadIMage:image];
    NSURL *url = [NSURL URLWithString:strVideoLink];
    [btnPlay addTarget:self action:@selector(actionPauseOrPlay) forControlEvents:UIControlEventTouchUpInside];
//    [self initMoviewPlayer];
    
    [self loadUIWebView];
}
- (void)loadUIWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40, 320, 320)];  //Change self.view.bounds to a smaller CGRect if you don't want it to take up the whole screen
    webView.delegate = self;
    [self.view addSubview:webView];
//    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strVideoLink]]];
   
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)playVedio:(NSURL*)moviePath{
//    mp = [[MPMoviePlayerViewController alloc] initWithContentURL:moviePath];
//    
//    [[mp moviePlayer] prepareToPlay];
//    [[mp moviePlayer] setUseApplicationAudioSession:NO];
//    [[mp moviePlayer] setShouldAutoplay:YES];
//    [[mp moviePlayer] setControlStyle:2];
//    [[mp moviePlayer] setRepeatMode:MPMovieRepeatModeOne];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
//    [self presentMoviePlayerViewControllerAnimated:mp];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnHomeClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    return;
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
- (void) afterInviteFriend{
//    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    ///userid (của người mời), email(của người được mời), tripid
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[userDefault objectForKey:@"userId"] forKey:@"userid"];
    [_params setObject:tfTypingMode.text forKey:@"email"];
    //- Commit ảnh và update data, có input: flag(=1), client_ver, ownerid, photourl, isreceipt(=0,=1), caption, clientid
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'
//    NSString *FileParamConstant = @"";
    
    //Setup request URL
    NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/add_group_users.php",SERVER_LINK]];
    
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
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSLog(@"add into group : %@",dict);
    if (dict != nil) {
        [delegate showAlert:[dict objectForKey:@"message"]];
    }else{
        [delegate showAlert:@"Fail to send your invitation."];
    }
}
- (void) afterClickSendMail{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *kURLString = [NSString stringWithFormat:@"%@/send_link.php",SERVER_LINK];
    NSURL *url = [NSURL URLWithString:kURLString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:tfEmail.text forKey:@"email"];
    [request setPostValue:[userDefault objectForKey:@"userId"] forKey:@"userid"];
    
    //userid (của người mời), email(của người được mời)
    [request setDelegate:self];
    [request startSynchronous];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSError *error = [request error];
    if (!error) {
        NSLog(@"NO error");
        
        NSData *response = [request responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSLog(@"%@",dict);
        if (dict == nil) {
//            [delegate showAlert:@"Server is not connected"];
            return;
        }
        if ([[dict objectForKey:@"success"] intValue] == 0) {
            [delegate showAlert:[dict objectForKey:@"message"]];
        }else{
            [delegate showAlert:[dict objectForKey:@"message"]];
        }
    }
}
- (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

- (void) downloadAndSaveLocal{
    
    NSURL *url = [NSURL URLWithString:strVideoLink];
    NSUInteger location = [strVideoLink rangeOfString:@"slideshow_"].location;
    NSString *fileNameVideoSave= [NSString stringWithFormat:@"video_%d_%@",[[USER_DEFAULT objectForKey:@"userTripId"] intValue], [strVideoLink substringFromIndex:location]];
    NSString *outputFilePath = [FileHelper videoPathForName:fileNameVideoSave];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:outputFilePath];
    [request setDelegate:self];
    [request startAsynchronous];
    
//    [self performSelector:@selector(finishDownloadingSlideshow) withObject:nil afterDelay:1.0];
}
- (void) finishDownloadingSlideshow{
    isDownloading = NO;
    isDownloaded = YES;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
-(void)requestFinished:(ASIHTTPRequest *)request

{
    isDownloading = NO;
    isDownloaded = YES;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [delegate showAlert:@"Download slideshow successful"];
//    [[[UIAlertView alloc] initWithTitle:nil
//                                message:@"Download slideshow successful"
//                               delegate:self
//                      cancelButtonTitle:@"OK"
//                      otherButtonTitles:nil] show];
    
}
- (IBAction)btnSendMailClick:(id)sender {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    [self.view endEditing:YES];
    if (netStatus == NotReachable) {
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
    } else {
        if (isDownloaded) {
            [delegate showAlert:@"This video has already downloaded"];
        }else{
            if (!isDownloading) {
                isDownloading = YES;
                [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
                [self downloadAndSaveLocal];
                
                IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
                @synchronized(self){
                    [sqlManager createTable:@"Slideshow"];
                    [sqlManager saveSlideshow:strVideoLink photo:strImageLink];
                }
            }
        }
    }
}
- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}
- (IBAction)btnInviteFriendClick:(id)sender {
    if ([tfTypingMode.text isEqualToString:@""]) {
        [delegate showAlert:@"Please enter your friend's email"];
        return;
    }
    if (![self validateEmail:tfTypingMode.text]) {
        [delegate showAlert:@"Friend's email is invalid!"];
        return;
    }
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    [self.view endEditing:YES];
    if (netStatus == NotReachable) {
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
        [self afterInviteFriend];
    }
}

- (IBAction)btnPlayVideoClick:(id)sender {
}
//- (void) afterInviteFriend{
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSString *kURLString = [NSString stringWithFormat:@"%@/add_group_users.php",SERVER_LINK];
//    NSURL *url = [NSURL URLWithString:kURLString];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request setPostValue:tfTypingMode.text forKey:@"email"];
//    [request setPostValue:[userDefault objectForKey:@"userId"] forKey:@"userid"];
//    
//    //userid (của người mời), email(của người được mời)
//    [request setDelegate:self];
//    [request startSynchronous];
//    
//    NSError *error = [request error];
//    if (!error) {
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
//    }
//}
#pragma text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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

- (void)actionPauseOrPlay
{
    if (moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        btnPlay.hidden = NO;
        [moviePlayer pause];
    }else{
        btnPlay.hidden = YES;
        [moviePlayer play];
    }
}

#pragma mark initMpMoviewPlayer
- (void)initMoviewPlayer
{
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:strVideoLink]];
    [moviePlayer.view setFrame:CGRectMake(0, 0, 100, 100)];
    [moviePlayer.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [moviePlayer.view setFrame: viewPlayVideo.bounds];
    moviePlayer.repeatMode = MPMovieRepeatModeNone;
    
    moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    moviePlayer.shouldAutoplay = YES;
    [viewPlayVideo addSubview:moviePlayer.view];
    [moviePlayer setFullscreen:YES animated:NO];
    
    moviePlayer.scalingMode = MPMovieScalingModeFill;
    [moviePlayer play];
//    [moviePlayer pause];
    
    [[NSNotificationCenter defaultCenter] addObserver:self // the object listening / "observing" to the notification
                                             selector:@selector(myMovieDidFinishPlay:) // method to call when the notification was pushed
                                                 name:MPMoviePlayerPlaybackDidFinishNotification // notification the observer should listen to
                                               object:moviePlayer];
}

- (void)myMovieDidFinishPlay:(NSNotification*)notification {
    NSLog(@"myMovieDidFinishPlay");
    btnPlay.hidden = NO;
    [moviePlayer pause];
}



@end
