//
//  AddPhotoVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "AddPhotoVC.h"
#import "PhotoObj.h"
@interface AddPhotoVC ()

@end

@implementation AddPhotoVC
@synthesize isAddPhoto,isTakePhoto;
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
    
    asynImgPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    asynImgPhoto.layer.borderWidth = 4.0;
    asynImgPhoto.layer.cornerRadius = 5.0;
    
    bgViewLabelDes.layer.cornerRadius = 5.0;
    isAddedPhoto = FALSE;
//    UIColor *color = [UIColor colorWithRed:248/255.0 green:216/255.0 blue:239/255.0 alpha:1.0];
    btnCancel.layer.cornerRadius = 4.0;
    if (isTakePhoto) {
        [self takePhotoClick:nil];
        lblTitleViewPhoto.text = @"Take photo";
    }
    if (isAddPhoto) {
        [self chooseFromLibClick:nil];
        lblTitleViewPhoto.text = @"Add photo";
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma UIImagePickerController
// get picture from library or take new picture
- (IBAction)btnPhotoClick:(id)sender {
    [self.view endEditing:YES];
    if (isTakePhoto) {
        [self takePhotoClick:nil];
        return;
    }
    if (isAddPhoto) {
        [self chooseFromLibClick:nil];
        return;
    }
    viewPhoto.hidden = NO;
}

- (IBAction)btnCancelImageClick:(id)sender {
    viewPhoto.hidden = YES;
}

- (IBAction)btnSaveClick:(id)sender {
    [self.view endEditing:YES];
    if (!isAddedPhoto) {
        [delegate showAlert:@"Please add a photo"];
        return;
    }
    NSString* strDes = [tfDescribePhoto.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([tfDescribePhoto.text isEqualToString:@""]) {
        [delegate showAlert:@"Please describe your photo"];
        return;
    }
    if (strDes.length == 0) {
        [delegate showAlert:@"Please input data"];
        return;
    }
    if (![tfDescribePhoto.text isEqualToString:@""] && tfDescribePhoto.text.length >40) {
        [delegate showAlert:@"Describle must have less than 40 character"];
        return;
    }
    UIImage *image = [self burnTextIntoImage:tfDescribePhoto.text :currentImage];//[self drawImage:currentImage andCaption:tfDescribePhoto.text];
    //set image name
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [NSDate date];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSString *timeStamp =[NSString stringWithFormat:@"%@_%@.jpg",[userDef objectForKey:@"userId"],[[strDate stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""]];
    
    //write to file into local app
//    NSData *pngData = UIImagePNGRepresentation(currentImage);
    NSData *pngData = UIImageJPEGRepresentation(image, 1.0);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:timeStamp]; //Add the file name
    [pngData writeToFile:filePath atomically:YES];
    
    //save photo into local database
    IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
    PhotoObj *photoObj = [[PhotoObj alloc] init];
    photoObj.caption   = tfDescribePhoto.text;
    photoObj.urlPhoto  = timeStamp;
    photoObj.isReceipt = 0;
    photoObj.tripId    = [[userDef objectForKey:@"userTripId"] intValue];
    photoObj.ownerUserId = [[userDef objectForKey:@"userId"] intValue];
    photoObj.serverId  = 0;
    photoObj.flag      = 1;
    @synchronized(self){
//        [sqlManager addPhotoInfor:photoObj];
        photoObj.photoId = [sqlManager addPhotoReceiptInfor:photoObj];
    }
    tfDescribePhoto.text = @"";
    [asynImgPhoto loadIMageFromImage:nil];
    btnAddPhotoSmall.hidden = NO;
    isAddedPhoto = FALSE;
    btnDelete.hidden = YES;
    [delegate showAlert:@"Your photo was saved succesfully into SlideShow"];
    
    [self performSelector:@selector(syncImage:) withObject:photoObj afterDelay:1.0];
}
- (void) syncImage:(PhotoObj*)photoObj{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        //                        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
    }else{
        [delegate.arrayPhotoSyncing addObject:photoObj];
        [delegate.myQueue addOperationWithBlock:^{
            // Background work
            [self clickSyncPhoto:photoObj];
        }];
    }

}
- (IBAction)btnAddPhotoSmallClicck:(id)sender {
    [self btnPhotoClick:nil];
}

- (IBAction)btnYesClick:(id)sender {
    viewConfirmDeletePhoto.hidden = YES;
    btnDelete.hidden = YES;
    isAddedPhoto = FALSE;
    btnAddPhotoSmall.hidden = NO;
    [asynImgPhoto loadIMageFromImage:nil];
}

- (IBAction)btnNoClick:(id)sender {
    viewConfirmDeletePhoto.hidden = YES;
}
- (IBAction)takePhotoClick:(id)sender {
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

- (IBAction)chooseFromLibClick:(id)sender {
    viewPhoto.hidden = YES;
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.delegate = self;
//    pickerImage.allowsEditing = YES;
    pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:pickerImage animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)pickerImage
      didFinishPickingImage : (UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo
{
    isAddedPhoto = TRUE;
    btnDelete.hidden = NO;
    btnAddPhotoSmall.hidden = YES;
    currentImage = image;
//    [asynImgPhoto setImage:image forState:UIControlStateNormal];
    [asynImgPhoto loadIMageFromImage:image];
    [pickerImage dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *) pickerImage
{
    [pickerImage dismissViewControllerAnimated:YES completion:nil];
}
//action when click delete photo
- (IBAction)btnDeletePhotoCLick:(id)sender {
    viewConfirmDeletePhoto.hidden = NO;
}
//when click button home
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
                    
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"syncPhotoSuccess"
//                                                                        object:nil];
                }
            }
        }];
