//
//  EditAccountVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/14/14.
//
//

#import "EditAccountVC.h"
#import "IntroViewController.h"
#import "User.h"
#import "IMSSqliteManager.h"

@interface EditAccountVC ()

@end

@implementation EditAccountVC

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
    
//    tfEmail.layer.cornerRadius    = 5.0;
//    tfPassword.layer.cornerRadius = 5.0;
//    tfNewPass.layer.cornerRadius  = 5.0;
//    tfUserName.layer.cornerRadius = 5.0;
    bgImgView.layer.cornerRadius      = 5.0;
    btnCancelImage.layer.cornerRadius = 5.0;
    btnDeleteAvatar.imageEdgeInsets   = UIEdgeInsetsMake(2, 2, 2, 2);
    isAddAvatar = TRUE;
    
    [tfConfirmNewPass setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:14]];
    [tfEmail setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:14]];
    [tfNewPass setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:14]];
    [tfPassword setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:14]];
    [tfUserName setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:14]];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *strImageUrl = [NSString stringWithFormat:@"%@%@",SERVER_LINK,[userDefault objectForKey:@"userAvatarUrl"]];
    [asynImgPhoto loadImageFromURL:[NSURL URLWithString:strImageUrl]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    tfUserName.text = [USER_DEFAULT objectForKey:@"userName"];
    tfEmail.text    = [USER_DEFAULT objectForKey:@"userEmail"];
    
    if ([[USER_DEFAULT objectForKey:@"memoryUser"] isEqualToString:@"true"]) {
        [btnRemember setSelected:YES];
    }else
        [btnRemember setSelected:NO];
}
- (void)viewWillAppear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma UIImagePickerController
// get picture from library or take new picture
- (IBAction)btnPhotoClick:(id)sender {
    [self.view endEditing:YES];
    viewPhoto.hidden = NO;
}

- (IBAction)btnCancelImageClick:(id)sender {
    viewPhoto.hidden = YES;
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
        pickerImage.allowsEditing = YES;
        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerImage animated:YES completion:nil];
    }
}

- (IBAction)chooseFromLibClick:(id)sender {
    viewPhoto.hidden = YES;
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.delegate = self;
    pickerImage.allowsEditing = YES;
    pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:pickerImage animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)pickerImage
      didFinishPickingImage : (UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo
{
    isAddAvatar = TRUE;
    btnDeleteAvatar.hidden = NO;
    //    [asynImgPhoto setImage:image forState:UIControlStateNormal];
    [asynImgPhoto loadIMageFromImage:image];
    [self saveImageIntoFolder:image];
    [pickerImage dismissModalViewControllerAnimated:YES];
}
- (void)saveImageIntoFolder: (UIImage*)image
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageUser.png"];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)  pickerImage
{
    [pickerImage dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnRememberClick:(id)sender {
    if (isMemory) {
        isMemory = false;
        [btnRemember setSelected:NO];
    }else{
        isMemory = YES;
        [btnRemember setSelected:YES];
    }
}
- (BOOL)validateChar:(NSString *)character {
    NSString *charRegex = @"[A-Za-z]";
    NSPredicate *charTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", charRegex];
    return [charTest evaluateWithObject:character];
}
- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}
- (void) afterClickSave{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:tfUserName.text forKey:@"username"];
    [_params setObject:[userDefault objectForKey:@"userId"] forKey:@"userid"];
    [_params setObject:tfPassword.text forKey:@"password"];
    [_params setObject:tfNewPass.text forKey:@"new_password"];
    
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'
    NSString *FileParamConstant = @"avatarurl";
    if (!isAddAvatar) {
        FileParamConstant = @"";
    }
    
    //Setup request URL
    NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/edit_user.php",SERVER_LINK]];
    
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
    NSData *imageData = UIImageJPEGRepresentation([self loadImage], 1.0);
    if (imageData) {
        printf("appending image data\n");
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\'%@\'; filename=\"avatar.png\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
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
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if ([[dict objectForKey:@"success"] intValue] == 1) {
        [delegate showAlert:@"Save successful"];
        [userDefault setObject:[dict objectForKey:@"username"] forKey:@"userName"];
        [userDefault setObject:[[dict objectForKey:@"avatarurl"] substringFromIndex:1] forKey:@"userAvatarUrl"];
        [userDefault synchronize];
        
        for (UIViewController *viewController in self.navigationController.viewControllers) {
            if ([viewController isKindOfClass:[IntroViewController class]]) {
                [self.navigationController popToViewController:viewController animated:YES];
                [self performSelector:@selector(pushView:) withObject:viewController afterDelay:0.6];
                break;
            }
        }
    }else
        [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
}
- (IBAction)btnSaveClick:(id)sender {
    BOOL isChangePass = FALSE;
    if ([tfUserName.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input name"];
        return;
    }
//    if([tfUserName.text length]<6 || [tfUserName.text length]>15) {
//        [delegate showAlert:@"Name must have from 6 to 15 characters"];
//        return;
//    }
//    NSString *str = [tfUserName.text substringToIndex:1];
//    if (![self validateChar:str]) {
//        [delegate showAlert:@"Name has begin by character"];
//        return;
//    }
    if ([tfEmail.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input e-mail"];
        return;
    }
    if(![self validateEmail:tfEmail.text]) {
        [delegate showAlert:@"E-mail is invalid"];
        return;
    }

    if (![tfNewPass.text isEqualToString:@""] || ![tfPassword.text isEqualToString:@""] || ![tfConfirmNewPass.text isEqualToString:@""]) {
        isChangePass = TRUE;
    }
    if (!isAddAvatar) {
        [delegate showAlert:@"You have to add avatar"];
        return;
    }
    if (isChangePass) {
        if ([tfPassword.text isEqualToString:@""]) {
            [delegate showAlert:@"Please input password"];
            return;
        }//
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if (![[userDefault objectForKey:@"userPassword"] isEqualToString:tfPassword.text]) {
            [delegate showAlert:@"Current password is incorrect"];
            return;
        }
        if ([tfNewPass.text isEqualToString:@""]) {
            [delegate showAlert:@"Please input new password"];
            return;
        }
        if ([tfConfirmNewPass.text isEqualToString:@""]) {
            [delegate showAlert:@"Please input confirm new password"];
            return;
        }
//        if([tfNewPass.text length]<6 || [tfNewPass.text length]>15) {
//            [delegate showAlert:@"New password must have from 6 to 15 characters"];
//            return;
//        }
        if (![tfConfirmNewPass.text isEqualToString:tfNewPass.text]) {
            [delegate showAlert:@"Confirm password did not match"];
            return;
        }
    }
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Common showNetworkFailureAlert];
    } else {
        [self performSelector:@selector(afterClickSave) withObject:nil afterDelay:1.0];
    }
}
- (UIImage*)loadImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageUser.png"];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}
- (void) pushView:(UIViewController*)viewController{
    IntroViewController *vc = (IntroViewController*)viewController;
    [vc goMainScreen];
}
- (IBAction)btnDeleteAvatarClick:(id)sender {
    btnDeleteAvatar.hidden = YES;
    isAddAvatar = FALSE;
    [asynImgPhoto loadIMageFromImage:[UIImage imageNamed:@"defaultAvatar.jpeg"]];
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

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 150, self.view.frame.size.width, self.view.frame.size.height);
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 150, self.view.frame.size.width, self.view.frame.size.height);
}

@end
