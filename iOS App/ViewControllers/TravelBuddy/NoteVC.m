//
//  NoteVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#define FONT_SIZE 13.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#import "NoteVC.h"
#import "TripDetailVC.h"
#import "CellNote.h"
@interface NoteVC ()<IconDownloaderDelegate>

@end

@implementation NoteVC
@synthesize imageDownloadsInProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)getUserInfor{
    NSMutableArray *arrayUserId = [[NSMutableArray alloc] init];
    @autoreleasepool {
        for (int i = 0; i < mainArray.count ; i++) {
            NoteObj *noteObj = [[NoteObj alloc] init];
            noteObj = [mainArray objectAtIndex:i];
            [arrayUserId addObject:[NSNumber numberWithInt:noteObj.ownerUserId]];
        }
    }
    
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc] init];
    [dictPost setObject:arrayUserId forKey:@"listid"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *kURLString = [NSString stringWithFormat:@"%@/get_users_info.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [request startSynchronous];
        
        NSError *error2 = [request error];
        if (!error2) {
            NSLog(@"NO error");
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"dict %@",dict);
//            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            if ([[dict objectForKey:@"success"] intValue] == 1) {
                NSMutableArray *arrayRes = [dict objectForKey:@"data"];
                for (int i = 0; i < mainArray.count ; i++) {
                    NoteObj *noteObj = [mainArray objectAtIndex:i];
                    for (int j = 0; j < arrayRes.count;  j++) {
                        NSDictionary *dictRes = [arrayRes objectAtIndex:j];
                        if (noteObj.ownerUserId == [[dictRes objectForKey:@"userid"] intValue] ) {
                            noteObj.noteUrl = [dictRes objectForKey:@"avatarurl"];
                            noteObj.userAddNote = [NSString stringWithFormat:@"%@", [dictRes objectForKey:@"username"]];
                            break;
                        }
                    }
                }
            }
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sqlManager = [[IMSSqliteManager alloc] init];
    self.imageDownloadsInProgress = [[NSMutableDictionary alloc] init];
    objVersion = [[VersionObj alloc] init];
    @synchronized(self)
    {
        objVersion = [[sqlManager getVersion] objectAtIndex:0];
    }
    
    float main_top = 0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        main_top = 0;
    }
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    
    if (mainRect.size.height <=480) {
        subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y-60, subView.frame.size.width, subView.frame.size.height);
    }
    
    bgImgSubView.layer.cornerRadius = 4.0;
    mainArray = [[NSMutableArray alloc] init];
    mainArrayAvatar = [[NSMutableArray alloc] init];
    
    //get note from local
    [self getAllNote];
    mainTable.allowsSelectionDuringEditing = YES;
    mainTable.layer.cornerRadius = 3.0;
    
    txtContent.text = @"Content";
    txtContent.textColor = [UIColor lightGrayColor];
    txtContent.delegate = self;
    bgImgSubView.layer.cornerRadius = 4.0;
    [self removeNoti];
    [self addNoti];
}
-(void)addNoti{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncNoteSuccess) name:@"syncNoteSuccess" object:nil];
}
-(void)removeNoti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncNoteSuccess" object:nil];
}
- (void) syncNoteSuccess{
    [self getAllNote];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}
- (void) setupTable{
    NSMutableArray *arrayRes = [sqlManager getAllUserInfor:[[USER_DEFAULT objectForKey:@"userTripId"] intValue]];
    for (int i = 0; i < mainArray.count ; i++) {
        NoteObj *noteObj = [mainArray objectAtIndex:i];
        for (int j = 0; j < arrayRes.count;  j++) {
            User *userObj = [arrayRes objectAtIndex:j];
            if (noteObj.ownerUserId == userObj.userInTripId) {
                noteObj.noteUrl = userObj.avatarUrl;
                noteObj.userAddNote = userObj.name;
                break;
            }
        }
    }
    [mainTable reloadData];
}
-(void) getAllNote{
    [mainArray removeAllObjects];
    @autoreleasepool {
//        IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
        @synchronized(self)
        {
            mainArray = [sqlManager getNotes];
        }
        for (int i = mainArray.count -1 ; i >= 0 ; i--) {
            NoteObj *obj = [mainArray objectAtIndex:i];
            if (obj.flag == 3) {
                [mainArray removeObjectAtIndex:i];
            }
        }
    }
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        //        [Common showNetworkFailureAlert];
        [self setupTable];
    } else {
        NSOperationQueue *myQueue = [[NSOperationQueue alloc]init];
        [myQueue addOperationWithBlock:^{
            [self getUserInfor];
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [mainTable reloadData];
            }];
        }];
    }
   
