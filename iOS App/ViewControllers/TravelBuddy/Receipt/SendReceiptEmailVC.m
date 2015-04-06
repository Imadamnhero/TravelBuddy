//
//  CreateSlideShowVC.m
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 10/16/14.
//
//
#import "AppDelegate.h"
#import "SendReceiptEmailVC.h"
#import "SlideShowVC.h"
#import "AsynImageButton.h"
#import "PhotoViewController.h"
#import "BaseNavigationController.h"
#import "ImageGalleryViewController.h"
#import "CreateSlideShowVC.h"
#import "Annotation.h"
#import "PhotoObj.h"
#import "PlayListView.h"
#import "FileHelper.h"

#define MaxSizeToSendReceipt 26214400.0f

@interface SendReceiptEmailVC ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate,AVAudioSessionDelegate,MPMediaPickerControllerDelegate,PlayListViewDelegate>
{
    __weak IBOutlet UILabel *_lbNameAudio;
    __weak IBOutlet UILabel *_lbDurationSlide;
    __weak IBOutlet UIView *_viewMenuBar;
    NSMutableArray *_images;
    UITapGestureRecognizer *recognizer;
    float sizeOfReceiptsSendEmail;
    AppDelegate *delegate;
    NSOperationQueue *calculatorQueue,*queueGetData;
}

@end

@implementation SendReceiptEmailVC
@synthesize arrayImages;

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
    [self initData];
    [self initUI];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self getImage];
}
- (void)initData
{
    delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    //arrayImages = [NSMutableArray array];
    _images = [NSMutableArray array];
    calculatorQueue = [[NSOperationQueue alloc]init];
    calculatorQueue.name = @"calculatorSize";
    queueGetData = [[NSOperationQueue alloc]init];
    queueGetData.name = @"getDataImages";
}

- (void)initUI
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    btnBack.imageEdgeInsets = UIEdgeInsetsMake(7, 12, 7, 8);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgScrollSlideShow.png"]];
    scrollChooseImages.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40);
}
- (void) getImage{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
    [queueGetData addOperationWithBlock:^{
        arrayImages = [NSMutableArray array];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
        @synchronized(self){
            arrayImages = [sqlManager getPhotoItemsSync:[[userDefault objectForKey:@"userTripId"] intValue] andReceipt:1];
        }
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self createScrollImageView];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }];
    
}
- (void) createScrollImageView{
    for (UIView *subView in scrollChooseImages.subviews) {
        [subView removeFromSuperview];
    }
    float x = 0;
    float y = 5;
    scrollChooseImages.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgScrollImages.png"]];
    for (int i = 0; i < arrayImages.count; i++) {
        PhotoObj *objPhoto = [[PhotoObj alloc] init];
        objPhoto = [arrayImages objectAtIndex:i];
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
        [asynImgBtn loadIMageFromImage:image];
        [asynImgBtn addTarget:self action:@selector(insertImage:) forControlEvents:UIControlEventTouchUpInside];
        [scrollChooseImages addSubview:asynImgBtn];
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(x, y+79, 100, 21)];
        lblName.backgroundColor = [UIColor blackColor];
        lblName.textColor = [UIColor whiteColor];
        lblName.text = objPhoto.caption;
        lblName.alpha = 0.6;
        lblName.font = [UIFont boldSystemFontOfSize:12];
        [scrollChooseImages addSubview:lblName];
        
        UIButton *btnSync = [[UIButton alloc] initWithFrame:CGRectMake(x+80, y+2, 20, 23)];
        [btnSync setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        btnSync.tag = TagImageClickSync+i;
        [scrollChooseImages addSubview:btnSync];
        if (objPhoto.isChecked == 0) {
            btnSync.hidden=YES;
        }
        else
            btnSync.hidden=NO;
    }
    [scrollChooseImages setContentSize:CGSizeMake(300, y+125)];
    scrollChooseImages.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void) insertImage:(id)sender{
    [self.view endEditing:YES];
    UIButton *btn = (UIButton *)sender;
    PhotoObj *photo = [arrayImages objectAtIndex:btn.tag-TagImage];
    if (photo.isChecked == 0) {
        photo.isChecked=1;
        for (UIView *subView in scrollChooseImages.subviews) {
            if (subView.tag == TagImageClickSync + (btn.tag-TagImage)) {
                subView.hidden=NO;
                [_images addObject:photo];
                
                break;
            }
        }
    }else
    {
        photo.isChecked=0;
        for (UIView *subView in scrollChooseImages.subviews) {
            if (subView.tag == TagImageClickSync + (btn.tag-TagImage)) {
                for (PhotoObj *ptObject in _images) {
                    if ([ptObject.urlPhoto isEqualToString:photo.urlPhoto]) {
                        [_images removeObject:ptObject];
                        break;
                    }
                }
                subView.hidden=YES;
                break;
            }
        }
    }
    
}
- (void)calculatorSizeOfImages
{
    [calculatorQueue addOperationWithBlock:^{
        sizeOfReceiptsSendEmail = 0.0f;
        for (PhotoObj *objPhoto in _images) {
            NSString *strImageName = [Common getFilePath:objPhoto.urlPhoto];
            NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
            UIImage *image = [UIImage imageWithData:pngData];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            float sizeImage = [imageData length];
            sizeOfReceiptsSendEmail = sizeOfReceiptsSendEmail + sizeImage;
        }
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            if (sizeOfReceiptsSendEmail >= MaxSizeToSendReceipt) {
                [delegate showAlert:@"Please choose small size. Maximum size to send is 25MB"];
            }
        }];
    }];
    
}

