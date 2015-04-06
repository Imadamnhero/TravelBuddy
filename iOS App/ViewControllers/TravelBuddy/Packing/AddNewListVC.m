//
//  AddNewListVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "AddNewListVC.h"
#import "NewListVC.h"
#import "PackingVC.h"
#import "TripDetailVC.h"

@interface AddNewListVC ()

@end

@implementation AddNewListVC
@synthesize premadeListId,strTitle;

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

- (IBAction)btnCancelMethodClick:(id)sender {
    subView.hidden = YES;
}
//add new item
- (void) AddNewItem{
    PremadeItemObj *itemObj = [[PremadeItemObj alloc] init];
    itemObj.itemName = tfItemName.text;
    itemObj.isCheck = 1;
    itemObj.listId = premadeListId;
    itemObj.serverId = 0;
    itemObj.flag = 1;
    [mainArray insertObject:itemObj atIndex:0];
    tfItemName.text = @"";
    mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
    [mainTable reloadData];
}
- (IBAction)btnSaveAddItemMethodClick:(id)sender {
    if ([tfItemName.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input item name"];
        return;
    }
    NSString *strItem = [tfItemName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (strItem.length == 0) {
        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:@"Please input valid item" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [dialog show];
        return;
    }
    [self AddNewItem];
    [delegate showAlert:[NSString stringWithFormat:@"Item %@ was added",tfItemName.text]];
    subView.hidden = YES;
//    [delegate showAlert:@""];
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
    btnHome.imageEdgeInsets = UIEdgeInsetsMake(7, 12, 7, 8);
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    
    mainArray = [[NSMutableArray alloc] init];
    bgImgAddItemView.layer.cornerRadius = bgImgListItemView.layer.cornerRadius = bgImgListTitleView.layer.cornerRadius = 4.0;
    mainTable.allowsSelectionDuringEditing = YES;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom1.jpg",@"imageName",@"Sandals",@"name",@"65",@"percent", nil];
    [mainArray addObject:dict];
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom2.jpg",@"imageName",@"Shoes",@"name",@"75",@"percent", nil];
    [mainArray addObject:dict1];
    NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom3.jpg",@"imageName",@"Bikini",@"name",@"85",@"percent", nil];
    [mainArray addObject:dict2];
    NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom3.png",@"imageName",@"Underwear",@"name",@"85",@"percent", nil];
    [mainArray addObject:dict3];
    NSMutableDictionary *dict4 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom3.png",@"imageName",@"Shorts",@"name",@"85",@"percent", nil];
    [mainArray addObject:dict4];
//    mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
    [self getPremaItem];
    if ([parent isKindOfClass:[NewListVC class]]) {
        viewAddItem.hidden = YES;
        
        CGRect rectList = viewListItem.frame;
        rectList.origin.y = rectList.origin.y - 86;
        viewListItem.frame = rectList;
        
        CGRect rectTable = mainTable.frame;
        rectTable.origin.y = rectTable.origin.y - 86;
        mainTable.frame = rectTable;
    }
}
- (void)getPremaItem{
    lblTitle.text = strTitle;
    [mainArray removeAllObjects];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        mainArray = [sqliteManager getPremadeItem:premadeListId];
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
    [self.view endEditing:YES];
    viewConfirmCancel.hidden = NO;
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
    subView.hidden = NO;
}
//add new item
- (void) AddNewList{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    int packingId = 0;
    @synchronized(self)
    {
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
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[PackingVC class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}
//save new packing list
- (void) SaveNewCustomList:(int)packingId{
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    for (int i = 0; i < mainArray.count; i++) {
        PremadeItemObj *preObj  = [[PremadeItemObj alloc] init];
        preObj = [mainArray objectAtIndex:i];
        
        PackingItemObj *packObj = [[PackingItemObj alloc] init];
        packObj.itemName  = preObj.itemName;
        packObj.isCheck = preObj.isCheck;
        packObj.packingId = packingId;
        packObj.serverId = 0;
        packObj.flag = 1;
        packObj.idAddNew  = packingId;
        @synchronized(self)
        {
            [sqliteManager addPackingItemInfor:packObj];
        }
    }
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
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
- (IBAction)btnSaveClick:(id)sender {
    if ([tfListName.text isEqualToString:@""]) {
        [delegate showAlert:@"Please input list title"];
        return;
    }
    NSString *strItem = [tfListName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (strItem.length == 0) {
        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:@"Please input valid title" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [dialog show];
        return;
    }else{
        [self.view endEditing:YES];
        viewSaveList.hidden = NO;
        [self AddNewList];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex == 0){
//        [self.navigationController popViewControllerAnimated:YES];
//    }
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
    PremadeItemObj *preObj = [[PremadeItemObj alloc] init];
    preObj = [mainArray objectAtIndex:indexPath.row];
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(55, 12, 200, 21)];
    lblDescription.text = [NSString stringWithFormat:@"%@",preObj.itemName];//@"Description";
    [lblDescription setFont:[UIFont boldSystemFontOfSize:15]];
    [cell.contentView addSubview:lblDescription];
    
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(7, 7, 30, 30)];
    btnCheck.tag = indexPath.row + 5000;
    [btnCheck addTarget:self action:@selector(checkBoxSelected:) forControlEvents:UIControlEventTouchUpInside];
    NSString* strStatus =@"unSelectedCheckbox.png";
    if (preObj.isCheck == 1) {
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
    PremadeItemObj *preObj = [[PremadeItemObj alloc] init];
    preObj = [mainArray objectAtIndex:indexPath.row];
    int status = 1;
    if (preObj.isCheck == 1) {
        status = 0;
    }
    preObj.isCheck = status;
    [mainTable reloadData];
}

// action event of check box
- (void)checkBoxSelected:(id)sender{
    UIButton *btn = (UIButton*)sender;
    int tag = btn.tag - 5000;
    PremadeItemObj *preObj = [[PremadeItemObj alloc] init];
    preObj = [mainArray objectAtIndex:tag];
    int status = 1;
    if (preObj.isCheck == 1) {
        status = 0;
    }
    preObj.isCheck = status;
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

- (IBAction)btnYesClick:(id)sender {
    [delegate showAlert:@"New list was saved successful"];
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[PackingVC class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}

- (IBAction)btnNoClick:(id)sender {
    viewSaveList.hidden = YES;
}

- (IBAction)btnYesConfirmClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnNoConfirmClick:(id)sender {
    viewConfirmCancel.hidden = YES;
}
@end
