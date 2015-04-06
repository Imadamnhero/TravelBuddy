//
//  SlideShowVC.m
//  Fun Spot App
//
//  Created by MAC on 8/29/14.
//
//

#import "SlideShowVC.h"
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
#import "CellPhoto.h"
#import "NewCellPhoto.h"
#import "SendSlideShowVC.h"

@interface SlideShowVC (){
    NSString *urlShareSlideShow,*message;
    NSOperationQueue *queueGetPath;
    NSDictionary *dictResult;
}

@end

@implementation SlideShowVC
@synthesize mainArray,mainCollectionView;
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
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPress:)];
    longPressGesture.minimumPressDuration = 1.5;
    [mapView addGestureRecognizer:longPressGesture];
    mainArray = [[NSMutableArray alloc] init];
    arrayFilePathVideos = [NSMutableArray array];
    arrayFilePathSaved = [NSMutableArray array];
    btnBack.imageEdgeInsets = UIEdgeInsetsMake(8, 7, 7, 6);
    viewSharing.hidden = YES;
    scrollPreviews.hidden=YES;
    [mainCollectionView registerNib:[UINib nibWithNibName:@"NewCellPhoto" bundle:nil] forCellWithReuseIdentifier:@"NewCellPhoto"];
//    [self getImage];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
    [self performSelector:@selector(getImage) withObject:nil afterDelay:1.0];
    [self removeNoti];
    [self addNoti];
}
-(void)addNoti{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncPhotoSuccess) name:@"syncPhotoSuccess" object:nil];
}
-(void)removeNoti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncPhotoSuccess" object:nil];
}
- (void) syncPhotoSuccess{
    [self getImage];
}
- (void) getImage{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
    [mainArray removeAllObjects];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    @autoreleasepool {
        IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
        NSMutableArray * arrayPhoto = [[NSMutableArray alloc] init];
        @synchronized(self){
            arrayPhoto = [sqlManager getPhotoItems:[[userDefault objectForKey:@"userTripId"] intValue] andReceipt:0];
        }
        for (int i = 0; i < arrayPhoto.count; i++) {
            PhotoObj *obj = [arrayPhoto objectAtIndex:i];
            NSString *strImageName = [Common getFilePath:obj.urlPhoto];
            NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
            UIImage *image = [UIImage imageWithData:pngData];
            CGSize size = CGSizeMake(208, 208);
            UIImage *img = [Common imageWithImage:image scaledToSize:size];
            
            obj.imageThumbnail = img;
            
            [mainArray addObject:obj];
        }
    }
    [mainCollectionView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    [self reloadScrollView];
}

- (IBAction)btnDeleteSlideshowClick:(id)sender {
    SlideVideo *slide = [arrayFilePathVideos objectAtIndex:currentTag];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if([fileMan fileExistsAtPath:slide.urlVideo isDirectory:nil]) {
        [fileMan removeItemAtPath:slide.urlVideo error: nil];
        [arrayFilePathVideos removeAllObjects];
        [self scanPath:[FileHelper videoDirectory]];
        [self loadVideoSlideShow];
        viewSharing.hidden = YES;
    }
}
- (void) reloadScrollView{
    lblInstruction.hidden = YES;
    for (UIView *subView in mainScroll.subviews) {
        [subView removeFromSuperview];
    }
    float x = 0;
    float y = 5;
    @autoreleasepool {
        for (int i = 0; i < mainArray.count; i++) {
            PhotoObj *objPhoto = [[PhotoObj alloc] init];
            objPhoto = [mainArray objectAtIndex:i];
            NSLog(@"URL PHOTO :%@",objPhoto.urlPhoto);
            if (i % 3 == 0 ) {
                x = 5;
            }else
                x+= 105;
            y = 105*(i/3)+5;
            AsynImageButton *asynImgBtn = [[AsynImageButton alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
            asynImgBtn.tag = TagImage+i;
            NSString *strImageName = [Common getFilePath:objPhoto.urlPhoto];
            NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
            UIImage *image = [UIImage imageWithData:pngData];
            
            float tile = image.size.height/image.size.width;
            float newHeight = 100;
            
            float newWidht = 100;
            if (tile > 1) {
                newWidht = newHeight/tile;
                asynImgBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 100 - newWidht/4, 0, 100 - newWidht/4);
            }else{
                newHeight = newWidht*tile;
                asynImgBtn.imageEdgeInsets = UIEdgeInsetsMake(100 - newHeight/4, 0, 100 - newHeight/4, 0);
            }
            
            //        [asynImgBtn loadIMageFromImage:image];
            [asynImgBtn loadIMage:image];
            
            //        [asynImgBtn setImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
            [asynImgBtn addTarget:self action:@selector(pushToGallery:) forControlEvents:UIControlEventTouchUpInside];
            [mainScroll addSubview:asynImgBtn];
            asynImgBtn.backgroundColor = [UIColor grayColor];
            
            UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(x, y+79, 100, 21)];
            lblName.backgroundColor = [UIColor blackColor];
            lblName.textColor = [UIColor whiteColor];
            lblName.text = objPhoto.caption;
            lblName.alpha = 0.6;
            lblName.font = [UIFont boldSystemFontOfSize:12];
            [mainScroll addSubview:lblName];
            
            if (objPhoto.serverId == 0) {
                BOOL isBelongArraySyncing = false;
                for (int i = 0; i < delegate.arrayPhotoSyncing.count; i++) {
                    PhotoObj *photoObj = [delegate.arrayPhotoSyncing objectAtIndex:i];
                    if (photoObj.photoId == objPhoto.photoId) {
                        isBelongArraySyncing = true;
                        break;
                    }
                }
                
                if (isBelongArraySyncing) {
                    UIActivityIndicatorView *actIn = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(x+35,y+35, 30, 30)];
                    [actIn startAnimating];
                    [mainScroll addSubview:actIn];
                }else{
                    UIButton *btnSync = [[UIButton alloc] initWithFrame:CGRectMake(x+69, y+2, 28, 28)];
                    [btnSync setImage:[UIImage imageNamed:@"ic_upload.png"] forState:UIControlStateNormal];
                    [btnSync setImage:[UIImage imageNamed:@"ic_upload_clicked.png"] forState:UIControlStateHighlighted];
                    btnSync.tag = TagImageClickSync+i;
                    [btnSync addTarget:self action:@selector(syncPhoto:) forControlEvents:UIControlEventTouchUpInside];
                    [mainScroll addSubview:btnSync];
                    lblInstruction.hidden = NO;
                }
            }
            
        }
    }
    
    [mainScroll setContentSize:CGSizeMake(300, y+125)];
    mainScroll.layer.borderColor = [UIColor darkGrayColor].CGColor;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    scrollChooseVideo.frame = CGRectMake(0, self.view.frame.size.height, scrollChooseVideo.frame.size.width, scrollChooseVideo.frame.size.height);
    mainScroll.hidden = NO;
    scrollChooseVideo.hidden=YES;
//    scrollPreviews.hidden=YES;
    btnDone.hidden=YES;
    viewSharing.hidden=YES;
    queueGetPath = [[NSOperationQueue alloc]init];
    queueGetPath.name =@"queueGetPathSlideShows";
    dictResult = [NSDictionary dictionary];
}

