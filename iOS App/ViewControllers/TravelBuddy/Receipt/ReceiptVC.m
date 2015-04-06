//
//  ReceiptVC.m
//  Fun Spot App
//
//  Created by MAC on 8/21/14.
//
//

#import "ReceiptVC.h"
#import "AsynImageButton.h"
#import "ImageGalleryViewController.h"
#import "SendReceiptEmailVC.h"
#import "NewCellPhoto.h"

@interface ReceiptVC ()

@end

@implementation ReceiptVC
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
    bgImgView.layer.cornerRadius = 5.0;
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    float main_top = 0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        main_top = 0;
    }
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    mainArray = [[NSMutableArray alloc] init];
    [mainCollectionView registerNib:[UINib nibWithNibName:@"NewCellPhoto" bundle:nil] forCellWithReuseIdentifier:@"NewCellPhoto"];
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
    [self performSelector:@selector(getImage) withObject:nil afterDelay:1.0];
//    [self getImage];
}

- (void) getImage{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
    [mainArray removeAllObjects];
    @autoreleasepool {
        IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
        NSMutableArray * arrayPhoto = [[NSMutableArray alloc] init];
        @synchronized(self){
            arrayPhoto = [sqlManager getPhotoItems:[[USER_DEFAULT objectForKey:@"userTripId"] intValue] andReceipt:1];
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
    
//    NSOperationQueue *queueGetDataREceipt = [[NSOperationQueue alloc]init];
//    queueGetDataREceipt.name = @"queueGetDataREceipt";
//    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
//    
//    [queueGetDataREceipt addOperationWithBlock:^{
//        [mainArray removeAllObjects];
//        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//        IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
//        @synchronized(self){
//            mainArray = [sqlManager getPhotoItems:[[userDefault objectForKey:@"userTripId"] intValue] andReceipt:1];
//        }
//        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//            [self reloadScrollView];
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        }];
//    }];
//    [self performSelector:@selector(reloadScrollView) withObject:Nil afterDelay:1.0];
    
}
- (void) reloadScrollView{
    lblInstruction.hidden = YES;
    [self.view bringSubviewToFront:lblInstruction];
    for (UIView *subView in mainScroll.subviews) {
        [subView removeFromSuperview];
    }
    float x = 0;
    float y = 0;
    if (mainArray.count >0) {
        
        for (int i = 0; i < mainArray.count; i++) {
            PhotoObj *obj = [[PhotoObj alloc] init];
            obj = [mainArray objectAtIndex:i];
            NSLog(@"URL PHOTO :%@",obj.urlPhoto);
            if (i % 2 == 0 ) {
                x = 10;
            }else
                x+= 150;
            y = 150*(i/2)+10;
            AsynImageButton *asynImgBtn = [[AsynImageButton alloc] initWithFrame:CGRectMake(x, y, 140, 140)];
            asynImgBtn.tag = TagImage+i;
            NSString *strImageName = [Common getFilePath:obj.urlPhoto];
            NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
            UIImage *image = [UIImage imageWithData:pngData];
            [asynImgBtn loadIMageFromImage:image];
//            [asynImgBtn loadIMage:image];
            //        [asynImgBtn setImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
            [asynImgBtn addTarget:self action:@selector(pushToGallery:) forControlEvents:UIControlEventTouchUpInside];
            [mainScroll addSubview:asynImgBtn];
            
            UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(x+5, y+110, 130, 25)];
            lblName.backgroundColor = [UIColor blackColor];
            lblName.textColor = [UIColor whiteColor];
            lblName.text = obj.caption;
            lblName.alpha = 0.6;
            lblName.font = [UIFont boldSystemFontOfSize:12];
            [mainScroll addSubview:lblName];
            
            if (obj.serverId == 0) {
                BOOL isBelongArraySyncing = false;
                for (int i = 0; i < delegate.arrayPhotoSyncing.count; i++) {
                    PhotoObj *photoObj = [delegate.arrayPhotoSyncing objectAtIndex:i];
                    if (photoObj.photoId == obj.photoId) {
                        isBelongArraySyncing = true;
                        break;
                    }
                }
                
                if (isBelongArraySyncing) {
                    
                    
                    Reachability *reach = [Reachability reachabilityForInternetConnection];
                    NetworkStatus netStatus = [reach currentReachabilityStatus];
                    
                    if (netStatus == NotReachable) {
//                        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
                    }else{
                        UIActivityIndicatorView *actIn = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(x+50, y+50, 40, 40)];
                        [actIn setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                        [actIn startAnimating];
                        actIn.tag = TagActIn + i;
                        [mainScroll addSubview:actIn];
                        
//                        [delegate.myQueue addOperationWithBlock:^{
//                            // Background work
//                            [self clickSyncPhoto:obj];
//                            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//                                [self getImage];
//                            }];
//                        }];
                    }
                    
                }else{
                    UIButton *btnSync = [[UIButton alloc] initWithFrame:CGRectMake(x+107, y+3, 30, 30)];
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
    
    [mainScroll setContentSize:CGSizeMake(300, y+140)];
    mainScroll.layer.borderColor = [UIColor darkGrayColor].CGColor;
}

- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.view endEditing:YES];
    self.navigationController.navigationBarHidden = YES;
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
            //                    [delegate showAlert:[dict objectForKey:@"message"]];
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
//        NSMutableArray *arrayPhoto = [[NSMutableArray alloc] init];
//        @synchronized(self){
//            arrayPhoto = [sqliteManager getPhotoItems:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userTripId"] intValue] andReceipt:1];
//        }
//        
//        for (int j = 0 ; j < arrayUpdateData.count; j++) {
//            PhotoObj *objPhoto = [[PhotoObj alloc] init];
//            NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
//            if ([[dictResponse objectForKey:@"isreceipt"] intValue] == 0) {
//                continue;
//            }
//            BOOL isExist = NO;
//            for (int k = 0 ; k < arrayPhoto.count; k++) {
//                PhotoObj *obj = [arrayPhoto objectAtIndex:k];
//                if ([[dictResponse objectForKey:@"serverid"] intValue] == obj.serverId) {
//                    isExist = YES;
//                    break;
//                }
//            }
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
//                if (isExist) {
//                    continue;
//                }
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
                UIActivityIndicatorView *actIn = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(subView.frame.origin.x+50, subView.frame.origin.y+50, 40, 40)];
                [actIn setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                [actIn startAnimating];
                actIn.tag = TagActIn + tag;
                [mainScroll addSubview:actIn];
            }
        }
        //Get current Photo which want to update
        PhotoObj *obj = [[PhotoObj alloc] init];
        obj = [mainArray objectAtIndex:tag];
        
        [delegate.myQueue addOperationWithBlock:^{
            
            // Background work
//            [self afterClickSyncPhoto:obj withTag:(TagActIn + tag)];
        }];
    } 
}
-(void) pushToGallery:(id)sender{
    [self.view endEditing:YES];
    UIButton *btn = (UIButton *)sender;
    ImageGalleryViewController *imageGallery = [[ImageGalleryViewController alloc] initWithNibName:@"ImageGalleryViewController" bundle:nil parent:self];
    self.navigationItem.title =@"Back";
    imageGallery.isSlideshow = FALSE;
    [[self navigationController] pushViewController:imageGallery animated:YES];
    imageGallery.currentPage = btn.tag -10000;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    if (mainRect.size.height > 480) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 200, self.view.frame.size.width, self.view.frame.size.height);
    }else
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 280, self.view.frame.size.width, self.view.frame.size.height);
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    if (mainRect.size.height > 480) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 200, self.view.frame.size.width, self.view.frame.size.height);
    }else
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 280, self.view.frame.size.width, self.view.frame.size.height);
}
- (IBAction)btnHomeClick:(id)sender {
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

- (IBAction)btnSendToMySelfClick:(id)sender {
    if (isSendToMyself) {
        isSendToMyself = FALSE;
        btnSendToMyself.selected = NO;
    }else{
        isSendToMyself = true;
        btnSendToMyself.selected = YES;
    }
}
- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}
#pragma mark move to view send receipt images
- (IBAction)btnSendReceiptClick:(id)sender {
    [self.view endEditing:YES];
    if ([tfReceiptEmailAddress.text isEqualToString:@""] && (isSendToMyself == NO)) {
        [delegate showAlert:@"Please input an email address"];
        return;
    }
    else{
        if (tfReceiptEmailAddress.text.length>0) {
            if(![self validateEmail:tfReceiptEmailAddress.text]) {
                [delegate showAlert:@"Email is invalid!"];
                return;
            }else{
                [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading" animated:YES];
                SendReceiptEmailVC *sendReceipt = [[SendReceiptEmailVC alloc]init];
                sendReceipt.arrayImages = [NSMutableArray array];
                sendReceipt.arrayImages = mainArray;
                sendReceipt.emailFriend = tfReceiptEmailAddress.text;
                sendReceipt.isSendMySelf = isSendToMyself;
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self.navigationController pushViewController:sendReceipt animated:YES];
            }
        }
        else{
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading" animated:YES];
            SendReceiptEmailVC *sendReceipt = [[SendReceiptEmailVC alloc]init];
            sendReceipt.arrayImages = mainArray;
            sendReceipt.emailFriend = tfReceiptEmailAddress.text;
            sendReceipt.isSendMySelf = isSendToMyself;
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.navigationController pushViewController:sendReceipt animated:YES];
        }
    }
}

