//
//  GroupVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "GroupVC.h"
#import "InviteGroupVC.h"
#import "CellGroup.h"

@interface GroupVC ()

@end

@implementation GroupVC

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
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*60);
        }else{
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,SCREEN_HEIGHT - 10 - mainTable.frame.origin.y);
        }
    }else{
        if (mainArray.count <7 && mainArray.count >0) {
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*60);
        }else{
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,SCREEN_HEIGHT - 10 - mainTable.frame.origin.y);
        }
    }
    //    [self getUserInfor];
//    mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*60);
//    [mainTable reloadData];
    [mainTable performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:NO];
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
    bgImgGroup.layer.cornerRadius = 4.0;
    mainTable.allowsSelectionDuringEditing = YES;
}
- (void)viewWillAppear:(BOOL)animated{
    [self getAllUser];
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

- (IBAction)btnInviteGroup:(id)sender {
    InviteGroupVC *inviteGroupController = [[InviteGroupVC alloc] initWithNibName:@"InviteGroupVC" bundle:nil];
    [self.navigationController pushViewController:inviteGroupController animated:YES];
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
    static NSString *indentity = @"CellGroup";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentity];
    CellGroup *cell = [tableView dequeueReusableCellWithIdentifier:indentity];
    if (cell == nil)
    {
        //   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentity];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellGroup" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}
- (void)configureCell:(CellGroup*)cell atIndexPath:(NSIndexPath*)indexPath
{
    User *Obj = [mainArray objectAtIndex:indexPath.row];
    
    cell.lbtitle.text = Obj.name;
    cell.lbtitle.font = [UIFont boldSystemFontOfSize:14];
    cell.lbtitle.numberOfLines = 1;
    
    //image
    NSData *imgData = [sqliteManager image:[NSString stringWithFormat:@"User_%d",Obj.userId]];
    
    Obj.userIcon =  [UIImage imageWithData:imgData scale:1];
    
    if (!Obj.userIcon)
    {
        if (mainTable.dragging == NO && mainTable.decelerating == NO && ![Obj.avatarUrl isEqualToString:@"NA"])
        {
            [self startIconDownload:Obj forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        cell.imgNote.image = [UIImage imageNamed:@"bg_img_default.png"];
        
    } else
    {
        if(Obj.userIcon.size.width ==0)
        {
            //  cell.imgNote.image = [UIImage imageNamed:@"bg_img_default.png"];
        }
        else
        {
            cell.imgNote.image =  Obj.userIcon;//[delegate thumbWithSideOfLength:50:Obj.userIcon];
        }
    }
    
}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [mainArray removeObjectAtIndex:indexPath.row];
//        mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*60);
//        [mainTable reloadData];
//    }
//}

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
        
        NSString *str = [userImg.avatarUrl stringByReplacingOccurrencesOfString:@"./" withString:@"/"];
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
            CellGroup *cell = (CellGroup*)[mainTable cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            if (tmpImg.size.height == 0)
            {
                UIImage *img = [UIImage imageNamed:@"bg_img_default.png"];
                cell.imgNote.image = img;
            }
            else
            {
                cell.imgNote.image = iconDownloader.userObj.userIcon;//[delegate thumbWithSideOfLength:50:iconDownloader.userObj.userIcon];
                
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [mainTable deselectRowAtIndexPath:indexPath animated:YES];
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