- (void)mapLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint touchLocation = [gestureRecognizer locationInView:mapView];
        
        CLLocationCoordinate2D coordinate;
        coordinate = [mapView convertPoint:touchLocation toCoordinateFromView:mapView];// how to convert this to a String or something else?
        NSLog(@"Longpress");
    }
}

// Show location Sanfrancisco
- (void)showUserLocation
{
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.02;
	span.longitudeDelta=0.02;
	
	CLLocationCoordinate2D location;
	location.latitude = 37.774929500000000000;
	location.longitude = -122.419415500000010000;
	
	region.span=span;
	region.center=location;
	
	Annotation *ann = [[Annotation alloc] init];
	ann.title =  @"";
    
	ann.subtitle = @"";
	ann.coordinate = region.center;
	[mapView addAnnotation:ann];
	
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
}
- (void)mapView:(MKMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{
    NSLog(@"%f",coordinate.latitude);
    NSLog(@"%f",coordinate.longitude);
}
-(void) afterClickSyncPhoto:(PhotoObj*)obj withTag:(NSIndexPath*)indexPath{
    NSLog(@"obj.caption :%@",obj.caption);
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    VersionObj *objVersion = [[VersionObj alloc] init];
    int photoIdDeleted = -1;
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
    }
    
    if (obj.flag == 0) {
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    //flag(=1), client_ver, ownerid, photourl, isreceipt(=0,=1), caption, clientid
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[NSNumber numberWithInt:obj.photoId] forKey:@"clientid"];
    [_params setObject:[NSNumber numberWithInt:objVersion.photoVersion] forKey:@"client_ver"];
    [_params setObject:[NSNumber numberWithInt:obj.ownerUserId] forKey:@"ownerid"];
    [_params setObject:[NSNumber numberWithInt:obj.flag] forKey:@"flag"];
    if (obj.flag == 3) {
        photoIdDeleted = obj.photoId;
        [_params setObject:[NSNumber numberWithInt:obj.serverId] forKey:@"serverid"];
    }else{
        [_params setObject:obj.caption forKey:@"caption"];
        [_params setObject:[NSNumber numberWithInt:obj.isReceipt] forKey:@"isreceipt"];
    }
    //- Commit ảnh và update data, có input: flag(=1), client_ver, ownerid, photourl, isreceipt(=0,=1), caption, clientid
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'
    NSString *FileParamConstant = @"";
    if (obj.flag != 3)
        FileParamConstant = @"photourl";
    
    //Setup request URL
    NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/sync_photo.php",SERVER_LINK]];
    
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
    if (obj.flag != 3) {
        // add image data
        NSString *strImageName = [Common getFilePath:obj.urlPhoto];
        NSData *imageData = [NSData dataWithContentsOfFile:strImageName];
        if (imageData) {
            printf("appending image data\n");
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\'%@\'; filename=\"images.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
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
    NSLog(@"sync photo : %@",dict);
    NewCellPhoto *cell = (NewCellPhoto *)[mainCollectionView cellForItemAtIndexPath:indexPath];
    if ([[dict objectForKey:@"success"] intValue] == 0) {
        cell.myBtnUpLoad.hidden = NO;
        cell.myActivity.hidden  = YES;
        if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
//            [delegate showAlert:[dict objectForKey:@"message"]];
        }
    }else{
        //update expense version in table Versions
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Main thread work (UI usually)
            @synchronized(self)
            {
                int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                objVersion.photoVersion = newVersion;
                [sqliteManager updateVersion:objVersion];
            }
        }];
        
        //update information for record in local which updated on server
        NSDictionary *dictCommitted = [dict objectForKey:@"committed_id"];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Main thread work (UI usually)
            @synchronized(self)
            {
                int clientId = [[dictCommitted objectForKey:@"clientid"] intValue];
                int serverId = [[dictCommitted objectForKey:@"serverid"] intValue];
                [Common removeImage:obj.urlPhoto];
                if (photoIdDeleted >0) {
                    NSLog(@"delete image");
                    [sqliteManager deletePhoto:clientId];
                }else{
                    NSString *imageName = [[dictCommitted objectForKey:@"photourl"] stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    [sqliteManager updatePhotoFromServer:clientId withServerId:serverId];
                    [Common saveImageToLocal:[dictCommitted objectForKey:@"photourl"]];
                    [sqliteManager updatePhotoUrlFromServer:clientId withPhotoUrl:imageName];
                    obj.serverId = serverId;
                    obj.urlPhoto = imageName;
                    
                    for (int i = 0; i < delegate.arrayPhotoSyncing.count; i++) {
                        PhotoObj *photoObj = [delegate.arrayPhotoSyncing objectAtIndex:i];
                        if (photoObj.photoId == clientId) {
                            [delegate.arrayPhotoSyncing removeObject:photoObj];
                        }
                    }
                }
            }
            cell.myActivity.hidden  = YES;
        }];
        