//        //get array updated from sever
//        NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
//        NSMutableArray *arrayPhoto = [[NSMutableArray alloc] init];
//        @synchronized(self){
//            arrayPhoto = [sqliteManager getPhotoItems:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userTripId"] intValue] andReceipt:0];
//        }
//        arrayUpdateData = [dict objectForKey:@"updated_data"];
//        for (int j = 0 ; j < arrayUpdateData.count; j++) {
//            PhotoObj *objPhoto = [[PhotoObj alloc] init];
//            NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
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
#pragma text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 185, self.view.frame.size.width, self.view.frame.size.height);
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 185, self.view.frame.size.width, self.view.frame.size.height);
}

- (UIImage *)burnTextIntoImage:(NSString *)text :(UIImage *)img {
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
    
    CGRect cRectangle = CGRectMake(0,newHeight - 40, newWidht, 40);
    UIImage *imgView = [UIImage imageNamed:@"bg_caption_text.png"];
    [imgView drawInRect:cRectangle];
    
    //draw text
    [[UIColor whiteColor] set];           // set text color
    NSInteger fontSize = 17;
    if ( [text length] > 200 ) {
        fontSize = 10;
    }
    CGRect bRectangle = CGRectMake(10,newHeight - 32, newWidht,32);
    UIFont *font = [UIFont boldSystemFontOfSize: fontSize];
    [ text drawInRect : bRectangle                      // render the text
             withFont : font
        lineBreakMode : UILineBreakModeTailTruncation  // clip overflow from end of last line
            alignment : UITextAlignmentLeft];
//    CGRect bRectangle = CGRectMake(10,30, img.size.width, img.size.height);
//    /// Make a copy of the default paragraph style
//    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//    /// Set line break mode
//    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//    /// Set text alignment
//    paragraphStyle.alignment = NSTextAlignmentLeft;
//    
//    NSDictionary *attributes = @{ NSFontAttributeName: font,
//                                  NSParagraphStyleAttributeName: paragraphStyle };
//    [text drawInRect:bRectangle withAttributes:attributes];
    
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();   // extract the image
    UIGraphicsEndImageContext();     // clean  up the context.
    return theImage;
}





// add label into image
//-(UIImage*) drawText:(NSString*) text
//             inImage:(UIImage*)  image
//             atPoint:(CGPoint)   point
-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*) drawImage:(UIImage*)image
           andCaption:(NSString*)text
{
    UILabel *label =  [[UILabel alloc] initWithFrame:CGRectMake(0, image.size.height - 20, image.size.width, image.size.height)];
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, image.size.height - 20, image.size.width, image.size.height)];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.5;
    
    UIGraphicsBeginImageContext(image.size);
    CGRect rect = CGRectMake(0, image.size.height - 20, image.size.width, 21);
    
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    [view drawRect:rect];
    [label drawRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
@end