- (IBAction)btnAddNewReceiptClick:(id)sender {
    viewPhoto.hidden = NO;
    [self.view endEditing:YES];
}

-(void)imagePickerController:(UIImagePickerController *)pickerImage
      didFinishPickingImage : (UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo
{
    //set image name
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss a";
    NSDate *date = [NSDate date];
    NSString *strDate =  [dateFormatter stringFromDate:date];
    NSString *timeStamp =[NSString stringWithFormat:@"%@_%@.jpg",[userDef objectForKey:@"userId"],[[strDate stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""]];
    dateFormatter.dateFormat = @"MM-dd-yyyy HH:mm:ss a";
    NSString *currentDate = [NSString stringWithFormat:@"Added %@",[dateFormatter stringFromDate:date]];
    
    UIImage *img = [self burnTextIntoImage:image];
    //write to file into local app
    NSData *pngData = UIImageJPEGRepresentation(img, 1.0);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:timeStamp]; //Add the file name
    [pngData writeToFile:filePath atomically:YES];
    
    //save photo into local database
    IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
    PhotoObj *photoObj = [[PhotoObj alloc] init];
    photoObj.caption   = currentDate;
    photoObj.urlPhoto  = timeStamp;
    photoObj.isReceipt = 1;
    photoObj.tripId    = [[userDef objectForKey:@"userTripId"] intValue];
    photoObj.ownerUserId = [[userDef objectForKey:@"userId"] intValue];
    photoObj.serverId  = 0;
    photoObj.flag      = 1;
    
    @synchronized(self){
        photoObj.photoId = [sqlManager addPhotoReceiptInfor:photoObj];
    }
    [mainArray addObject:photoObj];
    [self getImage];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        
    }else{
        [delegate.arrayPhotoSyncing addObject:photoObj];
        [delegate.myQueue addOperationWithBlock:^{
            // Background work
            [self clickSyncPhoto:photoObj];
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [self getImage];
            }];
        }];
    }
    