//        //get array updated from sever
//        NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
//        arrayUpdateData = [dict objectForKey:@"updated_data"];
//        for (int j = 0 ; j < arrayUpdateData.count; j++) {
//            PhotoObj *objPhoto = [[PhotoObj alloc] init];
//            NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
//            
//            objPhoto.caption  = [dictResponse objectForKey:@"caption"];
//            NSString *imageName = [[dictResponse objectForKey:@"photourl"] stringByReplacingOccurrencesOfString:@"/" withString:@""];
//            objPhoto.urlPhoto = imageName;
//            objPhoto.isReceipt = [[dictResponse objectForKey:@"isreceipt"] intValue];
//            objPhoto.tripId = [[dictResponse objectForKey:@"tripid"] intValue];
//            objPhoto.ownerUserId = [[dictResponse objectForKey:@"ownerid"] intValue];
//            objPhoto.serverId    = [[dictResponse objectForKey:@"serverid"] intValue];
//            objPhoto.flag        = 0;
//            
//            if ([[dictResponse objectForKey:@"flag"] intValue] == 1) {
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    // Main thread work (UI usually)
//                    @synchronized(self)
//                    {
//                        [sqliteManager addPhotoInfor:objPhoto];
//                        [Common saveImageToLocal:[dictResponse objectForKey:@"photourl"]];
//                    }
//                }];
//            }
//        }
    }
}

