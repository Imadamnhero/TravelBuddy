//
//  SlideShowVC.m
//  Fun Spot App
//
//  Created by MAC on 8/29/14.
//
//

#import "SendSlideShowVC.h"
#import "AsynImageButton.h"
#import "PhotoViewController.h"
#import "BaseNavigationController.h"
#import "ImageGalleryViewController.h"
#import "CreateSlideShowVC.h"
#import "Annotation.h"
#import "PhotoObj.h"
#import "FileHelper.h"
#import "SlideVideo.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NewCellPhoto.h"

@interface SendSlideShowVC (){
    NSString *urlShareSlideShow,*message;
    NSOperationQueue *queueGetPath;
    NSDictionary *dictResult;
    NSMutableArray *mainArray, *arraySavePath;
    AppDelegate *delegate;
}
//Type == 1 is email
//Type == 2 is facebook;
@end

@implementation SendSlideShowVC
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
    float main_top = 0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        main_top = 0;
    }
    btnBack.imageEdgeInsets = UIEdgeInsetsMake(7, 12, 7, 8);
    mainArray = [NSMutableArray array];
    arraySavePath = [NSMutableArray array];
    [mainCollectionView registerNib:[UINib nibWithNibName:@"NewCellPhoto" bundle:nil] forCellWithReuseIdentifier:@"NewCellPhoto"];
    [self getData];
}


- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
//    mainScroll.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40);
//    mainScroll.hidden = NO;
    
    queueGetPath = [[NSOperationQueue alloc]init];
    queueGetPath.name =@"queueGetPathSlideShows";
    dictResult = [NSDictionary dictionary];
}
- (void)getData{
    
    [self scanPath:[FileHelper videoDirectory]];
    if (mainArray.count==0) {
        [delegate showAlert:@"Please create slide show"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else{
        [mainCollectionView reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        mainScroll.backgroundColor = [UIColor grayColor];
//        [self loadVideoSlideShowChooseToSend];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark load all video to scroll view
//load all url video in path
- (void)scanPath:(NSString *) sPath {
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"loading..." animated:YES];
    BOOL isDir;
    mainArray = [NSMutableArray array];
    [[NSFileManager defaultManager] fileExistsAtPath:sPath isDirectory:&isDir];
    if(isDir)
    {
        NSArray *contentOfDirectory=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:sPath error:NULL];
        int contentcount = [contentOfDirectory count];
        int i;
        for(i=0;i<contentcount;i++)
        {
            NSString *fileName = [contentOfDirectory objectAtIndex:i];
            NSString *path = [sPath stringByAppendingFormat:@"%@%@",@"/",fileName];
            
            if([[NSFileManager defaultManager] isDeletableFileAtPath:path])
            {
                NSString *typeFile = [[path componentsSeparatedByString:@"."]lastObject];
                if ([typeFile isEqualToString:@"mp4"]) {
                    NSString *fileNameOfPath = [[path componentsSeparatedByString:@"/"]lastObject];
                    NSString *fileNameIdTrip = [[fileNameOfPath componentsSeparatedByString:@"_"]objectAtIndex:1];
                    int tripValueID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userTripId"];
                    NSString *tripId = [NSString stringWithFormat:@"%i",tripValueID];
                    
                    if ([fileNameIdTrip isEqualToString:tripId]) {
                        SlideVideo *slide = [[SlideVideo alloc]init];
                        NSURL *url = [NSURL fileURLWithPath:path];
                        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
                        
                        UIImage *image = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
                        [slide initData:path choosed:0 thumnail:image];
                        [mainArray addObject:slide];
                        player.pause;
                        player = nil;
                        NSLog(@"fileNameOfPath :%@",fileNameOfPath);
                    }
                    //[self scanPath:path];
                }
            }
        }
    }
    else{
    }
}

- (void) loadVideoSlideShowChooseToSend{
    for (UIView *subView in mainScroll.subviews) {
        [subView removeFromSuperview];
    }
    mainScroll.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-85);
    float x = 0;
    float y = 5;
    mainScroll.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgScrollImages.png"]];
    for (int i = 0; i < mainArray.count; i++) {
        SlideVideo *slide = [mainArray objectAtIndex:i];
        if (i % 3 == 0 ) {
            x = 5;
        }else
            x+= 105;
        y = 105*(i/3)+5;
        
        AsynImageButton *asynImgBtn = [[AsynImageButton alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
        asynImgBtn.tag = TagImage+i;
        [asynImgBtn loadIMageFromImage:slide.thumnail];
        [asynImgBtn addTarget:self action:@selector(chooseVideoTosend:) forControlEvents:UIControlEventTouchUpInside];
        [mainScroll addSubview:asynImgBtn];
        
        UIButton *btnSync = [[UIButton alloc] initWithFrame:CGRectMake(x+40, y+40, 20, 20)];
        [btnSync setImage:[UIImage imageNamed:@"ic_play.png"] forState:UIControlStateNormal];
        btnSync.tag = TagImageClickSync+i;
        [mainScroll addSubview:btnSync];
    }
    [mainScroll setContentSize:CGSizeMake(300, y+105)];
    mainScroll.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void) chooseVideoTosend:(id)sender{
    
    [self.view endEditing:YES];
    UIButton *btn = (UIButton *)sender;
    currentTag = btn.tag - TagImage;
    viewSharing.hidden = NO;
    return;
    
    SlideVideo *slide = [mainArray objectAtIndex:btn.tag-TagImage];
    
    if (slide.choosed == 0) {
        for (SlideVideo *slideVD in mainArray) {
            slideVD.choosed =0;
        }
        slide.choosed=1;
        arraySavePath = [NSMutableArray array];
        [arraySavePath addObject:slide];
    }else{
        for (SlideVideo *slideVD  in mainArray) {
            slideVD.choosed=0;
        }
        arraySavePath = [NSMutableArray array];
    }
    [self loadVideoSlideShowChooseToSend];
}

#pragma mark send to mail

- (void)sendEmail {
    SlideVideo *slide = [arraySavePath objectAtIndex:0];
    NSString *file = [[slide.urlVideo componentsSeparatedByString:@"/"]lastObject];
    NSString *emailTitle = @"Travel buddy share slide show";
    NSString *messageBody = @"Hey, check this out!";
    NSArray *toRecipents = [NSArray arrayWithObject:@" "];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Determine the file name and extension
    //NSArray *filepart = [file componentsSeparatedByString:@"."];
    NSString *filename = [[file componentsSeparatedByString:@"."]objectAtIndex:0];
    NSString *extension = @"mp4";
    
    // Get the resource path and read the file using NSData
    NSData *fileData = [NSData dataWithContentsOfFile:slide.urlVideo];
    
    // Determine the MIME type
    NSString *mimeType;
    if ([extension isEqualToString:@"jpg"]) {
        mimeType = @"image/jpeg";
    } else if ([extension isEqualToString:@"png"]) {
        mimeType = @"image/png";
    } else if ([extension isEqualToString:@"doc"]) {
        mimeType = @"application/msword";
    } else if ([extension isEqualToString:@"ppt"]) {
        mimeType = @"application/vnd.ms-powerpoint";
    } else if ([extension isEqualToString:@"html"]) {
        mimeType = @"text/html";
    } else if ([extension isEqualToString:@"pdf"]) {
        mimeType = @"application/pdf";
    }else if ([extension isEqualToString:@"mp4"]) {
        mimeType = @"application/movie";
    }
    
    // Add attachment
    [mc addAttachmentData:fileData mimeType:mimeType fileName:file];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

#pragma mark mail delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            [self dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            [self dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            [self dismissModalViewControllerAnimated:YES];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            [self dismissModalViewControllerAnimated:YES];
            break;
        default:
            NSLog(@"Result: not sent");
            [self dismissModalViewControllerAnimated:YES];
            break;
    }
    
}




#pragma mark send to facebook
- (IBAction)btnSendFacebookCreateSlideClick:(id)sender {
    [self uploadVideoToServer];
}

- (void)uploadVideoToServer
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Uploading" animated:YES];
    NSString *result =@"";
    NSOperationQueue *queueUpLoad = [[NSOperationQueue alloc]init];
    queueUpLoad.name = @"queueUpLoad";
    [queueUpLoad addOperationWithBlock:^{
        SlideVideo *slide = [arraySavePath objectAtIndex:0];
        
        int userID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        //flag(=1), client_ver, ownerid, photourl, isreceipt(=0,=1), caption, clientid
        NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
        [_params setObject:[NSNumber numberWithInt:userID] forKey:@"user_id"];
        
        NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
        
        // string constant for the post parameter 'file'
        NSString *FileParamConstant = @"slideshow";
        //Setup request URL
        NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/upload_slideshow.php",SERVER_LINK]];
        
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
        NSData *videoData = [NSData dataWithContentsOfFile:slide.urlVideo];
        if (videoData) {
            printf("appending image data\n");
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\'%@\'; filename=\".mp4\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:videoData];
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
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            NSLog(@"Upload Video : %@",dict);
            message = [dict objectForKey:@"message"];
            NSLog(@"=== message : %@",message);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([message isEqualToString:@"Uploaded successful"]) {
                NSString *pathVideo = [dict objectForKey:@"path"];
                urlShareSlideShow = [NSString stringWithFormat:@"%@%@",SERVER_LINK,pathVideo];
                [self shareToFaceBook];
            }else if([message isEqualToString:@"user_id is required"]){
                [delegate showAlert:@"Upload failed"];
            }
        }];
    }];
}
- (void)shareToFaceBook{
    SlideVideo *slideVD = [arraySavePath objectAtIndex:0];
    SLComposeViewController *controller = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
    SLComposeViewControllerCompletionHandler myBlock =
    ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled)
        {
            [delegate showAlert:@"Post failed"];
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [delegate showAlert:@"Post successed"];
            [controller dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    };
    controller.completionHandler =myBlock;
    
    //Adding the Text to the facebook post value from iOS
    [controller setInitialText:@"Travel Buddy Share Slide Show"];
    //Adding the URL to the facebook post value from iOS
    [controller addImage:slideVD.thumnail];
    [controller addURL:[NSURL URLWithString:urlShareSlideShow]];
    //Adding the Text to the facebook post value from iOS
    [self presentViewController:controller animated:YES completion:nil];
    
    
}
- (IBAction)actionSend:(id)sender {
    if (arraySavePath.count==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Travel Buddy" message:@"Please choose video if you want to share it" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }else{
        if (self.type==1) {
            [self sendEmail];
        }else if (self.type==2){
            [self uploadVideoToServer];
        }
    }
}

- (IBAction)backToView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnSendVideoToFBClick:(id)sender {
    
    viewSharing.hidden = YES;
    
    SlideVideo *slide = [mainArray objectAtIndex:currentTag];
    NSUInteger locationSlide = [slide.urlVideo rangeOfString:@"slideshow_"].location;
    NSString *strCurrentSlide = [slide.urlVideo substringFromIndex:locationSlide];
    
    IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
    NSMutableArray *arraySlide = [NSMutableArray array];
    @synchronized(self){
        arraySlide = [sqlManager getSlideshowList:[[USER_DEFAULT objectForKey:@"userTripId"] intValue]]; //[sqlManager getPhotoItems: andReceipt:0];
    }
    NSString *strCurrentSlideDB = @"";
    NSString *strCurrentImageDB = @"";
    for (int i = 0; i < arraySlide.count; i++) {
        SlideShow *objSlide = [arraySlide objectAtIndex:i];
        NSUInteger locationSlideDB = [objSlide.serverUrl rangeOfString:@"slideshow_"].location;
        strCurrentSlideDB = [objSlide.serverUrl substringFromIndex:locationSlideDB];
        if ([strCurrentSlideDB isEqualToString:strCurrentSlide]) {
            strCurrentSlideDB = objSlide.serverUrl;
            strCurrentImageDB = objSlide.photoUrl;
            break;
        }
    }
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    
    
    NSString *tripName = [USER_DEFAULT objectForKey:@"userTripName"];
    //Adding the Text to the facebook post value from iOS
    NSString *strTitle = [NSString stringWithFormat:@"Slide Show - %@",tripName];
    
    NSString *strDes = [NSString stringWithFormat:@"I created a slideshow of my %@ Trip. Watch it now!",tripName];
    //    PhotoObj *objPhoto = [_images objectAtIndex:0];
    //    NSString *strServerLinkImage = [self convertServerLinkImage:objPhoto.urlPhoto];
    // Put together the dialog parameters
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      strTitle, @"name",
                                      @"Created with the Travel Buddy app", @"caption",
                                      strDes, @"description",
                                      strCurrentSlideDB, @"link",
                                      strCurrentImageDB, @"picture",
                                      nil];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:parameter
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  if (error) {
                                                      // An error occurred, we need to handle the error
                                                      // See: https://developers.facebook.com/docs/ios/errors
                                                      NSLog(@"Error publishing story: %@", error.description);
                                                  } else {
                                                      if (result == FBWebDialogResultDialogNotCompleted) {
                                                          // User canceled.
                                                          NSLog(@"User cancelled.");
                                                      } else {
                                                          // Handle the publish feed callback
                                                          NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                          
                                                          if (![urlParams valueForKey:@"post_id"]) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                              
                                                          } else {
                                                              // User clicked the Share button
                                                              NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                              NSLog(@"result %@", result);
                                                          }
                                                      }
                                                  }
                                              }];

    
}

