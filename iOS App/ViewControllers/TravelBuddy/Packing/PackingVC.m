//
//  PackingVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "PackingVC.h"
#import "CustomeListVC.h"
#import "NewListVC.h"
#import "KDGoalBar.h"
#import "EditListVC.h"
#import "TripDetailVC.h"

@interface PackingVC ()

@end

@implementation PackingVC

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
    
    bgImgSubView.layer.cornerRadius = 4.0;
    mainArray = [[NSMutableArray alloc] init];
    mainTable.allowsSelectionDuringEditing = YES;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [mainArray removeAllObjects];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        mainArray = [sqliteManager getPackingTitle];
    }
    for (int i = mainArray.count - 1 ; i >= 0   ; i--) {
        PackingTitleObj *packObj = [[PackingTitleObj alloc] init];
        packObj = [mainArray objectAtIndex:i];
        if (packObj.flag == 3)
            [mainArray removeObjectAtIndex:i];
    }
    if ( mainArray.count > 0) {
        for (int i = mainArray.count - 1 ; i >= 0   ; i--) {
            PackingTitleObj *packObj = [[PackingTitleObj alloc] init];
            packObj = [mainArray objectAtIndex:i];
            if (packObj.flag == 3) {
                [mainArray removeObjectAtIndex:i];
                continue;
            }
            NSMutableArray *arrayPackingItem = [[NSMutableArray alloc] init];
            @synchronized(self)
            {
                arrayPackingItem = [sqliteManager getPackingItems:packObj.serverId];
            }
            int sumCheck = 0;
            for (int j = 0;  j < arrayPackingItem.count ; j++) {
                PackingItemObj *packItemObj = [[PackingItemObj alloc] init];
                packItemObj = [arrayPackingItem objectAtIndex:j];
                if (packItemObj.isCheck == 1) {
                    sumCheck += 1;
                }
            }
            if (arrayPackingItem.count >0) {
                packObj.percent = sumCheck*100/arrayPackingItem.count;
            }
            
        }
        // reset frame of table
        if (mainArray.count <8) {
            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*50);
        }
        
        mainTable.hidden = NO;
        lblLine.hidden = lblTitleStart.hidden = lblStart.hidden = YES;
        
        CGRect rect = subViewChooseList.frame;
        rect.size.height = 55;
        subViewChooseList.frame = rect;
        
        CGRect rectBg = bgImgSubView.frame;
        rectBg.size.height = 55;
        bgImgSubView.frame = rectBg;
        
        CGRect rectCustomer = btnCustomeList.frame;
        rectCustomer.origin.y = 4;
        btnCustomeList.frame = rectCustomer;
        
        CGRect rectNew = btnNewList.frame;
        rectNew.origin.y = 4;
        btnNewList.frame = rectNew;
        
        CGRect rectOr = lblOr.frame;
        rectOr.origin.y = 4;
        lblOr.frame = rectOr;
        
        CGRect rectIconCustomer = btnIConCustomeList.frame;
        rectIconCustomer.origin.y = 10;
        btnIConCustomeList.frame = rectIconCustomer;
        
        CGRect rectIconNew = btnIconNewList.frame;
        rectIconNew.origin.y = 10;
        btnIconNewList.frame = rectIconNew;
        [mainTable reloadData];
    }else{
        lblLine.hidden = lblTitleStart.hidden = lblStart.hidden = NO;
        mainTable.hidden = YES;
        
        CGRect rect = subViewChooseList.frame;
        rect.size.height = 128;
        subViewChooseList.frame = rect;
        
        CGRect rectBg = bgImgSubView.frame;
        rectBg.size.height = 128;
        bgImgSubView.frame = rectBg;
        
        CGRect rectCustomer = btnCustomeList.frame;
        rectCustomer.origin.y = 87;
        btnCustomeList.frame = rectCustomer;
        
        CGRect rectNew = btnNewList.frame;
        rectNew.origin.y = 87;
        btnNewList.frame = rectNew;
        
        CGRect rectOr = lblOr.frame;
        rectOr.origin.y = 87;
        lblOr.frame = rectOr;
        
        CGRect rectIconCustomer = btnIConCustomeList.frame;
        rectIconCustomer.origin.y = 93;
        btnIConCustomeList.frame = rectIconCustomer;
        
        CGRect rectIconNew = btnIconNewList.frame;
        rectIconNew.origin.y = 93;
        btnIconNewList.frame = rectIconNew;
    }
    
