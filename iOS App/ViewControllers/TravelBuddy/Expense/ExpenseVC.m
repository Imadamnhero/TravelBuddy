//
//  ExpenseVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "ExpenseVC.h"
#import "AddExpenseVC.h"
#import "PCPieChart.h"
#import "TripDetailVC.h"

@interface ExpenseVC ()

@end

@implementation ExpenseVC
@synthesize numberRow;
@synthesize isEnte,isFood,isTaxi,isBussiness,isGift,isShopping;
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
    numberRow = 0;
    // Do any additional setup after loading the view from its nib.
    sqliteManager = [[IMSSqliteManager alloc] init];
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
    arrayExpense = [[NSMutableArray alloc] init];
    
//    [self drawRect:bgImageLinePercentBudget.frame];
    bgImgBudgetView.layer.cornerRadius = bgImgCircleView.layer.cornerRadius = 4.0;
    
    lineLeftShopping = [[UIImageView alloc] init];
    lineLeftGifts    = [[UIImageView alloc] init];
    lineLeftBusiness = [[UIImageView alloc] init];
    
    CGRect rectEnt = lineLeftTaxi.frame;
    rectEnt.origin.y += rectEnt.size.height;
    lineLeftShopping.frame = rectEnt;
    
    rectEnt.origin.y += rectEnt.size.height;
    lineLeftGifts.frame = rectEnt;
    
    rectEnt.origin.y += rectEnt.size.height;
    lineLeftBusiness.frame = rectEnt;
    
    lineLeftShopping.backgroundColor = PCColorGreen;
    lineLeftGifts.backgroundColor = PCColorOrange;
    lineLeftBusiness.backgroundColor = PCColorLightBlue;
    
    
    CGRect rect = mainTable.frame;
    rect.size.height = mainArray.count*40;
    mainTable.frame = rect;
    [mainScroll setContentSize:CGSizeMake(320, mainTable.frame.origin.y + mainTable.frame.size.height + 100)];
    
    mainTable.allowsSelectionDuringEditing = YES;
    
    [budgetAmount setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:17.f]];
    [lblBudgetAmount setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:17.f]];
    [spentAmout setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
    [lblSpentAmount setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
    [remainingAmount setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
    [lblRemainingAmount setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:14.f]];
}
- (void) drawSpent{

    float sumAmount = 0;
    for (int i = 0; i < arrayExpense.count; i++) {
        ExpenseObj *expenseObj = [arrayExpense objectAtIndex:i];
        sumAmount += [expenseObj.money floatValue];
    }
    NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
//    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    for (int i = 0 ; i < mainArray.count; i++) {
        CategoryObj *objCat = [mainArray objectAtIndex:i];
        NSMutableArray *arrayEx = [sqliteManager getExpenses:objCat.categoryId];
        if (arrayEx.count == 0) {
            [indexesToDelete addIndex:i];
            continue;
        }
        float sum = 0;
        //    if (sum != 0) {
        //        strPercentEnt = [NSString stringWithFormat:@"%0.2f",sumEnt/sum*100];
        //    }
        for (int j = 0 ; j < arrayEx.count ; j++) {
            ExpenseObj *expenseObj = [arrayEx objectAtIndex:j];
            sum += [expenseObj.money floatValue];
        }
        objCat.amount = [NSString stringWithFormat:@"%0.2f",sum];
        objCat.percent = [NSString stringWithFormat:@"%0.2f",sum/sumAmount*100];
        objCat.numberItem = arrayEx.count;
        objCat.arrayExp = arrayEx;
    }
    [mainArray removeObjectsAtIndexes:indexesToDelete];
    
    spentAmout.text = [NSString stringWithFormat:@"$ %0.2f",sumAmount];
    float numberRemaining = [[budgetAmount.text substringFromIndex:2] floatValue] - sumAmount;
    remainingAmount.text = [NSString stringWithFormat:@"$ %0.2f",numberRemaining];
    [self drawRect:bgImageLinePercentBudget.frame];
    
//    [mainTable reloadData];
    // draw color line at left
    [self drawRectLineLeftTable];
    
    if (sumAmount != 0) {
        [self drawCircle:mainArray];
    }else{
        for (UIView *subView in viewCirclePercent.subviews) {
            if (subView.tag == 100) {
                [subView removeFromSuperview];
            }
        }
        [self.view bringSubviewToFront:lblNoExpenseAdded];
    }
}
- (void) getListColor{
    if (mainArray.count > delegate.arrayColor.count) {
        NSMutableArray  *arrayColorDB = [NSMutableArray array];
        @synchronized(self)
        {
            //get trip infor to get budget
            arrayColorDB  = [sqliteManager getColor];
        }
        for (int i = 0; i < arrayColorDB.count; i++) {
            NSDictionary *dictColor = [arrayColorDB objectAtIndex:i];
            NSString *strColor = [dictColor objectForKey:@"color"];
            [delegate.arrayColor addObject:strColor];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [arrayExpense removeAllObjects];
    [mainArray removeAllObjects];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    @autoreleasepool {
//        IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
        @synchronized(self)
        {
            //get trip infor to get budget
            TripObj *tripInfor  = [[sqliteManager getTripInfor:[[userDefault objectForKey:@"userTripId"] intValue]] objectAtIndex:0];
            budgetAmount.text = [NSString stringWithFormat:@"$ %@",tripInfor.budget];
            //get all category
            mainArray = [sqliteManager getCategoryList];
            //get all expenses
            arrayExpense = [sqliteManager getExpenses:0];
        }
    }
    [self getListColor];
    mainTable.allowsSelectionDuringEditing = YES;
    [self drawSpent];
}

- (void) drawCircle:(NSMutableArray*)arrayInfor{
    for (UIView *subView in viewCirclePercent.subviews) {
        if (subView.tag == 100) {
            [subView removeFromSuperview];
        }
    }
    
    int height = viewCirclePercent.frame.size.width/3*2.;
    int width = viewCirclePercent.frame.size.width;
    PCPieChart* pieChart = [[PCPieChart alloc] initWithFrame:CGRectMake((viewCirclePercent.frame.size.width-width)/2,(viewCirclePercent.frame.size.height-height)/2,width,height)];
    pieChart.tag = 100;
    [pieChart setShowArrow:NO];
    [pieChart setSameColorLabel:YES];
    [pieChart setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [pieChart setDiameter:width/2];
    [viewCirclePercent addSubview:pieChart];
    
//    NSString *sampleFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"sample_piechart_data.plist"];
//    NSDictionary *sampleInfo = [NSDictionary dictionaryWithContentsOfFile:sampleFile];
    NSMutableArray *components = [NSMutableArray array];
    for (int i=0; i<[arrayInfor count]; i++)
    {
        CategoryObj *objCate = [arrayInfor objectAtIndex:i];
        PCPieComponent *component = [PCPieComponent pieComponentWithTitle:objCate.title value:[objCate.amount floatValue]];
        [components addObject:component];
        UIColor *color = [UIColor colorWithHexString:[delegate.arrayColor objectAtIndex:objCate.categoryId -1]];
        [component setColour:color];
//        if (i==0)
//        {
//            [component setColour:PCColorBlue];
//        }
//        else if (i==1)
//        {
//            [component setColour:PCColorViolet];
//        }
//        else if (i==2)
//        {
//            [component setColour:PCColorYellow];
//        }
//        else if (i==3)
//        {
//            [component setColour:PCColorGreen];
//        }
//        else if (i==4)
//        {
//            [component setColour:PCColorOrange];
//        }
//        else if (i==5)
//        {
//            [component setColour:PCColorLightBlue];
//        }
    }
    [pieChart setComponents:components];
}

- (void)drawRect:(CGRect)rect {
    bgImageLinePercentBudget.layer.cornerRadius = 3.0;
    float numberBudget = [[budgetAmount.text substringFromIndex:2] floatValue];
    if (numberBudget == 0) {
        numberBudget = 2200;
    }
    float numberSpent = [[spentAmout.text substringFromIndex:2] floatValue];
    float percent = numberSpent/numberBudget;
    if (percent>1) {
        percent = 1;
    }
    rect.size.width = 300*percent;
    bgImageLinePercentBudget.frame = rect;
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

- (IBAction)AddNewExpensiveClick:(id)sender {
    AddExpenseVC *addExpensiveController = [[AddExpenseVC alloc] initWithNibName:@"AddExpenseVC" bundle:nil parent:self];
    addExpensiveController.budget = [[budgetAmount.text substringFromIndex:2] floatValue];
    [self.navigationController pushViewController:addExpensiveController animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return mainArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CategoryObj *catObj = [mainArray objectAtIndex:section];
    if (catObj.numberItem == 0 || catObj.isChecked == 0) {
        return 0;
    }else
        return catObj.numberItem;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    //    if (cell == nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //    }
    
    
    CategoryObj *cateObj   = [mainArray objectAtIndex:indexPath.section];
    ExpenseObj *expenseObj = [cateObj.arrayExp objectAtIndex:indexPath.row];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 21)];
    lblTitle.text = [NSString stringWithFormat:@"%@",expenseObj.item];
    [lblTitle setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:13.f]];
    lblTitle.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:lblTitle];
    
    
    UILabel *lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(125, 5, 70, 21)];
    lblPrice.text = [NSString stringWithFormat:@"$ %@",expenseObj.money];
    lblPrice.textAlignment = NSTextAlignmentRight;
    [lblPrice setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:13.f]];
    lblPrice.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:lblPrice];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:expenseObj.dateTime];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    dateFormatter.dateFormat = @"M-d-yyyy";
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(200, 5,100, 21)];
    lblDate.text = [NSString stringWithFormat:@"%@",strDate];
    lblDate.textAlignment = NSTextAlignmentRight;
    [lblDate setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:13.f]];
    lblDate.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:lblDate];
    
    cell.textLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row %2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:57/255.0 green:56/255.0 blue:57/255.0 alpha:1.0];
    }else
        cell.backgroundColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0];
    
    UIImageView *lineLeftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 6, 30)];
    lineLeftView.backgroundColor = [UIColor colorWithHexString:[delegate.arrayColor objectAtIndex:cateObj.categoryId-1]];
    [cell addSubview:lineLeftView];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    UIImage *imgBgCell = [UIImage imageNamed:@"bgImgCell.png"];
    UIImageView *imgCelBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    imgCelBgView.image = imgBgCell;
    [view addSubview:imgCelBgView];
    
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    /* Create custom view to display section header... */
    CategoryObj *obj = [mainArray objectAtIndex:section];
    //add line left color
    UIImageView *lineLeftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 6, view.frame.size.height)];
    lineLeftView.backgroundColor = [UIColor colorWithHexString:[delegate.arrayColor objectAtIndex:obj.categoryId-1]];
    [view addSubview:lineLeftView];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, 110, 22)];
    lblTitle.textColor = [UIColor darkGrayColor];