- (IBAction)btnOpenVideoClick:(id)sender {
    SlideVideo *slide = [mainArray objectAtIndex:currentTag];
    NSURL *urlVideo = [NSURL fileURLWithPath:slide.urlVideo];
    [self playVedio:urlVideo];
}

- (IBAction)btnCancelClick:(id)sender {
    viewSharing.hidden = YES;
    
}

- (IBAction)btnSendVideoToEmailClick:(id)sender {
    SlideVideo *slide = [mainArray objectAtIndex:currentTag];
    NSUInteger locationSlide = [slide.urlVideo rangeOfString:@"slideshow_"].location;
    NSString *strCurrentSlide = [slide.urlVideo substringFromIndex:locationSlide];
    
    IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
    NSMutableArray *arraySlide = [NSMutableArray array];
    @synchronized(self){
        arraySlide = [sqlManager getSlideshowList:[[USER_DEFAULT objectForKey:@"userTripId"] intValue]]; //[sqlManager getPhotoItems: andReceipt:0];
    }
    NSString *strCurrentSlideDB = @"";
    for (int i = 0; i < arraySlide.count; i++) {
        SlideShow *objSlide = [arraySlide objectAtIndex:i];
        NSUInteger locationSlideDB = [objSlide.serverUrl rangeOfString:@"slideshow_"].location;
        strCurrentSlideDB = [objSlide.serverUrl substringFromIndex:locationSlideDB];
        if ([strCurrentSlideDB isEqualToString:strCurrentSlide]) {
            strCurrentSlideDB = objSlide.serverUrl;
            break;
        }
    }
    NSString *emailTitle = @"slideshow";
    NSString *tripName = [USER_DEFAULT objectForKey:@"userTripName"];
    
    NSMutableString *body = [NSMutableString string];
    NSString *messageBody = [NSString stringWithFormat:@"I created a video for my %@ trip. Watch it here %@",tripName,strCurrentSlideDB];
    
    [body appendString:messageBody];
    
    NSArray *toRecipents = [NSArray arrayWithObject:@" "];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:body isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    //    [self dismissViewControllerAnimated:YES completion:^{
    [self presentViewController:mc animated:YES completion:^{}];
    //    }];
}