//    if (mainArray.count == 0) {
//        lblLine.hidden = lblTitleStart.hidden = lblStart.hidden = NO;
//        mainTable.hidden = YES;
//    }else{
//        mainTable.hidden = NO;
//        lblLine.hidden = lblTitleStart.hidden = lblStart.hidden = YES;
//        
//        CGRect rect = subViewChooseList.frame;
//        rect.size.height = 55;
//        subViewChooseList.frame = rect;
//        
//        CGRect rectBg = bgImgSubView.frame;
//        rectBg.size.height = 55;
//        bgImgSubView.frame = rectBg;
//        
//        CGRect rectCustomer = btnCustomeList.frame;
//        rectCustomer.origin.y = 4;
//        btnCustomeList.frame = rectCustomer;
//        
//        CGRect rectNew = btnNewList.frame;
//        rectNew.origin.y = 4;
//        btnNewList.frame = rectNew;
//        
//        CGRect rectOr = lblOr.frame;
//        rectOr.origin.y = 4;
//        lblOr.frame = rectOr;
//        
//        CGRect rectIconCustomer = btnIConCustomeList.frame;
//        rectIconCustomer.origin.y = 10;
//        btnIConCustomeList.frame = rectIconCustomer;
//        
//        CGRect rectIconNew = btnIconNewList.frame;
//        rectIconNew.origin.y = 10;
//        btnIconNewList.frame = rectIconNew;
//        [mainTable reloadData];
//    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [mainArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    PackingTitleObj *packObj = [mainArray objectAtIndex:indexPath.row];
    
    KDGoalBar *firstGoalBar = [[KDGoalBar alloc]initWithFrame:CGRectMake(7, 7, 36, 36)];
    int percent = packObj.percent;
    [firstGoalBar setPercent:percent animated:NO];
    [cell.contentView addSubview:firstGoalBar];
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 200, 21)];
    lblDescription.text = [NSString stringWithFormat:@"%@",packObj.title];
    [lblDescription setFont:[UIFont boldSystemFontOfSize:15]];
    [cell.contentView addSubview:lblDescription];
    
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PackingTitleObj *packObj = [mainArray objectAtIndex:indexPath.row];
        [self updatePackingList:packObj];
//        [mainArray removeObjectAtIndex:indexPath.row];
//        if (mainArray.count <7 && mainArray.count >0) {
//            mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*50);
//        }
//        [mainTable reloadData];
        [self viewWillAppear:YES];
    }
}
- (void) updatePackingList:(PackingTitleObj*)objPackTitle{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    objPackTitle.flag = 3;
    @synchronized(self)
    {
        [sqliteManager updatePackingTitle:objPackTitle];
    }
    
    NSMutableArray *arrayPackingItem = [[NSMutableArray alloc] init];
    @synchronized(self)
    {
        arrayPackingItem = [sqliteManager getPackingItems:objPackTitle.serverId];
    }
    for (int j = 0;  j < arrayPackingItem.count ; j++) {
        PackingItemObj *packItemObj = [[PackingItemObj alloc] init];
        packItemObj = [arrayPackingItem objectAtIndex:j];
        packItemObj.flag = 3;
        @synchronized(self)
        {
            [sqliteManager updatePackingItem:packItemObj];
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
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PackingTitleObj *packObj = [[PackingTitleObj alloc] init];
    packObj = [mainArray objectAtIndex:indexPath.row];
    [self getPackingItem:packObj];
//    [self performSelector:@selector(getPackingItem:) withObject:(PackingTitleObj*)packObj afterDelay:2.0];
}
-(void)getPackingItem:(PackingTitleObj*)packingObj{
    EditListVC *customController = [[EditListVC alloc] initWithNibName:@"EditListVC" bundle:Nil];
    customController.packingId = packingObj.serverId;
    customController.strTitle = packingObj.title;
    [self.navigationController pushViewController:customController animated:YES];
}

// action event of check box
- (void)checkBoxSelected:(id)sender{
    UIButton *btn = (UIButton*)sender;
    int tag = btn.tag - 5000;
    if (tag == 0) {
        //all check box is selected
    }else{
        // select or unselect one user
    }
}

- (IBAction)btnCustomClick:(id)sender {
    CustomeListVC *customController = [[CustomeListVC alloc] initWithNibName:@"CustomeListVC" bundle:Nil parent:self];
    [self.navigationController pushViewController:customController animated:YES];
}

- (IBAction)btnNewListClick:(id)sender {
    NewListVC *newListController = [[NewListVC alloc] initWithNibName:@"NewListVC" bundle:Nil];
    [self.navigationController pushViewController:newListController animated:YES];
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