- (IBAction)backToReceiptVC:(id)sender {
    arrayImages = [NSMutableArray array];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)sendEmail:(id)sender {
    if (sizeOfReceiptsSendEmail >= MaxSizeToSendReceipt) {
        [delegate showAlert:@"Please choose small size. Maximum size to send is 25MB"];
    }else{
        if (_images.count == 0) {
            [delegate showAlert:@"Please choose receipts if you want to send"];
        }else{
            Reachability *reach = [Reachability reachabilityForInternetConnection];
            NetworkStatus netStatus = [reach currentReachabilityStatus];
            
            if (netStatus == NotReachable) {
                [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
            }else{
                [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Uploading" animated:YES];
                [self afterClickSendMail];
            }
        }
    }
}

//- (void)attactFileSendEmail {
//    NSString *emailTitle = @"Travel buddy share receipts";
//    NSString *messageBody = @"Hey, check this out!";
//    NSArray *toRecipents = [NSArray array];
//    if (self.isSendMySelf) {
//        NSString *myEmail = [[NSUserDefaults standardUserDefaults]objectForKey:@"userEmail"];
//        toRecipents = [NSArray arrayWithObjects:self.emailFriend,myEmail, nil];
//    }else{
//        toRecipents = [NSArray arrayWithObjects:self.emailFriend, nil];
//    }
//    
//    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
//    mc.mailComposeDelegate = self;
//    [mc setSubject:emailTitle];
//    [mc setMessageBody:messageBody isHTML:NO];
//    [mc setToRecipients:toRecipents];
//    
//    
//    NSOperationQueue *queueSendEmail = [[NSOperationQueue alloc]init];
//    [queueSendEmail addOperationWithBlock:^{
//        for (PhotoObj *photo in _images) {
//            NSString *filename = [[photo.urlPhoto componentsSeparatedByString:@"."]objectAtIndex:0];
//            NSString *extension = @"jpg";
//            NSString *strImageName = [Common getFilePath:photo.urlPhoto];
//            NSData *fileData = [NSData dataWithContentsOfFile:strImageName];
//            // Get the resource path and read the file using NSData
//            //NSData *fileData = [NSData dataWithContentsOfFile:photo.urlPhoto];
//            
//            // Determine the MIME type
//            NSString *mimeType;
//            if ([extension isEqualToString:@"jpg"]) {
//                mimeType = @"image/jpeg";
//            } else if ([extension isEqualToString:@"png"]) {
//                mimeType = @"image/png";
//            } else if ([extension isEqualToString:@"doc"]) {
//                mimeType = @"application/msword";
//            } else if ([extension isEqualToString:@"ppt"]) {
//                mimeType = @"application/vnd.ms-powerpoint";
//            } else if ([extension isEqualToString:@"html"]) {
//                mimeType = @"text/html";
//            } else if ([extension isEqualToString:@"pdf"]) {
//                mimeType = @"application/pdf";
//            }else if ([extension isEqualToString:@"mp4"]) {
//                mimeType = @"application/movie";
//            }
//            
//            // Add attachment
//            [mc addAttachmentData:fileData mimeType:mimeType fileName:filename];
//        }
//        // Present mail view controller on screen
//        
//    }];
//    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//        [self presentViewController:mc animated:YES completion:NULL];
//    }];
//}
- (void)attactFileSendEmail {
    NSString *emailTitle = @"Travel buddy share receipts";
    NSString *messageBody = @"Hey, check this out!";
    NSArray *toRecipents = [NSArray array];
    if (self.isSendMySelf) {
        NSString *myEmail = [[NSUserDefaults standardUserDefaults]objectForKey:@"userEmail"];
        toRecipents = [NSArray arrayWithObjects:self.emailFriend,myEmail, nil];
    }else{
        toRecipents = [NSArray arrayWithObjects:self.emailFriend, nil];
    }
    
    MFMailComposeViewController *mailCompo = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        mailCompo.mailComposeDelegate = self;
        [mailCompo setSubject:emailTitle];
        [mailCompo setMessageBody:messageBody isHTML:NO];
        [mailCompo setToRecipients:toRecipents];
        
        
        for (PhotoObj *photo in _images) {
            NSString *filename = [[photo.urlPhoto componentsSeparatedByString:@"."]objectAtIndex:0];
            NSString *extension = @"jpg";
            NSString *strImageName = [Common getFilePath:photo.urlPhoto];
            NSData *fileData = [NSData dataWithContentsOfFile:strImageName];
            // Get the resource path and read the file using NSData
            //NSData *fileData = [NSData dataWithContentsOfFile:photo.urlPhoto];
            
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
            [mailCompo addAttachmentData:fileData mimeType:mimeType fileName:filename];
        }
        // Present mail view controller on screen
        [self presentViewController:mailCompo animated:YES completion:NULL];
    }
}

#pragma mark mail delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            [delegate showAlert:@"Canceled"];
            [self dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSaved:
            [delegate showAlert:@"Saved"];
            NSLog(@"Result: saved");
            [self dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSent:
            [delegate showAlert:@"Sent"];
            NSLog(@"Result: sent");
            [self dismissModalViewControllerAnimated:YES];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case MFMailComposeResultFailed:
            [delegate showAlert:@"Failed"];
            NSLog(@"Result: failed");
            [self dismissModalViewControllerAnimated:YES];
            break;
        default:
            [delegate showAlert:@"Not sent"];
            NSLog(@"Result: not sent");
            [self dismissModalViewControllerAnimated:YES];
            break;
    }
    
}

- (void)afterClickSendMail
{
    
    //    NSString *result =@"";
    NSOperationQueue *queueUpLoad = [[NSOperationQueue alloc]init];
    queueUpLoad.name = @"queueUpLoad";
    [queueUpLoad addOperationWithBlock:^{
        
        int userID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
        int userTripID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userTripId"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        NSString *myEmail = @"";
        NSString *sentOwner = @"0";
        if (self.isSendMySelf) {
            myEmail = [[NSUserDefaults standardUserDefaults]objectForKey:@"userEmail"];
            sentOwner = @"1";
        }else{
            myEmail = self.emailFriend;
            sentOwner = @"0";
        }
        
        NSString *strPhotoId = @"";
        for (int i = 0; i < _images.count; i++) {
            PhotoObj *photo = [_images objectAtIndex:i];
            if (i == 0) {
                strPhotoId = [NSString stringWithFormat:@"%d",photo.serverId];
            }else
                strPhotoId = [NSString stringWithFormat:@"%d,%@",photo.serverId,strPhotoId];
        }
        ///userid (của người mời), email(của người được mời), tripid
        NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
        [_params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] forKey:@"userid"];
        [_params setObject:myEmail forKey:@"email"];
        [_params setObject:sentOwner forKey:@"sent2owner"];
        [_params setObject:strPhotoId forKey:@"receipt_ids"];
        //- reply (=0 là cancel, =1 là ok), invited_tripid( tripid được mời vào),invited_user_id (id của người đc mời) và inviter_id (id của người mời)
        NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
        
        // string constant for the post parameter 'file'
        //    NSString *FileParamConstant = @"";
        
        //Setup request URL
        NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/send_receipt.php",SERVER_LINK]];
        
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
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            NSLog(@"Upload Video : %@",dict);
            int success = [[dict objectForKey:@"success"] intValue];
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success == 1) {
                [delegate showAlert:@"Send mail successful"];
            }else {
                [delegate showAlert:@"Failed to send mail"];
            }
        }];
    }];
}
@end
