//
//  ImageGalleryViewController.m
//  Funpot App
//
//  Created by Pradeep Sundriyal on 01/10/12.
//
//

#import "ImageGalleryViewController.h"
//#import "ANIPlaceService.h"
#import "IMSSqliteManager.h"
#import "PhotoObj.h"
#import "SlideShowVC.h"
#import "ReceiptVC.h"

#define kConfigPlistName @"config"


@interface ImageGalleryViewController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    NSOperationQueue *myQueee;
}

@end

@implementation ImageGalleryViewController
@synthesize scrollView,pageControl;
@synthesize currentPage,isSlideshow,indexImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"", @"imagegallerytitle");
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"", @"imagegallerytitle");
        // Custom initialization
        parent = _parent;
    }
    return self;
}

- (void) initUI{
    [scrView setBackgroundColor:[UIColor clearColor]];
    [scrView setCanCancelContentTouches:NO];
    
    scrView.clipsToBounds = YES; // default is NO, we want to restrict drawing within our scrollview
    scrView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [scrView setContentSize:CGSizeMake(myImageView.frame.size.width, myImageView.frame.size.height)];
    scrView.maximumZoomScale = 2.0f;
    scrView.minimumZoomScale = 1.0f;
//    OLDContent_width = scrView.contentSize.width;
//    OLDContent_height = scrView.contentSize.height;
    
    scrView.delegate = self;
    [scrView setScrollEnabled:YES];
    [scrView addSubview:myImageView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.title = [delegate.funSpotDict valueForKey:@"gallery"];
    [self initUI];
    
    IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];

    @synchronized(self){
        if(delegate.isUpdateAvailableForGallery){
        [sqlManager clearGalleryContent];
        }
    }

    @synchronized(self){
        [self loadImagesAndAddToScrollView];
    }

    UIColor *colornav = [UIColor colorWithHexString:(self.appDelagte.funSpotDict)[@"color_nav"]];
    if(!colornav) colornav = COLOR_NAV;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationController.navigationBar.barTintColor = colornav;
    } else {
        self.navigationController.navigationBar.tintColor = colornav;
    }
    
    UIColor *colorbg = [UIColor colorWithHexString:(delegate.funSpotDict)[@"color_bg"]];
    if(!colorbg) colorbg = [UIColor darkGrayColor];
    self.view.backgroundColor = colorbg;
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self loadImagesAndAddToScrollView];
    [super viewWillAppear:YES];
}

- (NSMutableArray*)getImage:(int)isReceipt{
    NSMutableArray *galleryImgArr = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
    @synchronized(self){
        galleryImgArr = [sqlManager getPhotoItems:[[userDefault objectForKey:@"userTripId"] intValue] andReceipt:isReceipt];
    }
    return galleryImgArr;
}
- (void) syncPhoto{
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    VersionObj *objVersion = [[VersionObj alloc] init];
    int photoIdDeleted = -1;
    @synchronized(self)
    {
        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
    }
    //Get current Photo which want to update
    PhotoObj *obj = [[PhotoObj alloc] init];
    obj = [mainArray objectAtIndex:indexImage];
    
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
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\'%@\'; filename=\"images.png\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
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
    if ([[dict objectForKey:@"success"] intValue] == 0) {
        if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
            //                    [delegate showAlert:[dict objectForKey:@"message"]];
        }
    }else{
        //update expense version in table Versions
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(self)
            {
                int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                objVersion.photoVersion = newVersion;
                [sqliteManager updateVersion:objVersion];
            }
        });
        
        //update information for record in local which updated on server
        NSDictionary *dictCommitted = [dict objectForKey:@"committed_id"];
        dispatch_async(dispatch_get_main_queue(), ^{
//            @synchronized(self)
//            {
                int clientId = [[dictCommitted objectForKey:@"clientid"] intValue];
                int serverId = [[dictCommitted objectForKey:@"serverid"] intValue];
                [Common removeImage:obj.urlPhoto];
                if (photoIdDeleted >0) {
                    NSLog(@"delete image");
                    @synchronized(self)
                    {
                        [sqliteManager deletePhoto:clientId];
                    }
                    
                }else{
                    NSString *imageName = [[dictCommitted objectForKey:@"photourl"] stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    @synchronized(self)
                    {
                        [sqliteManager updatePhotoFromServer:clientId withServerId:serverId];
                        [sqliteManager updatePhotoUrlFromServer:clientId withPhotoUrl:imageName];
                    }
                    [Common saveImageToLocal:[dictCommitted objectForKey:@"photourl"]];
                }
//            }
        });
    }
}
//Loading all the images Asynchronously
- (IBAction)SyncPhotoClick:(id)sender {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // sync data
        [self syncPhoto];
    });
    
}

