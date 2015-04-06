//
//  CustomeListVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "CustomeListVC.h"
#import "NewListVC.h"
#import "TripDetailVC.h"

@interface CustomeListVC ()

@end

@implementation CustomeListVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(id)_parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        parent = _parent;
    }
    return self;
}

- (IBAction)btnYesClick:(id)sender {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    int packingId = 0;
    @synchronized(self)
    {
        [sqliteManager createTable:@"PackingTitles"];
        [sqliteManager createTable:@"PackingItems"];
        PackingTitleObj *packObj = [[PackingTitleObj alloc] init];
        packObj.title = tfListName.text;
        packObj.serverId = 0;
        packObj.ownerUserId = [[userDef objectForKey:@"userId"] intValue];
        packObj.flag = 1;
        packingId += [sqliteManager addPackingTitleInfor:packObj];
        [sqliteManager updateServerIdPackingTitle:packingId withServerId:packingId];
    }
    
    [self SaveNewCustomList:packingId];
    [delegate showAlert:@"Your list was saved successful"];
    [self.navigationController popViewControllerAnimated:YES];
    
}
//save new custome list
- (void) SaveNewCustomList:(int)packingId{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    for (int i = 0; i < mainArray.count; i++) {
        PackingItemObj *packObj = [[PackingItemObj alloc] init];
        packObj = [mainArray objectAtIndex:i];
        packObj.packingId = packingId;
        packObj.idAddNew  = packingId;
        @synchronized(self)
        {
            [sqliteManager addPackingItemInfor:packObj];
        }
    }
    //sync
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        //        [Common showNetworkFailureAlert];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //sync packing title
            [userDef setObject:@"0" forKey:@"syncPackingTitle"];
            [userDef synchronize];
            [TripDetailVC SyncPackingTitleData];
        });
    }
}

- (IBAction)btnNoClick:(id)sender {
    viewSaveList.hidden = YES;
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
    
    mainArray = [[NSMutableArray alloc] init];
    bgImgAddItemView.layer.cornerRadius = bgImgListItemView.layer.cornerRadius = bgImgListTitleView.layer.cornerRadius = 4.0;
    mainTable.allowsSelectionDuringEditing = YES;
    mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
    
    if ([parent isKindOfClass:[NewListVC class]]) {
        viewAddItem.hidden = YES;
        
        CGRect rectList = viewListItem.frame;
        rectList.origin.y = rectList.origin.y - 86;
        viewListItem.frame = rectList;
        
        CGRect rectTable = mainTable.frame;
        rectTable.origin.y = rectTable.origin.y - 86;
        mainTable.frame = rectTable;
    }
    btnHome.imageEdgeInsets = UIEdgeInsetsMake(7, 12, 7, 8);
//    [self getArrayListItem];
}

//get array list item
- (void)getArrayListItem{
    [mainArray removeAllObjects];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        mainArray = [sqliteManager getPackingItems:0];
    }
    if (mainArray.count < 7 && mainArray.count >0) {
         mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
    }
    [mainTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnHomeClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    return;
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

- (IBAction)btnAddItemClick:(id)sender {
    if (![tfNewItem.text isEqualToString:@""]) {
        NSString *strItem = [tfNewItem.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (strItem.length == 0) {
            UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:@"Please input valid item" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [dialog show];
            return;
        }
        [self AddNewItem];
    }else{
        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:@"Please input item name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [dialog show];
        return;
    }
    [mainTable reloadData];
}
//add new item
- (void) AddNewItem{
    PackingItemObj *itemObj = [[PackingItemObj alloc] init];
    itemObj.itemName = tfNewItem.text;
    itemObj.isCheck = 0;
    itemObj.packingId = -1;
    itemObj.serverId = 0;
    itemObj.flag = 1;
    [mainArray addObject:itemObj];
    tfNewItem.text = @"";
    if (SCREEN_HEIGHT > 480) {
        if (mainArray.count > 0 && mainArray.count <8) {
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
        }
    }else{
        if (mainArray.count > 0 && mainArray.count <6) {
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
        }
    }
}
- (IBAction)btnSaveClick:(id)sender {
   
    if ([tfListName.text isEqualToString:@""] ) {
        [delegate showAlert:@"Please input list title"];
        return;
    }
    NSString* strDes = [tfListName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (strDes.length == 0) {
        [delegate showAlert:@"Please input data"];
        return;
    }else{
        [self.view endEditing:YES];
        if (mainArray.count == 0) {
            [delegate showAlert:@"Please input item"];
            return;
        }else
            viewSaveList.hidden = NO;
    }
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
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    PackingItemObj *packObj = [[PackingItemObj alloc] init];
    packObj = [mainArray objectAtIndex:indexPath.row];
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(55, 12, 200, 21)];
    lblDescription.text = [NSString stringWithFormat:@"%@",packObj.itemName];//@"Description";
    [lblDescription setFont:[UIFont boldSystemFontOfSize:15]];
    [cell.contentView addSubview:lblDescription];
    
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(7, 7, 30, 30)];
    btnCheck.tag = indexPath.row + 5000;
    [btnCheck addTarget:self action:@selector(checkBoxSelected:) forControlEvents:UIControlEventTouchUpInside];
    NSString* strStatus =@"unSelectedCheckbox.png";
    if (packObj.isCheck == 1) {
        strStatus = @"selectedCheckbox.png";
    }
    [btnCheck setImage:[UIImage imageNamed:strStatus] forState:UIControlStateNormal];
    [cell.contentView addSubview:btnCheck];
    
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [mainArray removeObjectAtIndex:indexPath.row];
        if (mainArray.count <7 && mainArray.count >0) {
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
        }
        [mainTable reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSMutableDictionary *dict = [mainArray objectAtIndex:indexPath.row];
//    NSString *strStatus = @"1";
//    if ([[dict objectForKey:@"status"] intValue] == 1) {
//        strStatus = @"0";
//    }
//    [dict setValue:strStatus forKey:@"status"];
    
    PackingItemObj *packObj = [[PackingItemObj alloc] init];
    packObj = [mainArray objectAtIndex:indexPath.row];
    int status = 1;
    if (packObj.isCheck == 1) {
        status = 0;
    }
    packObj.isCheck = status;
    [mainTable reloadData];
}

// action event of check box
- (void)checkBoxSelected:(id)sender{
    UIButton *btn = (UIButton*)sender;
    int tag = btn.tag - 5000;
    PackingItemObj *packObj = [[PackingItemObj alloc] init];
    packObj = [mainArray objectAtIndex:tag];
    int status = 1;
    if (packObj.isCheck == 1) {
        status = 0;
    }
    packObj.isCheck = status;
//    [packObj setValue:strStatus forKey:@"status"];
    [mainTable reloadData];
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