//    if (mainArray.count >0) {
    lblTitle.text = obj.title;
//    }
    [lblTitle setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:15.f]];
    [view addSubview:lblTitle];
    
    UILabel *lblTotal = [[UILabel alloc] initWithFrame:CGRectMake(125, 9, 155, 22)];
    lblTotal.textAlignment = NSTextAlignmentRight;
    lblTotal.textColor = [UIColor darkGrayColor];
    lblTotal.text = [NSString stringWithFormat:@"$ %@ (%@%%)",obj.amount,obj.percent];
    [lblTotal setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:15.f]];
    [view addSubview:lblTotal];
    
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    btnCheck.tag = section + 5000;
    btnCheck.backgroundColor = [UIColor clearColor];
    [btnCheck addTarget:self action:@selector(checkBoxSelected:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnCheck];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
// action event of check box
- (void)checkBoxSelected:(id)sender{
    UIButton *btn = (UIButton*)sender;
    int tag = btn.tag - 5000;
    int numRow = 0;
    CGRect rect = mainTable.frame;
    CategoryObj *obj = [mainArray objectAtIndex:tag];
    numRow = obj.numberItem;
    if (obj.isChecked == 0) {
        obj.isChecked = 1;
        rect.size.height += numRow*30;
    }else{
        obj.isChecked = 0;
        rect.size.height -= numRow*30;
    }
    
    //reset frame table
    
    mainTable.frame = rect;
    
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    if (mainRect.size.height > 480) {
        [mainScroll setContentSize:CGSizeMake(320, mainTable.frame.origin.y + mainTable.frame.size.height + 10)];
    }else
        [mainScroll setContentSize:CGSizeMake(320, mainTable.frame.origin.y + mainTable.frame.size.height + 100)];
    
    [mainTable reloadData];
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        CategoryObj *cateObj   = [mainArray objectAtIndex:indexPath.section];
        ExpenseObj *expenseObj = [cateObj.arrayExp objectAtIndex:indexPath.row];
        expenseObj.flag = 3;
        @synchronized(self)
        {
            [sqliteManager updateExpense:expenseObj];
        }
        [self viewWillAppear:YES];
        
        //check connection internet and sync expense
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus = [reach currentReachabilityStatus];
        if (netStatus == NotReachable) {
            //        [Common showNetworkFailureAlert];
        } else {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // sync expense
                [userDef setObject:@"0" forKey:@"syncExpense"];
                [userDef synchronize];
                [TripDetailVC SyncExpenseData];
            });
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (void) drawRectLineLeftTable{
    
    //reset frame table
    CGRect rect = mainTable.frame;
    rect.size.height = numberRow*30 + mainArray.count*40;
    mainTable.frame = rect;
    
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    if (mainRect.size.height > 480) {
        [mainScroll setContentSize:CGSizeMake(320, mainTable.frame.origin.y + mainTable.frame.size.height + 10)];
    }else
        [mainScroll setContentSize:CGSizeMake(320, mainTable.frame.origin.y + mainTable.frame.size.height + 100)];

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