//    [asynImgPhoto loadIMageFromImage:image];
    [pickerImage dismissModalViewControllerAnimated:YES];
//    [mainArray addObject:photoObj];
//    [self reloadScrollView];
    //[self getImage];
}
- (UIImage *)burnTextIntoImage:(UIImage *)img {
    CGSize imageSize = CGSizeMake(400, 400);
    float tile = img.size.height/img.size.width;
    float newHeight = 400;
    float newWidht = 400;
    if (tile > 1) {
        newWidht = newHeight/tile;
    }else{
        newHeight = newWidht*tile;
    }
    imageSize = CGSizeMake(newWidht, newHeight);
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(imageSize,NO,0.0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGRect aRectangle = CGRectMake(0,0, newWidht, newHeight);
    [img drawInRect:aRectangle];
    
    // draw text bg
    
//    CGRect cRectangle = CGRectMake(0,newHeight - 40, newWidht, 40);
//    UIImage *imgView = [UIImage imageNamed:@"bg_caption_text.png"];
//    [imgView drawInRect:cRectangle];
//    
//    //draw text
//    [[UIColor whiteColor] set];           // set text color
//    NSInteger fontSize = 17;
//    if ( [text length] > 200 ) {
//        fontSize = 10;
//    }
//    CGRect bRectangle = CGRectMake(10,newHeight - 32, newWidht,32);
//    UIFont *font = [UIFont boldSystemFontOfSize: fontSize];
//    [ text drawInRect : bRectangle                      // render the text
//             withFont : font
//        lineBreakMode : UILineBreakModeTailTruncation  // clip overflow from end of last line
//            alignment : UITextAlignmentLeft];
    
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();   // extract the image
    UIGraphicsEndImageContext();     // clean  up the context.
    return theImage;
}
-(void) clickSyncPhoto:(PhotoObj*)obj{
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
    if ([[dict objectForKey:@"success"] intValue] == 0) {
        if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
            //                    [delegate showAlert:[dict objectForKey:@"message"]];
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
                    for (UIView *subView in mainScroll.subviews) {
                        if (subView.tag >= TagActIn) {
                            [subView removeFromSuperview];
                        }
                    }
                }
            }
        }];