-(void)loadImagesAndAddToScrollView{

    NSMutableArray *galleryImgArr = [[NSMutableArray alloc] init];
    //Get all images from database
    if (isSlideshow) {
        galleryImgArr = [self getImage:0];
    }else{
        galleryImgArr = [self getImage:1];
    }
    
    mainArray = [galleryImgArr mutableCopy];
    
    if([galleryImgArr count] > 0){
        UISwipeGestureRecognizer *leftswipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeRecognizer:)];
        leftswipe.delegate = self;
        leftswipe.direction = UISwipeGestureRecognizerDirectionLeft;
        
        UISwipeGestureRecognizer *rightswipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeRecognizer:)];
        rightswipe.delegate = self;
        rightswipe.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self.view addGestureRecognizer: leftswipe];
        [self.view addGestureRecognizer: rightswipe];
        
        myQueee = [[NSOperationQueue alloc]init];
        myQueee.name = @"QueeImage";
        [myQueee addOperationWithBlock:^{
            PhotoObj *obj = [galleryImgArr objectAtIndex:indexImage];
            lblDescibeImage.text = obj.caption;
            NSString *strImageName = [Common getFilePath:obj.urlPhoto];
            NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                UIImage *img=[[UIImage alloc] initWithData:pngData];
                [myImageView setImage:img];
            }];
        }];
    }
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSLog(@"== size :%f , %f",myImageView.frame.size.width,myImageView.frame.size.height);
    return myImageView;
}
#pragma mark Geture Swipe
- (void) SwipeRecognizer:(UISwipeGestureRecognizer *)sender
{
    CGAffineTransform rotation = CGAffineTransformMakeRotation(1 ? 0 : M_PI);
    myViewContain.transform = CGAffineTransformScale(rotation,1, 1);
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft )
    {
        NSLog(@"  SWIPE LEFT ");
        
        if (indexImage+1 < mainArray.count) {
            indexImage++;
            
            [myQueee addOperationWithBlock:^{
                PhotoObj *photoObj= mainArray[indexImage];
//                pathPhoto = strPath;
//                NSURL *targetURL = [NSURL fileURLWithPath:strPath];
                NSString *strImageName = [Common getFilePath:photoObj.urlPhoto];
                NSData *returnData=[NSData dataWithContentsOfFile:strImageName];
                UIImage *img=[[UIImage alloc] initWithData:returnData];
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [myImageView setImage:img];
                    lblDescibeImage.text = photoObj.caption;
                    
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.5;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionMoveIn;
                    transition.subtype =kCATransitionFromRight;
                    transition.delegate = self;
//                    imageDefault = img;
                    [myImageView.layer addAnimation:transition forKey:nil];
//                    sizePhotoDefault = myViewContain.frame.size.width;
                }];
            }];
        }
    }
    if ( sender.direction == UISwipeGestureRecognizerDirectionRight ){
        NSLog(@"  SWIPE RIGHT ");
        if (indexImage-1 >= 0) {
            indexImage--;
            
            [myQueee addOperationWithBlock:^{
                PhotoObj *photoObj= mainArray[indexImage];
//                pathPhoto = strPath;
                NSString *strImageName = [Common getFilePath:photoObj.urlPhoto];
                NSData *returnData=[NSData dataWithContentsOfFile:strImageName];
                UIImage *img=[[UIImage alloc] initWithData:returnData];
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    
                    [myImageView setImage:img];
                    lblDescibeImage.text = photoObj.caption;
                    
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.5;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionMoveIn;
                    transition.subtype =kCATransitionFromLeft;
                    transition.delegate = self;
//                    imageDefault = img;
                    [myImageView.layer addAnimation:transition forKey:nil];
//                    sizePhotoDefault = myViewContain.frame.size.width;
                }];
            }];
        }
    }
}


- (void) didFinishDownload:(NSNumber*)idx {
    
//    if ([downloads dataAsImageAtIndex:[idx intValue]]) {
//        delegate.isUpdateAvailableForGallery = NO;
//
//        UIImage *image = [downloads dataAsImageAtIndex:[idx intValue]];
//        float width = image.size.width;
//        float height = image.size.height;
//        
//        float newWidht = 320;
//        float newheightFloat = roundf(newWidht*height/width);
//        int newHeight = newheightFloat;
//        
//        UIImage *newImg = [delegate imageWithImage:image scaledToSize:CGSizeMake(newWidht, newHeight)];
//        //NSLog(@"newImg ki width SE %f",newImg.size.width);
//
//        @synchronized(self)
//        {
//            IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
//            [sqliteManager createTable:@"AppImages"];
//            [sqliteManager saveImage:[NSString stringWithFormat:@"GalleryImage_%d",[idx intValue]] Image:newImg];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self loadImagesAndAddToScrollView];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        });
//    }
}