//    [self getUserInfor];
//    [mainTable reloadData];
}
#pragma mark TEXT VIEW
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([txtContent.text isEqualToString:@"Content"]) {
        txtContent.text = @"";
    }
    txtContent.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(txtContent.text.length == 0){
        txtContent.textColor = [UIColor lightGrayColor];
        txtContent.text = @"Content";
        [txtContent resignFirstResponder];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if(txtContent.text.length == 0){
        txtContent.textColor = [UIColor lightGrayColor];
        txtContent.text = @"Content";
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

- (IBAction)btnAddNoteClick:(id)sender {
    viewAddNote.hidden = NO;
}

- (IBAction)btnSaveNoteClick:(id)sender {
    NSString *strTitle = [tfTitle.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strContent = [tfTitle.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([tfTitle.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input title"];
        return;
    }else if ([txtContent.text isEqualToString:@""] || [txtContent.text isEqualToString:@"Content"]) {
        [delegate showAlert:@"Please input content"];
        return;
    }else if (strTitle.length == 0) {
        [delegate showAlert:@"Please input valid title"];
        return;
    }else if (strContent.length == 0) {
        [delegate showAlert:@"Please input valid content"];
        return;
    }else {
        
        [self afterClickSaveNoteContent];
        
        viewAddNote.hidden = YES;
        tfTitle.text = @"";
        txtContent.text = @"Content";
        txtContent.textColor = [UIColor lightGrayColor];
        txtContent.delegate = self;
        [delegate showAlert:@"Your note was added successful"];
    }
    
//        User *userInfor = [[User alloc] init];
//        userInfor.name = [dict objectForKey:@"username"];
//        userInfor.avatarUrl = [dict objectForKey:@"avatarurl"];
//
//        IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
//        @synchronized(self)
//        {
//            [sqliteManager updateUserInfor:userInfor];
//        }
    
}
- (void) afterClickSaveNoteContent{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"M-d-yyyy HH:mm:ss";
    NSDate *date = [NSDate date];
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    NoteObj *objNote = [[NoteObj alloc] init];
    objNote.title       = tfTitle.text;
    objNote.dateTime    = strDate;
    objNote.content     = txtContent.text;
    objNote.ownerUserId = [[userDef objectForKey:@"userId"] intValue];
    objNote.tripId      = [[userDef objectForKey:@"userTripId"] intValue];
    objNote.serverId    = 0;
    objNote.flag        = 1;
    
    @synchronized(self)
    {
        [sqlManager createTable:@"Notes"];
        [sqlManager addNoteInfor:objNote];
    }
    
    [self getAllNote];
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"travel"];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
//        [Common showNetworkFailureAlert];
    } else {
//        NSOperationQueue *queueNote = [[NSOperationQueue alloc] init];
        [delegate.syncQueue addOperationWithBlock:^{
            [userDefault setObject:@"0" forKey:@"syncNote"];
            [userDefault synchronize];
            [TripDetailVC SyncNoteData];
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//                [self drawSpent];
            }];
        }];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            // sync note
////            delegate.isUpdateAvailableForNote = false;
//            [userDefault setObject:@"0" forKey:@"syncNote"];
//            [userDefault synchronize];
//            [TripDetailVC SyncNoteData];
//        });
    }
}

- (IBAction)btnCancelClick:(id)sender {
    viewConfirmCancel.hidden = NO;
}

- (IBAction)btnYesClick:(id)sender {
    viewAddNote.hidden = YES;
    viewConfirmCancel.hidden = YES;
    txtContent.text = @"Content";
    txtContent.textColor = [UIColor lightGrayColor];
    txtContent.delegate = self;
    tfTitle.text = @"";
}

- (IBAction)btnNoClick:(id)sender {
    viewConfirmCancel.hidden = YES;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        viewAddNote.hidden = YES;
        txtContent.text = @"Content";
        txtContent.textColor = [UIColor lightGrayColor];
        txtContent.delegate = self;
        tfTitle.text = @"";
    }
}
#pragma mark - Downloader
- (void)startIconDownload:(NoteObj *)noteImg forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = imageDownloadsInProgress[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.note = noteImg;
        iconDownloader.delegate = self;
        imageDownloadsInProgress[indexPath] = iconDownloader;
        //
        //NSString   *imageURL = [NSString stringWithFormat:@"http://img2.blog.zdn.vn/42937408.jpg"];
//        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        NSString *strNoteImg = noteImg.noteUrl;
        NSString *str = [strNoteImg stringByReplacingOccurrencesOfString:@"./" withString:@"/"];
        NSString *imageURL = [NSString stringWithFormat:@"%@%@",SERVER_LINK,str];

        
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
            
            NoteObj *Obj = mainArray[indexPath.row];
            NSData *imgData = [sqlManager image:[NSString stringWithFormat:@"Note_%d",Obj.ownerUserId]];

            Obj.noteIcon = [UIImage imageWithData:imgData];
            
            if (!Obj.noteIcon && ![Obj.noteUrl isEqualToString:@""]) // avoid the app icon download if the app already has an icon
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
                IMSSqliteManager *sqliteMngr = [[IMSSqliteManager alloc] init];
                [sqliteMngr createTable:@"AppImages"];
                
                tmpImg = iconDownloader.note.noteIcon;
                [sqliteMngr saveImage:[NSString stringWithFormat:@"Note_%d",iconDownloader.note.ownerUserId] Image:tmpImg];
            }
            
            // Display the newly loaded image
            CellNote *cell = (CellNote*)[mainTable cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            if (tmpImg.size.height == 0)
            {
                UIImage *img = [UIImage imageNamed:@"bg_img_default.png"];
                cell.imgNote.image = img;
            }
            else
            {
                cell.imgNote.image = [delegate thumbWithSideOfLength:50:iconDownloader.note.noteIcon];
                
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return mainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentity = @"CellNote";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentity];
    CellNote *cell = [tableView dequeueReusableCellWithIdentifier:indentity];
    if (cell == nil)
    {
        //   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentity];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellNote" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (void)configureCell:(CellNote*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NoteObj *Obj = [mainArray objectAtIndex:indexPath.row];
    
    cell.lbtitle.text = Obj.title;
    cell.lbtitle.font = [UIFont boldSystemFontOfSize:IS_IPAD?18:14];
    cell.lbtitle.numberOfLines = 1;
    
    cell.lbdescrsiption.text = Obj.content;
    cell.lbdescrsiption.font = [UIFont systemFontOfSize:IS_IPAD?17:13];
    [cell.lbdescrsiption setNumberOfLines:0];
    [cell.lbdescrsiption sizeToFit];
    
    cell.lbdescrsiption.frame = CGRectMake(cell.lbdescrsiption.frame.origin.x, cell.lbdescrsiption.frame.origin.y, 243, cell.lbdescrsiption.frame.size.height);
    
//    cell.lbdescrsiption.text = Obj.content;
////    cell.lbdescrsiption.font = [UIFont systemFontOfSize:13];
////    cell.lbdescrsiption.numberOfLines = 0;
//    [cell.lbdescrsiption setMinimumFontSize:FONT_SIZE];
//    [cell.lbdescrsiption setNumberOfLines:0];
//    [cell.lbdescrsiption setFont:[UIFont systemFontOfSize:FONT_SIZE]];
//    [cell.lbdescrsiption sizeToFit];
//    
//    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
//    CGSize size = [Obj.content sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//    [cell.lbdescrsiption setFrame:CGRectMake(cell.lbdescrsiption.frame.origin.x, cell.lbdescrsiption.frame.origin.y,243, MAX(size.height, 73.0f))];
    
    // setup date time
   
//    strDate = [strDate stringByReplacingOccurrencesOfString:@"+" withString:@"GMT+"];
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
//    NSDate *expiresDate = [dateFormat dateFromString:strDate];
//    [dateFormat setDateFormat:@"M-d-yyyy HH:mm:ss"];
//  
//    strDate = [dateFormat stringFromDate:expiresDate];
     NSString *strDate = Obj.dateTime;
     NSString *userAddNote = Obj.userAddNote;
    if ([userAddNote isEqualToString:@"(null)"] || userAddNote == NULL) {
        userAddNote = @"";
    }
    if (![strDate isEqualToString:@""]) {
        if (strDate.length == 19) {
            strDate = [NSString stringWithFormat:@"By %@ on %@ at %@",Obj.userAddNote,[strDate substringToIndex:10],[strDate substringFromIndex:11]];
        }else if (strDate.length == 18) {
            strDate = [NSString stringWithFormat:@"By %@ on %@ at %@",Obj.userAddNote,[strDate substringToIndex:9],[strDate substringFromIndex:10]];
        }else
            strDate = [NSString stringWithFormat:@"By %@ on %@ at %@",Obj.userAddNote,[strDate substringToIndex:8],[strDate substringFromIndex:9]];
    }
    
    cell.lbdatetime.text = strDate ;
    cell.lbdatetime.font = [UIFont systemFontOfSize:11];
    cell.lbdatetime.numberOfLines = 0;
    if (cell.lbdescrsiption.frame.size.height < 20) {
        [cell.lbdatetime setFrame:CGRectMake(cell.lbdatetime.frame.origin.x, cell.lbdescrsiption.frame.origin.y + cell.lbdescrsiption.frame.size.height+10,240, cell.lbdatetime.frame.size.height)];
    }else
        [cell.lbdatetime setFrame:CGRectMake(cell.lbdatetime.frame.origin.x, cell.lbdescrsiption.frame.origin.y + cell.lbdescrsiption.frame.size.height,240, cell.lbdatetime.frame.size.height)];
    //    //image
    NSData *imgData = [sqlManager image:[NSString stringWithFormat:@"Note_%d",Obj.ownerUserId]];

    Obj.noteIcon = [UIImage imageWithData:imgData];// [UIImage imageWithData:imgData scale:1];

    if (!Obj.noteIcon)
    {
        if (mainTable.dragging == NO && mainTable.decelerating == NO && ![Obj.noteUrl isEqualToString:@"NA"])
        {
            [self startIconDownload:Obj forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        cell.imgNote.image = [UIImage imageNamed:@"bg_img_default.png"];

    } else
    {
        if(Obj.noteIcon.size.width ==0)
        {
           //  cell.imgNote.image = [UIImage imageNamed:@"bg_img_default.png"];
        }
        else
        {
            cell.imgNote.image =  Obj.noteIcon; //[delegate thumbWithSideOfLength:50:Obj.noteIcon];
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float top_height_row = 73;
    
    NoteObj *Obj = [mainArray objectAtIndex:indexPath.row];
    
    UILabel *lbtitle = [[UILabel alloc] initWithFrame:CGRectMake(72, 20, 238, 0)];
    lbtitle.text = Obj.content;
    [lbtitle setNumberOfLines:0];
    [lbtitle sizeToFit];
    lbtitle.font = [UIFont systemFontOfSize:IS_IPAD?17:14];
    CGRect rectDes = lbtitle.frame;
    
//    if (rectDes.size.height > 21 && rectDes.size.height < 42)
//        top_height_row = top_height_row + lbtitle.frame.size.height - 21;
//    else
    if (rectDes.size.height > 60){
        int x = (rectDes.size.height/20) *2;
        top_height_row = top_height_row + lbtitle.frame.size.height - 41 -  x;
    }
    return top_height_row;
    
//    if (rectDes.size.height > 21) {
//        return top_height_row;
//    }else
//        return top_height_row;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if (mainArray.count > indexPath.row) {
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
            NoteObj *obj = [mainArray objectAtIndex:indexPath.row];
            if (obj.ownerUserId == [[USER_DEFAULT objectForKey:@"userId"] intValue]) {
                obj.flag = 3;
                @synchronized(self)
                {
                    [sqlManager updateNote:obj];
                }
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                //        NSUserDefaults *userDef = [[NSUserDefaults alloc] initWithSuiteName:@"travel"];
                Reachability *reach = [Reachability reachabilityForInternetConnection];
                NetworkStatus netStatus = [reach currentReachabilityStatus];
                if (netStatus == NotReachable) {
                    //        [Common showNetworkFailureAlert];
                } else {
                    NSOperationQueue *myQueue = [[NSOperationQueue alloc]init];
                    [myQueue addOperationWithBlock:^{
                        [userDef setObject:@"0" forKey:@"syncNote"];
                        [userDef synchronize];
                        [TripDetailVC SyncNoteData];
                    }];
                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                        [self getAllNote];
                    }];
                }
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }else{
                [delegate showAlert:@"Unable to delete another’s note"];
            }
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [mainTable deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark - Sync Note after delay
- (void) SyncNoteData:(NoteObj*)noteObj{
    //    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    if (appDelegate.isUpdateAvailableForNote == false) {
    //        return;
    //    }
    //    appDelegate.isUpdateAvailableForNote = false;
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    //    int syncNote = [[userDef objectForKey:@"syncNote"] intValue];
    //    if (syncNote == 1) {
    //        return;
    //    }
    //    [userDef setObject:[NSNumber numberWithInt:1] forKey:@"syncNote"];
    //    [userDef synchronize];
    // get current version
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
//    VersionObj *objVersion = [[VersionObj alloc] init];
//    @synchronized(self)
//    {
//        objVersion = [[sqliteManager getVersion] objectAtIndex:0];
//    }
    
    //get array which have update (add,edit,delete)
    NSMutableArray * noteArrayChange = [[NSMutableArray alloc] init];
    NSMutableArray * noteArrayDeleted = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:noteObj.noteId] forKey:@"clientid"];
    [dict setObject:noteObj.title forKey:@"title"];
    [dict setObject:noteObj.dateTime forKey:@"time"];
    [dict setObject:noteObj.content forKey:@"content"];
    [dict setObject:[NSNumber numberWithInt:noteObj.ownerUserId] forKey:@"ownerid"];
    [dict setObject:[NSNumber numberWithInt:noteObj.tripId] forKey:@"tripid"];
    [dict setObject:[NSNumber numberWithInt:noteObj.serverId] forKey:@"serverid"];
    [dict setObject:[NSNumber numberWithInt:noteObj.flag] forKey:@"flag"];
    
    [noteArrayChange addObject:dict];
    [noteArrayDeleted addObject:noteObj];
    //sync note data
    //    if (noteArrayChange.count > 0) {
    //set json_obj to post on server
    int tripid = [[userDef objectForKey:@"userTripId"] intValue];
    int noteVersion = objVersion.noteVersion;
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc] init];
    [dictPost setObject:[NSNumber numberWithInt:tripid] forKey:@"tripid"];
    [dictPost setObject:[NSNumber numberWithInt:noteVersion] forKey:@"client_ver"];
    [dictPost setObject:noteArrayChange forKey:@"data"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *kURLString = [NSString stringWithFormat:@"%@/sync_note.php",SERVER_LINK];
        NSURL *url = [NSURL URLWithString:kURLString];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [request startSynchronous];
        
        NSError *error2 = [request error];
        if (!error2) {
            NSLog(@"NO error");
            NSData *response = [request responseData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"note %@",dict);
            if ([[dict objectForKey:@"success"] intValue] == 0) {
                if (![[dict objectForKey:@"message"] isEqualToString:@""]) {
                    //                    [delegate showAlert:[dict objectForKey:@"message"]];
                }
            }else{
                
                //update note version in table Versions
                dispatch_async(dispatch_get_main_queue(), ^{
                    int newVersion = [[dict objectForKey:@"new_ver"] intValue];
                    objVersion.noteVersion = newVersion;
                    @synchronized(self)
                    {
                        [sqliteManager updateVersion:objVersion];
                    }
                });
                
                //update information for record in local which updated on server
                NSMutableArray *arrayCommittedData = [[NSMutableArray alloc] init];
                arrayCommittedData = [dict objectForKey:@"committed_id"];
                if (arrayCommittedData.count >0) {
                    for (int k = 0; k < arrayCommittedData.count ; k++) {
                        NSDictionary *dictCommitted = [arrayCommittedData objectAtIndex:k];
                        int clientId = [[dictCommitted objectForKey:@"clientid"] intValue];
                        int serverId = [[dictCommitted objectForKey:@"serverid"] intValue];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager updateNoteFromServer:clientId withServerId:serverId];
                            }
                        });
                        for (int e = 0; e < noteArrayDeleted.count ; e++) {
                            NoteObj *objNote = [[NoteObj alloc] init];
                            objNote = [noteArrayDeleted objectAtIndex:e];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                @synchronized(self)
                                {
                                    [sqliteManager deleteNote:objNote.noteId];
                                }
                            });
                        }
                    }
                }
                
                //get array updated from sever
                NSMutableArray *arrayUpdateData = [[NSMutableArray alloc] init];
                arrayUpdateData = [dict objectForKey:@"updated_data"];
                for (int j = 0 ; j < arrayUpdateData.count; j++) {
                    NoteObj *objNote = [[NoteObj alloc] init];
                    NSMutableDictionary *dictResponse = [arrayUpdateData objectAtIndex:j];
                    
                    objNote.title  = [dictResponse objectForKey:@"title"];
                    objNote.dateTime = [dictResponse objectForKey:@"time"];
                    objNote.content  = [dictResponse objectForKey:@"content"];
                    objNote.ownerUserId = [[dictResponse objectForKey:@"ownerid"] intValue];
                    objNote.tripId      = [[dictResponse objectForKey:@"tripid"] intValue];
                    objNote.serverId    = [[dictResponse objectForKey:@"serverid"] intValue];
                    objNote.flag        = 0;
                    
                    if ([[dictResponse objectForKey:@"flag"] intValue] == 1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager addNoteInfor:objNote];
                            }
                        });
                    }else if ([[dictResponse objectForKey:@"flag"] intValue] == 2) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager updateNote:objNote];
                            }
                        });
                        objNote.noteId = [[dictResponse objectForKey:@"clientid"] intValue];
                    }else if ([[dictResponse objectForKey:@"flag"] intValue] == 3) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self)
                            {
                                [sqliteManager deleteNote:objNote.noteId];
                            }
                        });
                        objNote.noteId = [[dictResponse objectForKey:@"clientid"] intValue];
                    }
                }
                
                //                appDelegate.isUpdateAvailableForNote = true;
                //                [userDef setObject:@"0" forKey:@"syncNote"];
                //                [userDef synchronize];
            }
        }
    }
    //    }
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
- (IBAction)btnRefreshListNote:(id)sender {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        //        [Common showNetworkFailureAlert];
    } else {
        NSOperationQueue *myQueue = [[NSOperationQueue alloc]init];
        [myQueue addOperationWithBlock:^{
            [USER_DEFAULT setObject:@"0" forKey:@"syncNote"];
            [USER_DEFAULT synchronize];
            [TripDetailVC SyncNoteData];
        }];
//        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//            [self getAllNote];
//        }];
    }
}

@end