//        //get array updated from sever
//        NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
//        NSMutableArray *arrayPhoto = [[NSMutableArray alloc] init];
//        @synchronized(self){
//            arrayPhoto = [sqliteManager getPhotoItems:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userTripId"] intValue] andReceipt:1];
//        }
//        arrayUpdateData = [dict objectForKey:@"updated_data"];
//        for (int j = 0 ; j < arrayUpdateData.count; j++) {
//            PhotoObj *objPhoto = [[PhotoObj alloc] init];
//            NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
//            if ([[dictResponse objectForKey:@"isreceipt"] intValue] == 0) {
//                continue;
//            }
//            BOOL isExist = NO;
//            for (int k = 0 ; k < arrayPhoto.count; k++) {
//                PhotoObj *obj = [arrayPhoto objectAtIndex:k];
//                if ([[dictResponse objectForKey:@"serverid"] intValue] == obj.serverId) {
//                    isExist = YES;
//                    break;
//                }
//            }
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
//                if (isExist) {
//                    continue;
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    @synchronized(self)
//                    {
//                        [sqliteManager addPhotoInfor:objPhoto];
//                        [Common saveImageToLocal:[dictResponse objectForKey:@"photourl"]];
//                    }
//                });
//            }
//        }
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)  pickerImage
{
    [pickerImage dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnTakePhotoClick:(id)sender {
    NSString *model = [[UIDevice currentDevice] model];
    
    if ([model isEqualToString:@"iPhone Simulator"]) {
        UIAlertView *funSpoAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Take Photo cannot be completed on simulator." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [funSpoAlertView show];
    }
    else
    {
        viewPhoto.hidden = YES;
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
        pickerImage.delegate = self;
//        pickerImage.allowsEditing = YES;
        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerImage animated:YES completion:nil];
    }
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
    CGSize size = CGSizeMake(145, 145);
    return size;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageGalleryViewController *imageGallery = [[ImageGalleryViewController alloc] initWithNibName:@"ImageGalleryViewController" bundle:nil parent:self];
    self.navigationItem.title =@"Back";
    imageGallery.isSlideshow = false;
    [[self navigationController] pushViewController:imageGallery animated:YES];
    imageGallery.indexImage = indexPath.row;
}

// sync photo Receipt
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

- (IBAction)btnChoosePhotoFromLibClick:(id)sender {
    viewPhoto.hidden = YES;
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.delegate = self;
//    pickerImage.allowsEditing = YES;
    pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:pickerImage animated:YES completion:nil];
}

- (IBAction)btnCancelClick:(id)sender {
    viewPhoto.hidden = YES;
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
    }else{
        [self.view bringSubviewToFront:self.itemsView];
        [self.view endEditing:YES];
    }
    
}
@end
