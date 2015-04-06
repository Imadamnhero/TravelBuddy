//
//  AlertVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "AlertVC.h"

@interface AlertVC ()

@end

@implementation AlertVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) getAllUser{
    [mainArray removeAllObjects];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int tripId = [[userDefault objectForKey:@"userTripId"] intValue];
    
    @synchronized(self)
    {
        mainArray = [sqliteManager getUserInfor:tripId];
    }
    
    if (SCREEN_HEIGHT >480) {
        if (mainArray.count <8 && mainArray.count >0) {
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*73);
        }
    }else{
        if (mainArray.count <7 && mainArray.count >0) {
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*73);
        }
    }
    //    [self getUserInfor];
    mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*60+40);
    [mainTable reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sqliteManager = [[IMSSqliteManager alloc] init];
    imageDownloadsInProgress = [[NSMutableDictionary alloc] init];
    float main_top = 0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        main_top = 0;
    }
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    
    mainArray = [[NSMutableArray alloc] init];
    bgImgView.layer.cornerRadius = 4.0;
    isSelectAll = FALSE;
    
    [self getAllUser];
    
    txtContent.text = @"Type";
    txtContent.textColor = [UIColor lightGrayColor];
    txtContent.delegate = self;
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([txtContent.text isEqualToString:@"Type"]) {
        txtContent.text = @"";
    }
    txtContent.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(txtContent.text.length == 0){
        txtContent.textColor = [UIColor lightGrayColor];
        txtContent.text = @"Type";
        [txtContent resignFirstResponder];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if(txtContent.text.length == 0){
        txtContent.textColor = [UIColor lightGrayColor];
        txtContent.text = @"Type";
        [txtContent resignFirstResponder];
    }
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

- (IBAction)btnSendAlert:(id)sender {
    if ([txtContent.text isEqualToString:@"Type"] || [txtContent.text isEqualToString:@""]) {
        [delegate showAlert:@"Please type an alert."];
        return;
    }else{
        [self.view endEditing:YES];
        BOOL isHaveChooseSomeone = FALSE;
        for (int i = 0 ; i < mainArray.count; i++) {
            User *obj  = [mainArray objectAtIndex:i];
            int status = obj.isCheck;
            if (status == 1) {
                isHaveChooseSomeone = TRUE;
                break;
            }
        }
        if (!isHaveChooseSomeone) {
            [delegate showAlert:@"Please choose someone to send your alert"];
            return;
        }
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus = [reach currentReachabilityStatus];
        
        if (netStatus == NotReachable) {
            [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
        }else{
            viewConfirmSendAlert.hidden = NO;
        }
    }
}

- (IBAction)btnYesClick:(id)sender {
    viewConfirmSendAlert.hidden = YES;
    [self afterClickSendAlert];
//    [delegate showAlert:@"Your alert was sent"];
}

- (IBAction)btnNoClick:(id)sender {
    viewConfirmSendAlert.hidden = YES;
}
- (void) afterClickSendAlert{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    //get array user who has been sent alert
    NSMutableArray *arrayUserId = [[NSMutableArray alloc] init];
    for (int i = 0; i < mainArray.count ; i++) {
        User *userObj = [mainArray objectAtIndex:i];
        if (userObj.isCheck == 1) {
            [arrayUserId addObject:[NSNumber numberWithInt:userObj.userInTripId]];
        }
    }
    //set json_obj to post on server
    
    int userId = [[userDef objectForKey:@"userId"] intValue];
   
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc] init];
    [dictPost setObject:[NSNumber numberWithInt:userId] forKey:@"senderid"];
    [dictPost setObject:arrayUserId forKey:@"receiverid"];
    [dictPost setObject:txtContent.text forKey:@"content"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *kURLString = [NSString stringWithFormat:@"%@/send_alert.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [request startSynchronous];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSError *error2 = [request error];
        if (!error2) {
            NSLog(@"NO error");
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"alert dict %@",dict);
            if (dict != nil) {
                if ([[dict objectForKey:@"success"] intValue] == 1) {
                    [delegate showAlert:[dict objectForKey:@"message"]];
                }
            }
//            else{
//                [delegate showAlert:@"Fail to send your alert."];
//            }
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [delegate showAlert:@"Your alert was sent"];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return mainArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row==0) {
//        return 40;
//    }else
        return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
//    NSDictionary *dict = [mainArray objectAtIndex:indexPath.row];

    User *Obj = [mainArray objectAtIndex:indexPath.row];
    
    //image
    NSData *imgData = [sqliteManager image:[NSString stringWithFormat:@"User_%d",Obj.userId]];
    
    Obj.userIcon =  [UIImage imageWithData:imgData scale:1];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5 , 50, 50)];
    imgView.clipsToBounds=YES;
    [cell.contentView addSubview:imgView];
    if (!Obj.userIcon)
    {
        if (mainTable.dragging == NO && mainTable.decelerating == NO && ![Obj.avatarUrl isEqualToString:@"NA"])
        {
            [self startIconDownload:Obj forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        imgView.image = [UIImage imageNamed:@"bg_img_default.png"];
        
    } else
    {
        if(Obj.userIcon.size.width ==0)
        {
            //  cell.imgNote.image = [UIImage imageNamed:@"bg_img_default.png"];
        }
        else
        {
            imgView.image =  Obj.userIcon;//[delegate thumbWithSideOfLength:50:Obj.userIcon];
        }
    }
    
//    NSString* strImageName = [dict objectForKey:@"imageName"];
//    UIImage *imageUser = [UIImage imageNamed:strImageName];
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5 , 50, 50)];
//    imgView.image = imageUser; //[Common thumbWithSideOfLength:50:imageUser];
//    //    imgView.layer.cornerRadius = 1.0f;
//    imgView.clipsToBounds=YES;
//    [cell.contentView addSubview:imgView];
    
    NSString* strName = Obj.name;
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(65, 15, 200, 21)];
    lblDescription.text = strName;
    [lblDescription setFont:[UIFont boldSystemFontOfSize:17]];
    [cell.contentView addSubview:lblDescription];
    
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(260, 15, 30, 30)];
    btnCheck.tag = indexPath.row + 5001;
    [btnCheck addTarget:self action:@selector(checkBoxSelected:) forControlEvents:UIControlEventTouchUpInside];
    NSString* strStatus =@"unSelectedCheckbox.png";
    if (Obj.isCheck == 1) {
        strStatus = @"selectedCheckbox.png";
    }
    [btnCheck setImage:[UIImage imageNamed:strStatus] forState:UIControlStateNormal];
    [cell.contentView addSubview:btnCheck];
    
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    /* Create custom view to display section header... */
    
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
    btnCheck.tag = 5000;
    [btnCheck addTarget:self action:@selector(checkBoxSelected:) forControlEvents:UIControlEventTouchUpInside];
    NSString* strStatus =@"unSelectedCheckbox.png";
    if (isSelectAll) {
        strStatus = @"selectedCheckbox.png";
    }
    [btnCheck setImage:[UIImage imageNamed:strStatus] forState:UIControlStateNormal];
    [view addSubview:btnCheck];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 200, 21)];
    lblTitle.text = @"Send to everyone";
    [lblTitle setFont:[UIFont boldSystemFontOfSize:17]];
    [view addSubview:lblTitle];
    
    return view;
}
#pragma mark - Table view delegate
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [mainArray removeObjectAtIndex:indexPath.row];
//        mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*60+40);
//        [mainTable reloadData];
//    }
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *obj = [mainArray objectAtIndex:indexPath.row];
    int status = 1;
    if (obj.isCheck == 1) {
        status = 0;
    }
    obj.isCheck = status;
    
    BOOL selectAll = TRUE;
    for (int i = 0; i < mainArray.count; i++) {
        User *obj = [mainArray objectAtIndex:i];
        if (obj.isCheck == 0) {
            selectAll = false;
            break;
        }
    }
    if (selectAll) {
        isSelectAll = TRUE;
    }else
        isSelectAll = false;
    
    [mainTable reloadData];
}
// action event of check box
- (void)checkBoxSelected:(id)sender{
    UIButton *btn = (UIButton*)sender;
    int tag = btn.tag - 5000;
    if (tag == 0) {
        //all check box is selected
        for (int i = 0 ; i < mainArray.count; i++) {
            User *obj = [mainArray objectAtIndex:i];
            int status = 1;
            if (isSelectAll) {
                status = 0;
            }
            obj.isCheck = status;
        }
        isSelectAll = !isSelectAll;
    }else{
        // select or unselect one user
        User *obj = [mainArray objectAtIndex:tag-1];
        int status = 1;
        if (obj.isCheck == 1) {
            status = 0;
        }
        obj.isCheck = status;
        
        BOOL selectAll = TRUE;
        for (int i = 0; i < mainArray.count; i++) {
            User *obj = [mainArray objectAtIndex:i];
            if (obj.isCheck == 0) {
                selectAll = false;
                break;
            }
        }
        if (selectAll) {
            isSelectAll = TRUE;
        }else
            isSelectAll = false;
    }
    [mainTable reloadData];
}

