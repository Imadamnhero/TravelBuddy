//
//  EditListVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "EditListVC.h"
#import "TripDetailVC.h"

@interface EditListVC ()

@end

@implementation EditListVC
@synthesize strTitle,packingId;
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
    
    bgImgSubview.layer.cornerRadius = 4.0;
    mainArray = [[NSMutableArray alloc] init];
    mainArrayUpdated = [[NSMutableArray alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom1.png",@"imageName",@"Sandals",@"name",@"65",@"percent", nil];
    [mainArray addObject:dict];
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom2.png",@"imageName",@"Shoes",@"name",@"75",@"percent", nil];
    [mainArray addObject:dict1];
    NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom3.png",@"imageName",@"Bikini",@"name",@"85",@"percent", nil];
    [mainArray addObject:dict2];
    NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom3.png",@"imageName",@"Underwear",@"name",@"85",@"percent", nil];
    [mainArray addObject:dict3];
    NSMutableDictionary *dict4 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom3.png",@"imageName",@"Shorts",@"name",@"85",@"percent", nil];
    [mainArray addObject:dict4];
    [self getPackingList];
    mainTable.allowsSelectionDuringEditing = YES;
    mainTable.layer.cornerRadius = 4.0;
    lblTitle.text = strTitle;
    btnHome.imageEdgeInsets = UIEdgeInsetsMake(7, 12, 7, 8);
    number = 0;
}
- (void)getPackingList{
    [mainArray removeAllObjects];
//    [MBProgressHUD showHUDAddedTo:self.view WithTitle:nil animated:YES];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        NSLog(@"number%d",number);
        if (number < 10 ){
            number +=1;
            mainArray = [sqliteManager getPackingItems:packingId];
            mainArrayUpdated = [sqliteManager getPackingItems:packingId];
        }else
            return;
    }
    if (mainArray.count > 0) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        CGRect rectBtnSave = btnSave.frame;
        rectBtnSave.origin.y = mainTable.frame.origin.y + mainTable.frame.size.height + 10;
        btnSave.frame = rectBtnSave;
        
        CGRect rectBtnCancel = btnCancel.frame;
        rectBtnCancel.origin.y = mainTable.frame.origin.y + mainTable.frame.size.height + 10;
        btnCancel.frame = rectBtnCancel;
        
        [mainTable reloadData];
    }else {
        [self getPackingList];
    }
    
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

- (IBAction)btnAddClick:(id)sender {
    viewAddNote.hidden = NO;
}

- (IBAction)btnSaveClick:(id)sender {
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
   
    for (int i = 0 ; i < mainArrayUpdated.count; i++) {
        PackingItemObj *packObj = [[PackingItemObj alloc] init];
        packObj = [mainArrayUpdated objectAtIndex:i];
        @synchronized(self)
        {
            [sqliteManager updatePackingItem:packObj];
        }
    }
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        //        [Common showNetworkFailureAlert];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // sync packing item
            [userDef setObject:@"0" forKey:@"syncPackingItem"];
            [userDef synchronize];
            [TripDetailVC SyncPackingItemData];
        });
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCancelClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    return;
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
        if (0<mainArray.count <7) {
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
        }
        [mainTable reloadData];
        
        //update local database
        PackingItemObj *packObj = [mainArrayUpdated objectAtIndex:indexPath.row];
        packObj.flag = 3;
    }
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
    [mainTable reloadData];
    
    //update arrayUpdating
    PackingItemObj *packItemObj = [mainArrayUpdated objectAtIndex:tag];
    status = 1;
    if (packItemObj.isCheck == 1) {
        status = 0;
    }
    packItemObj.isCheck = status;
    packItemObj.flag = 2;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PackingItemObj *packObj = [[PackingItemObj alloc] init];
    packObj = [mainArray objectAtIndex:indexPath.row];
    int status = 1;
    if (packObj.isCheck == 1) {
        status = 0;
    }
    packObj.isCheck = status;
    [mainTable reloadData];
    
    //update arrayUpdating
    PackingItemObj *packItemObj = [mainArrayUpdated objectAtIndex:indexPath.row];
    status = 1;
    if (packItemObj.isCheck == 1) {
        status = 0;
    }
    packItemObj.isCheck = status;
    packItemObj.flag = 2;
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