- (void) didFinishAllDownload {
	/////////NSLog(@"Finished all download!");
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)didFailDownloadWithError:(NSError *)error {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    ////NSLog(@"scrollViewDidScroll");
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    int page = floor((self.scrollView.contentOffset.x - pageWidth) / pageWidth) + 1;
    if (page == mainArray.count || page < 0) {
        return;
    }
    self.pageControl.currentPage = page;
    PhotoObj *obj = [[PhotoObj alloc] init];
    obj = [mainArray objectAtIndex:page];
    lblDescibeImage.text = obj.caption;
    if (obj.ownerUserId == [[USER_DEFAULT objectForKey:@"userId"] intValue]) {
        btnDelete.hidden = NO;
    }else
        btnDelete.hidden = YES;
    NSString *strImageName = [Common getFilePath:obj.urlPhoto];
    NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
    UIImage *gallImage = [UIImage imageWithData:pngData];
    
    float tile = gallImage.size.height/gallImage.size.width;
    float newHeight = 458;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight > 480) {
        if (newHeight > 468)
            newHeight = 458;
    }else{
        if (newHeight > 380)
            newHeight = 370;
    }
    float newWidht = 320;
    if (tile > 1) {
        newWidht = newHeight/tile;
    }else{
        newHeight = newWidht*tile;
    }
    gallImage= [delegate imageWithImage:gallImage scaledToSize:CGSizeMake(newWidht, newHeight)];
    
    int x = 0;
    if (SCREEN_HEIGHT > 480)
        x = 100;
    CGFloat xOrigin = page * 320;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin+ (320 - gallImage.size.width)/2,(self.scrollView.frame.size.height-gallImage.size.height+x)/2,gallImage.size.width,gallImage.size.height)];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin,(self.scrollView.frame.size.height-gallImage.size.height+x)/2,gallImage.size.width,gallImage.size.height)];
    [imageView setImage:gallImage];
    [scrollView addSubview:imageView];
    
//    if(gallImage.size.width!=320)
//    {
//        float newWidht = 320;
//        float newheightFloat = roundf(newWidht*gallImage.size.height/gallImage.size.width);
//        int newHeight = newheightFloat;
//        if (SCREEN_HEIGHT > 480) {
//            if (newHeight > 468)
//                newHeight = 458;
//        }else{
//            if (newHeight > 380)
//                newHeight = 370;
//        }
//        gallImage= [delegate imageWithImage:gallImage scaledToSize:CGSizeMake(newWidht, newHeight)];
//    }
//    int x = 0;
//    if (SCREEN_HEIGHT > 480)
//        x = 100;
//    CGFloat xOrigin = page * 320;
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin,(self.scrollView.frame.size.height-gallImage.size.height+x)/2,gallImage.size.width,gallImage.size.height)];
//    [imageView setImage:gallImage];
//    [scrollView addSubview:imageView];
}
- (IBAction)changePage {
    // update the scroll view to the appropriate page
    ////NSLog(@"changePage");

    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    PhotoObj *obj = [[PhotoObj alloc] init];
    obj = [mainArray objectAtIndex:currentPage];
    if (obj.ownerUserId == [[USER_DEFAULT objectForKey:@"userId"] intValue]) {
        btnDelete.hidden = NO;
    }else
        btnDelete.hidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated
{
    //[downloads release];
    //[MultipleDownload cancelPreviousPerformRequestsWithTarget:self];
//    downloads.delegate=nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnDeleteClick:(id)sender {
    viewPhoto.hidden = NO;
}

- (IBAction)btnBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnYesClick:(id)sender {
    viewPhoto.hidden = YES;
    PhotoObj *obj = [[PhotoObj alloc] init];
    obj = [mainArray objectAtIndex:indexImage];
    obj.flag = 3;
    [delegate.myQueue addOperationWithBlock:^{
        [self syncPhoto];
    }];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // sync data
//        [self syncPhoto];
//    });
    if ([parent isKindOfClass:[SlideShowVC class]]) {
        [((SlideShowVC*)parent).mainArray removeObjectAtIndex:indexImage];
        [((SlideShowVC*)parent).mainCollectionView reloadData];
//        [((SlideShowVC*)parent) getImage];
    }else{
        [((ReceiptVC*)parent).mainArray removeObjectAtIndex:indexImage];
        [((ReceiptVC*)parent).mainCollectionView reloadData];
//        [((ReceiptVC*)parent) reloadScrollView];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnNoClick:(id)sender {
    viewPhoto.hidden = YES;
}
@end