-(void) syncPhoto:(id)sender{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
    }else{
        UIButton *btn = (UIButton *)sender;
        btn.hidden = YES;
        int tag = btn.tag - TagImageClickSync;
        for (UIView *subView in mainScroll.subviews) {
            if (subView.tag == (tag + TagImage)) {
                UIActivityIndicatorView *actIn = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(subView.frame.origin.x+35, subView.frame.origin.y+35, 30, 30)];
                [actIn startAnimating];
                actIn.tag = TagActIn + tag;
                [mainScroll addSubview:actIn];
            }
        }
        //Get current Photo which want to update
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj = [mainArray objectAtIndex:tag];
        [delegate.arrayPhotoSyncing addObject:obj];
        [delegate.myQueue addOperationWithBlock:^{
            
            // Background work
//            [self afterClickSyncPhoto:obj withTag:(TagActIn + tag)];
        }];
    }
    
}
// push to gallery
-(void) pushToGallery:(id)sender{
    UIButton *btn = (UIButton *)sender;
    ImageGalleryViewController *imageGallery = [[ImageGalleryViewController alloc] initWithNibName:@"ImageGalleryViewController" bundle:nil parent:self];
    self.navigationItem.title =@"Back";
    imageGallery.isSlideshow = true;
    [[self navigationController] pushViewController:imageGallery animated:YES];
    imageGallery.indexImage = btn.tag - TagImage;
    
    return;
    
    //===========================================
    PhotoViewController *pageZero = [PhotoViewController photoViewControllerForPageIndex:0 withArray:mainArray];
    //    if (pageZero != nil) {
    // assign the first page to the pageViewController (our rootViewController)
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageViewController.dataSource = self;
    pageViewController.automaticallyAdjustsScrollViewInsets = NO;
    
    [pageViewController setViewControllers:@[pageZero]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:NULL];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pageViewController];
    pageZero.title =@"Gallery";
    
    pageViewController.navigationItem.title  = @"Gallery";
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissScreen:)];
    pageViewController.navigationItem.rightBarButtonItem = doneBtn;
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    //    }
}
- (void)dismissScreen :(id)sender{
    //    [self.mapView setDelegate:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnHomeClick:(id)sender {
    if (self.itemsView.hidden) {
        [self.view bringSubviewToFront:self.itemsView];
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

- (IBAction)btnCreateClick:(id)sender {
    if (mainArray.count==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Travel Buddy" message:@"Please add photo to create slide show" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else{
        scrollPreviews.hidden = YES;
        mainScroll.hidden = NO;
        CreateSlideShowVC *createVC = [[CreateSlideShowVC alloc]initWithNibName:@"CreateSlideShowVC" bundle:nil];
        createVC.arrayImages = [mainArray copy];
        [self.navigationController pushViewController:createVC animated:YES];
    }
}
-(void)createSlideShow{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    subViewCreateSlide.hidden = NO;
}
#pragma mark preview in here
- (IBAction)btnPreviewClick:(id)sender {
    SendSlideShowVC *sendSlide = [[SendSlideShowVC alloc]init];
    [self.navigationController pushViewController:sendSlide animated:YES];
    return;
    
    arrayFilePathVideos = [NSMutableArray array];
    
    [self scanPath:[FileHelper videoDirectory]];
    if (arrayFilePathVideos.count==0) {
        [delegate showAlert:@"Please create slide show"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else{
        
//        CGRect scroll = mainScroll.frame;
//        scroll.origin.x += 330;
//        mainScroll.frame =scroll;
        
        btnBack.hidden = NO;
        btnHome.hidden = YES;
        scrollPreviews.frame = mainScroll.frame;
        mainScroll.hidden = YES;
        scrollPreviews.hidden=NO;
        scrollChooseVideo.hidden=YES;
        btnDone.hidden=YES;
        scrollPreviews.backgroundColor = [UIColor grayColor];
        [self loadVideoSlideShow];
    }
}
#pragma mark load all video to scroll view
//load all url video in path
- (void)scanPath:(NSString *) sPath {
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"loading..." animated:YES];
        BOOL isDir;
        arrayFilePathVideos = [NSMutableArray array];
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
                            [arrayFilePathVideos addObject:slide];
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
- (void) loadVideoSlideShow{
    for (UIView *subView in scrollPreviews.subviews) {
        [subView removeFromSuperview];
    }
    float x = 0;
    float y = 5;
    for (int i = 0; i < arrayFilePathVideos.count; i++) {
        SlideVideo *slide = [arrayFilePathVideos objectAtIndex:i];
        slide.choosed=0;
        if (i % 3 == 0 ) {
            x = 5;
        }else
            x+= 105;
        y = 105*(i/3)+5;
        
        AsynImageButton *asynImgBtn = [[AsynImageButton alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
        asynImgBtn.tag = TagImage+i;
        [asynImgBtn loadIMageFromImage:slide.thumnail];
        [asynImgBtn addTarget:self action:@selector(previewVideoSlideShow:) forControlEvents:UIControlEventTouchUpInside];
        [scrollPreviews addSubview:asynImgBtn];
        UIButton *btnSync = [[UIButton alloc] initWithFrame:CGRectMake(x+40, y+40, 20, 20)];
        [btnSync setImage:[UIImage imageNamed:@"ic_play.png"] forState:UIControlStateNormal];
        btnSync.tag = TagImageClickSync+i;
        [scrollPreviews addSubview:btnSync];
//        btnSync.hidden=YES;
        
        // attach long press gesture to collectionView
//        UILongPressGestureRecognizer *lpgr
//        = [[UILongPressGestureRecognizer alloc]
//           initWithTarget:self action:@selector(handleLongPress:)];
//        lpgr.minimumPressDuration = .5; //seconds
//        lpgr.delegate = self;
//        [asynImgBtn addGestureRecognizer:lpgr];
    }
    [scrollPreviews setContentSize:CGSizeMake(300, y+105)];
    scrollPreviews.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    viewSharing.hidden = NO;
}
- (void) loadVideoSlideShowChooseToSend{
    
    for (UIView *subView in scrollChooseVideo.subviews) {
        [subView removeFromSuperview];
    }
    float x = 0;
    float y = 5;
    scrollChooseVideo.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgScrollImages.png"]];
    for (int i = 0; i < arrayFilePathVideos.count; i++) {
        SlideVideo *slide = [arrayFilePathVideos objectAtIndex:i];
        if (i % 3 == 0 ) {
            x = 5;
        }else
            x+= 105;
        y = 105*(i/3)+5;
        
        AsynImageButton *asynImgBtn = [[AsynImageButton alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
        asynImgBtn.tag = TagImage+i;
        [asynImgBtn loadIMageFromImage:slide.thumnail];
        [asynImgBtn addTarget:self action:@selector(chooseVideoTosend:) forControlEvents:UIControlEventTouchUpInside];
        [scrollChooseVideo addSubview:asynImgBtn];
        
        UIButton *btnSync = [[UIButton alloc] initWithFrame:CGRectMake(x+80, y+2, 20, 23)];
        [btnSync setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        btnSync.tag = TagImageClickSync+i;
        [scrollChooseVideo addSubview:btnSync];
        if (slide.choosed == 0) {
            btnSync.hidden=YES;
        }
        else
            btnSync.hidden=NO;
    }
    [scrollChooseVideo setContentSize:CGSizeMake(300, y+105)];
    scrollChooseVideo.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void) chooseVideoTosend:(id)sender{
    
    [self.view endEditing:YES];
    UIButton *btn = (UIButton *)sender;
    SlideVideo *slide = [arrayFilePathVideos objectAtIndex:btn.tag-TagImage];
    
    if (slide.choosed == 0) {
        for (SlideVideo *slideVD in arrayFilePathVideos) {
            slideVD.choosed =0;
        }
        slide.choosed=1;
        arrayFilePathSaved = [NSMutableArray array];
        [arrayFilePathSaved addObject:slide];
    }else{
        for (SlideVideo *slideVD  in arrayFilePathVideos) {
            slideVD.choosed=0;
        }
        arrayFilePathSaved = [NSMutableArray array];
    }
    [self loadVideoSlideShowChooseToSend];
}

-(void) previewVideoSlideShow:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    currentTag = btn.tag-TagImage;
    viewSharing.hidden = NO;
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


#pragma mark send email
- (IBAction)btnSendSlideShowClick:(id)sender {
    //scrollChooseVideo.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-81);
    NSString *stringPath = [FileHelper videoDirectory];
    [self scanPath:stringPath];
    if (arrayFilePathVideos.count==0) {
        [delegate showAlert:@"Please create slide show"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else{
        [self loadVideoSlideShowChooseToSend];
        mainScroll.hidden = YES;
        scrollPreviews.hidden=YES;
        scrollChooseVideo.hidden=NO;
        btnDone.hidden=YES;
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            scrollChooseVideo.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-81);
            btnDone.hidden=NO;
        } completion:nil];
    }
}

- (IBAction)btnBackClick:(id)sender {
    btnBack.hidden = YES;
    btnHome.hidden = NO;
    scrollPreviews.hidden=YES;
    mainScroll.hidden = NO;
//    [self performSelector:@selector(resetMainScroll) withObject:nil afterDelay:1.0];
}
- (void) resetMainScroll{
    CGRect scroll = mainScroll.frame;
    scroll.origin.x = 0;
    mainScroll.frame =scroll;
}
- (void)showEmail:(NSString*)file {
    SlideVideo *slide = [arrayFilePathSaved objectAtIndex:0];
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
            [delegate showAlert:@"Canceled"];
            break;
        case MFMailComposeResultSaved:
            [delegate showAlert:@"Saved"];
            break;
        case MFMailComposeResultSent:
            [delegate showAlert:@"Sent"];
            NSLog(@"Result: Sent");
            break;
        case MFMailComposeResultFailed:
            [delegate showAlert:@"Failed"];
            NSLog(@"Result: failed");
            break;
        default:
            [delegate showAlert:@"Not Sent"];
            NSLog(@"Result: not sent");
            break;
    }
    arrayFilePathSaved = [NSMutableArray array];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark action done choose video to send
- (IBAction)actionDoneChooseVideo:(id)sender {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        scrollChooseVideo.frame = CGRectMake(0, self.view.frame.size.height, scrollChooseVideo.frame.size.width, scrollChooseVideo.frame.size.height);
        btnDone.hidden=YES;
        [viewSharing bringSubviewToFront:self.view];
        if (arrayFilePathSaved.count>0) {
            viewSharing.hidden=NO;
            mainScroll.hidden=NO;
        }else{
            viewSharing.hidden=YES;
            mainScroll.hidden=NO;
        }
    } completion:nil];
}
//method of sub view create slide show

- (IBAction)btnCancelClick:(id)sender {
    viewSharing.hidden = YES;
    arrayFilePathSaved = [NSMutableArray array];
}

#pragma mark send to twitter
- (IBAction)sendToTwitter:(id)sender {
    SlideVideo *slide = [arrayFilePathVideos objectAtIndex:currentTag];
    NSURL *urlVideo = [NSURL fileURLWithPath:slide.urlVideo];
    [self playVedio:urlVideo];
}

#pragma mark send to mail
- (IBAction)btnSendMailCreateSlideClick:(id)sender {
    
//    SlideVideo *slide = [arrayFilePathSaved objectAtIndex:0];
//    NSString *fileName = [[slide.urlVideo componentsSeparatedByString:@"/"]lastObject];
//    [self showEmail:fileName];
    
    SlideVideo *slide = [arrayFilePathVideos objectAtIndex:currentTag];
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

#pragma mark send to facebook
- (IBAction)btnSendFacebookCreateSlideClick:(id)sender {
    viewSharing.hidden = YES;
    
    SlideVideo *slide = [arrayFilePathVideos objectAtIndex:currentTag];
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

- (void)uploadVideoToServer
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Uploading" animated:YES];
    NSString *result =@"";
    NSOperationQueue *queueUpLoad = [[NSOperationQueue alloc]init];
    queueUpLoad.name = @"queueUpLoad";
    [queueUpLoad addOperationWithBlock:^{
        SlideVideo *slide = [arrayFilePathSaved objectAtIndex:0];
        
        int userID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        //flag(=1), client_ver, ownerid, photourl, isreceipt(=0,=1), caption, clientid
        NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
        [_params setObject:[NSNumber numberWithInt:userID] forKey:@"user_id"];
        
        
        //- Commit ảnh và update data, có input: flag(=1), client_ver, ownerid, photourl, isreceipt(=0,=1), caption, clientid
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
    
    
    //    if ([[[dict objectForKey:@"message"]stringValue] isEqualToString:@"uploaded successfully"]) {
    //        NSString *pathVideo = [[dict objectForKey:@"path"]stringValue];
    //        urlShareSlideShow = [NSString stringWithFormat:@"%@%@",SERVER_LINK,pathVideo];
    //        [self shareToFaceBook];
    //    }else{
    //
    //    }
}
#pragma mark - Share Link to Facebook

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
- (void)shareToFaceBook{
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    // Show the feed dialog
//    [FBWebDialogs presentFeedDialogModallyWithSession:nil
//                                           parameters:params
//                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//                                                  if (error) {
//                                                      // An error occurred, we need to handle the error
//                                                      // See: https://developers.facebook.com/docs/ios/errors
//                                                      NSLog(@"Error publishing story: %@", error.description);
//                                                  } else {
//                                                      if (result == FBWebDialogResultDialogNotCompleted) {
//                                                          // User canceled.
//                                                          NSLog(@"User cancelled.");
//                                                      } else {
//                                                          // Handle the publish feed callback
//                                                          NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
//                                                          
//                                                          if (![urlParams valueForKey:@"post_id"]) {
//                                                              // User canceled.
//                                                              NSLog(@"User cancelled.");
//                                                              
//                                                          } else {
//                                                              // User clicked the Share button
//                                                              NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
//                                                              NSLog(@"result %@", result);
//                                                          }
//                                                      }
//                                                  }
//                                              }];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        NSString *tripName = [USER_DEFAULT objectForKey:@"userTripName"];
        //Adding the Text to the facebook post value from iOS
        NSString *strTitle = [NSString stringWithFormat:@"Slide Show - %@",tripName];
        
        NSString *strDes = [NSString stringWithFormat:@"I created a video from photo which i have in %@. Watch it now!",tripName];
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       strTitle, @"name",
                                       @"Travel Buddy", @"caption",
                                       strDes, @"description",
                                       urlShareSlideShow, @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
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
    
    // end
    return;
    
    
    SlideVideo *slideVD = [arrayFilePathSaved objectAtIndex:0];
    SLComposeViewController *controller = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
    SLComposeViewControllerCompletionHandler myBlock =
    ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled)
        {
            [delegate showAlert:@"Post failed"];
            
        }
        else
        {
            [delegate showAlert:@"Post successed"];
        }
        mainScroll.hidden=NO;
        viewSharing.hidden=YES;
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    controller.completionHandler =myBlock;
    NSString *tripName = [USER_DEFAULT objectForKey:@"userTripName"];
    //Adding the Text to the facebook post value from iOS
    NSString *strTitle = [NSString stringWithFormat:@"Slide Show - %@",tripName];
    
    //Adding the URL to the facebook post value from iOS
    [controller addImage:slideVD.thumnail];
    [controller addURL:[NSURL URLWithString:urlShareSlideShow]];
    [controller setTitle:strTitle];
    [controller setInitialText:[NSString stringWithFormat:@"I created a video from pictures which i have in %@. Watch it now!",tripName]];
//    controller.description = [NSString stringWithFormat:@"I created an video from pictures which i have in %@. Watch it now!",tripName];
    //Adding the Text to the facebook post value from iOS
    arrayFilePathSaved = [NSMutableArray array];
    [self presentViewController:controller animated:YES completion:nil];
    
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
    
    PhotoObj *objPhoto = [[PhotoObj alloc] init];
    objPhoto = [mainArray objectAtIndex:indexPath.row];
    
    cell.myImage.image = objPhoto.imageThumbnail;
    cell.myLblCaption.text = objPhoto.caption;
    cell.myBtnUpLoad.hidden = YES;
    cell.myActivity.hidden = YES;
    [cell.myBtnUpLoad addTarget:self action:@selector(synsPhoto:) forControlEvents:UIControlEventTouchUpInside];
    if (objPhoto.serverId == 0) {
        BOOL isBelongArraySyncing = false;
        for (int i = 0; i < delegate.arrayPhotoSyncing.count; i++) {
            PhotoObj *photoObj = [delegate.arrayPhotoSyncing objectAtIndex:i];
            if (photoObj.photoId == objPhoto.photoId) {
                isBelongArraySyncing = true;
                break;
            }
        }
        
        if (isBelongArraySyncing) {
            cell.myActivity.hidden = NO;
            [cell.myActivity startAnimating];
        }else{
            cell.myBtnUpLoad.hidden = NO;
            lblInstruction.hidden = NO;
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(104, 104);
    return size;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageGalleryViewController *imageGallery = [[ImageGalleryViewController alloc] initWithNibName:@"ImageGalleryViewController" bundle:nil parent:self];
    self.navigationItem.title =@"Back";
    imageGallery.isSlideshow = true;
    [[self navigationController] pushViewController:imageGallery animated:YES];
    imageGallery.indexImage = indexPath.row;
}

- (IBAction)synsPhoto:(id)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:mainCollectionView];
    NSIndexPath *indexPath = [mainCollectionView indexPathForItemAtPoint:touchPoint];
    
    NewCellPhoto *cell = (NewCellPhoto *)[mainCollectionView cellForItemAtIndexPath:indexPath];
    cell.myBtnUpLoad.hidden = YES;
    cell.myActivity.hidden  = NO;
    [cell.myActivity startAnimating];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
    }else{
        NewCellPhoto *cell = (NewCellPhoto *)[mainCollectionView cellForItemAtIndexPath:indexPath];
        cell.myBtnUpLoad.hidden = YES;
        cell.myActivity.hidden  = NO;
        [cell.myActivity startAnimating];
        
        //Get current Photo which want to update
        PhotoObj *obj = [mainArray objectAtIndex:indexPath.row];
        [delegate.arrayPhotoSyncing addObject:obj];
        [delegate.myQueue addOperationWithBlock:^{
            // Background work
            [self afterClickSyncPhoto:obj withTag:indexPath];
        }];
    }
}

@end