- (IBAction)btnDeleteVideoClick:(id)sender {
    SlideVideo *slide = [mainArray objectAtIndex:currentTag];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if([fileMan fileExistsAtPath:slide.urlVideo isDirectory:nil]) {
        [fileMan removeItemAtPath:slide.urlVideo error: nil];
        [mainArray removeObjectAtIndex:currentTag];
//        [self scanPath:[FileHelper videoDirectory]];
//        [self loadVideoSlideShowChooseToSend];
        [mainCollectionView reloadData];
        viewSharing.hidden = YES;
    }
}
// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
#pragma mark play video
-(void)playVedio:(NSURL*)moviePath{
    mp = [[MPMoviePlayerViewController alloc] initWithContentURL:moviePath];
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:moviePath];
    
    [[mp moviePlayer] prepareToPlay];
    [[mp moviePlayer] setUseApplicationAudioSession:NO];
    [[mp moviePlayer] setShouldAutoplay:YES];
    [[mp moviePlayer] setControlStyle:2];
    [[mp moviePlayer] setRepeatMode:MPMovieRepeatModeNone];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [player pause];
    [self presentMoviePlayerViewControllerAnimated:mp];
    
}

-(void)videoPlayBackDidFinish:(NSNotification*)notification  {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [mp.moviePlayer stop];
    mp = nil;
    //    mainScroll.hidden=YES;
    //    scrollPreviews.hidden=NO;
    [self dismissMoviePlayerViewControllerAnimated];
}

#pragma mark UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return mainArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NewCellPhoto";
    NewCellPhoto *cell = (NewCellPhoto *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"NewCellPhoto" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    SlideVideo *slide = [mainArray objectAtIndex:indexPath.row];
    
    cell.myImage.image = slide.thumnail;
//    cell.myBtnUpLoad.hidden = YES;
    cell.myActivity.hidden = YES;
    [cell.myBtnUpLoad setBackgroundImage:[UIImage imageNamed:@"ic_play.png"] forState:UIControlStateNormal];
    cell.myBtnUpLoad.frame = CGRectMake(42, 42, 20, 20);
    cell.myLblCaption.hidden = YES;
    cell.myImageBg.hidden = YES;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(104, 104);
    return size;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.view endEditing:YES];
    currentTag = indexPath.row;
    viewSharing.hidden = NO;
}

- (NSString*)convertServerLinkImage:(NSString*)LocalLinkImage{
    NSString *strServerLink = @"";
    NSString *strTripId =[NSString stringWithFormat:@"%d",[[USER_DEFAULT objectForKey:@"userTripId"] intValue]];
    strServerLink = [LocalLinkImage substringFromIndex:7+strTripId.length];
    strServerLink = [NSString stringWithFormat:@"%@/images/%@/%@",SERVER_LINK,strTripId,strServerLink];
    return strServerLink;
}
- (IBAction)btnCancelViewSharingClick:(id)sender {
    viewSharing.hidden = YES;
}

@end