#pragma mark - Downloader
- (void)startIconDownload:(User*)userImg forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = imageDownloadsInProgress[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.userObj = userImg;
        iconDownloader.delegate = self;
        imageDownloadsInProgress[indexPath] = iconDownloader;
        
        NSString *imageURL = [NSString stringWithFormat:@"%@%@",SERVER_LINK,userImg.avatarUrl];
        
        [iconDownloader startNoteIconDownload:imageURL];
    }
}
#pragma mark - Downloader delegate
// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([mainArray count] > 0) {
        NSArray *visiblePaths = [mainTable indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths) {
            
            User *Obj = mainArray[indexPath.row];
            NSData *imgData = [sqliteManager image:[NSString stringWithFormat:@"User_%d",Obj.userId]];
            
            Obj.userIcon = [UIImage imageWithData:imgData];
            
            if (!Obj.userIcon && ![Obj.avatarUrl isEqualToString:@""]) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:Obj forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = imageDownloadsInProgress[indexPath];
    if (iconDownloader != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* tmpImg;
            @synchronized(self)
            {
                //                IMSSqliteManager *sqliteMngr = [[IMSSqliteManager alloc] init];
                [sqliteManager createTable:@"AppImages"];
                
                tmpImg = iconDownloader.userObj.userIcon;
                [sqliteManager saveImage:[NSString stringWithFormat:@"User_%d",iconDownloader.userObj.userId] Image:tmpImg];
            }
            
            // Display the newly loaded image
            UITableViewCell *cell = (UITableViewCell*)[mainTable cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            if (tmpImg.size.height == 0)
            {
                UIImage *img = [UIImage imageNamed:@"bg_img_default.png"];
                cell.imageView.image = img;
            }
            else
            {
                cell.imageView.image = iconDownloader.userObj.userIcon;//[delegate thumbWithSideOfLength:50:iconDownloader.userObj.userIcon];
                
            }
            
        });
    }
    
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [imageDownloadsInProgress removeObjectForKey:indexPath];
}
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
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
