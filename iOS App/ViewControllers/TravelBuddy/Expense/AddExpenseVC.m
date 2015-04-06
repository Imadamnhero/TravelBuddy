//
//  AddExpenseVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "AddExpenseVC.h"
#import "TripDetailVC.h"
#import "ExpenseVC.h"

@interface AddExpenseVC ()

@end

@implementation AddExpenseVC
@synthesize budget;
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
        // Custom initializationse
        parent = _parent;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    bgImgAmount.layer.cornerRadius = bgImgCategory.layer.cornerRadius = 4.0;
    mainArray = [[NSMutableArray alloc] init];
    currentCategory = 0;
    [self getCategoryList];
    previousCategory.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    nextCategory.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    btnHome.imageEdgeInsets = UIEdgeInsetsMake(7, 12, 7, 8);
    
    txtContent.text = @"Description";
    txtContent.textColor = [UIColor lightGrayColor];
    txtContent.delegate = self;
    
    [lblCategoryName setFont:[UIFont fontWithName:@"MyriadPro-Bold" size:17]];
}
- (void)getCategoryList{
    [mainArray removeAllObjects];
    @autoreleasepool {
        @synchronized(self)
        {
            mainArray = [sqliteManager getCategoryList];
        }
    }
    [self getCategoryName];
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([txtContent.text isEqualToString:@"Description"]) {
        txtContent.text = @"";
    }
    txtContent.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(txtContent.text.length == 0){
        txtContent.textColor = [UIColor lightGrayColor];
        txtContent.text = @"Description";
        [txtContent resignFirstResponder];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if(txtContent.text.length == 0){
        txtContent.textColor = [UIColor lightGrayColor];
        txtContent.text = @"Description";
        [txtContent resignFirstResponder];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnHomeClick:(id)sender {
    [self.view endEditing:YES];
    viewConfirmCancel.hidden = NO;
    lblContentConfirm.text = @"Are you sure you want to cancel?";
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
-(void) getCategoryName{
    if (currentCategory > 5) {
        lblCategoryName.textColor = [UIColor colorWithRed:1.0 green:155/255.0 blue:0 alpha:1.0];
    }else
        lblCategoryName.textColor = [UIColor whiteColor];
    CategoryObj *obj = [mainArray objectAtIndex:currentCategory];
    lblCategoryName.text = obj.title;
}

- (IBAction)NextCategoryClick:(id)sender {
    if (currentCategory < mainArray.count -1)
        currentCategory += 1;
    else
        currentCategory = 0;
    [self getCategoryName];
}

- (IBAction)PreviousCategoryClick:(id)sender {
    if (currentCategory >0)
        currentCategory -= 1;
    else
        currentCategory = mainArray.count-1;
    [self getCategoryName];
}
- (BOOL) compareBudget{
    BOOL isMoreBudget = FALSE;
//    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    NSMutableArray *arrayExp = [[NSMutableArray alloc] init];
    @synchronized(self)
    {
        arrayExp = [sqliteManager getExpenses:0];
    }
    
    float sumFood = 0;
    for (int i = 0; i < arrayExp.count; i++) {
        ExpenseObj *expenseObj = [[ExpenseObj alloc] init];
        expenseObj = [arrayExp objectAtIndex:i];
        sumFood += [expenseObj.money floatValue];
    }
    
//    TripObj *tripInfor     = [[TripObj alloc] init];
//    tripInfor  = [[sqliteManager getTripInfor:[[userDefault objectForKey:@"userId"] intValue]] objectAtIndex:0];
//    float budget = [tripInfor.budget floatValue];
    
    float amount = [[tfAmount.text substringFromIndex:2] floatValue] + sumFood;
    if (amount > budget) {
        isMoreBudget = TRUE;
    }
    return isMoreBudget;
}
- (IBAction)btnSaveClick:(id)sender {
    [self.view endEditing:YES];
    if ([txtContent.text isEqualToString:@""] || [txtContent.text isEqualToString:@"Description"]) {
        [delegate showAlert:@"Please enter your description"];
        return;
    }
    if ([tfAmount.text isEqualToString:@""] || [tfAmount.text isEqualToString:@"$"]) {
        [delegate showAlert:@"Please enter your amount"];
        return;
    }
    if ([self compareBudget]) {
        [delegate showAlert:@"Expense must be less than budget"];
        [self.view endEditing:YES];
        return;
    }
//    if (![self validateDecimal:[tfAmount.text substringFromIndex:2]]) {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Amount is invalid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        tfAmount.text=@"";
//        return;
//    }
    CategoryObj *currentCategoryObj = [mainArray objectAtIndex:currentCategory];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [NSDate date];
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    ExpenseObj *expInfor = [[ExpenseObj alloc] init];
    expInfor.cateId = currentCategoryObj.categoryId;
    expInfor.dateTime = strDate;
    expInfor.money  = [tfAmount.text substringFromIndex:2];
    expInfor.item = txtContent.text;
    expInfor.ownerUserId = [[userDef objectForKey:@"userId"] intValue];
    expInfor.tripId      = [[userDef objectForKey:@"userTripId"] intValue];
    expInfor.serverId    = 0;
    expInfor.flag        = 1;

//    IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        [sqliteManager createTable:@"Expenses"];
        [sqliteManager addExpenseInfor:expInfor];
    }
//    Reachability *reach = [Reachability reachabilityForInternetConnection];
//    NetworkStatus netStatus = [reach currentReachabilityStatus];
//    if (netStatus == NotReachable) {
//        //        [Common showNetworkFailureAlert];
//    } else {
//        NSOperationQueue *myQueue = [[NSOperationQueue alloc]init];
//        [myQueue addOperationWithBlock:^{
//            [userDef setObject:@"0" forKey:@"syncExpense"];
//            [userDef synchronize];
//            [TripDetailVC SyncExpenseData];
//        }];
////        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
////            [self getAllNote];
////        }];
////        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////            // sync expense
////            [userDef setObject:@"0" forKey:@"syncExpense"];
////            [userDef synchronize];
////            [TripDetailVC SyncExpenseData];
////        });
//    }
    if ([parent isKindOfClass:[ExpenseVC class]]) {
//        if (currentCategory == 1 && ((ExpenseVC*)parent).isFood == YES ) {
//            ((ExpenseVC*)parent).numberRow += 1;
//        }else if (currentCategory == 2 && ((ExpenseVC*)parent).isEnte == YES ) {
//            ((ExpenseVC*)parent).numberRow += 1;
//        }else if (currentCategory == 3 && ((ExpenseVC*)parent).isTaxi == YES ) {
//            ((ExpenseVC*)parent).numberRow += 1;
//        }else if (currentCategory == 4 && ((ExpenseVC*)parent).isShopping == YES ) {
//            ((ExpenseVC*)parent).numberRow += 1;
//        }else if (currentCategory == 5 && ((ExpenseVC*)parent).isGift == YES ) {
//            ((ExpenseVC*)parent).numberRow += 1;
//        }else if (currentCategory == 6 && ((ExpenseVC*)parent).isBussiness == YES ) {
//            ((ExpenseVC*)parent).numberRow += 1;
//        }
        
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus = [reach currentReachabilityStatus];
        if (netStatus == NotReachable) {
            //        [Common showNetworkFailureAlert];
        } else {
            NSOperationQueue *myQueue = [[NSOperationQueue alloc]init];
            [myQueue addOperationWithBlock:^{
                [userDef setObject:@"0" forKey:@"syncExpense"];
                [userDef synchronize];
                [TripDetailVC SyncExpenseData];
            }];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)validateDecimal:(NSString*)inputString{
    NSNumberFormatter * formatDecimal = [[NSNumberFormatter alloc] init];
    [formatDecimal setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [formatDecimal numberFromString:inputString];
    if (myNumber == Nil || [myNumber intValue] == 0) {
        return NO;
    }else
        return YES;
}
- (IBAction)btnYesClick:(id)sender {
    if ([lblContentConfirm.text isEqualToString:@"Are you sure you want to delete?"]) {
        viewConfirmCancel.hidden = YES;
        viewAddCategory.hidden   = YES;
        CategoryObj *currentCategoryObj = [mainArray objectAtIndex:currentCategory];
        currentCategoryObj.flag = 3;
        @synchronized(self)
        {
            [sqliteManager updateCategory:currentCategoryObj];
            [sqliteManager deleteExpenseCategory:currentCategoryObj.categoryId];
        }
        [mainArray removeObjectAtIndex:currentCategory];
        currentCategory = 0 ;
        [self getCategoryName];
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus = [reach currentReachabilityStatus];
        if (netStatus == NotReachable) {
            //        [Common showNetworkFailureAlert];
        } else {
            NSOperationQueue *myQueue = [[NSOperationQueue alloc]init];
            [myQueue addOperationWithBlock:^{
                [USER_DEFAULT setObject:@"0" forKey:@"syncCategory"];
                [USER_DEFAULT synchronize];
                [TripDetailVC SyncCategoryData];
            }];
        }
    }else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnNoClick:(id)sender {
    viewConfirmCancel.hidden = YES;
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
    return 3;
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
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 3, 200, 21)];
    lblTitle.text = @"Title";
    [lblTitle setFont:[UIFont boldSystemFontOfSize:13]];
    [cell.contentView addSubview:lblTitle];
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(60, 25, 200, 21)];
//    [lblDescription sizeToFit];
    lblDescription.text = @"Description";
    [lblDescription setFont:[UIFont systemFontOfSize:13]];
    [cell.contentView addSubview:lblDescription];
    
    UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(60, 47, 200, 21)];
    lblDate.text = @"Date";
    [lblDate setFont:[UIFont boldSystemFontOfSize:13]];
    [cell.contentView addSubview:lblDate];
    
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 50, self.view.frame.size.width, self.view.frame.size.height);
    if (tfAmount.text.length == 0) {
        tfAmount.text = [NSString stringWithFormat:@"$ %@",tfAmount.text];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == tfAmount) {
        if (tfAmount.text.length == 0) {
            tfAmount.text = [NSString stringWithFormat:@"$ "];
        }
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50, self.view.frame.size.width, self.view.frame.size.height);
    if (textField == tfAmount) {
        if ([tfAmount.text isEqualToString:@"$ "] || [tfAmount.text isEqualToString:@""]) {
            tfAmount.text = @"";
        }else{
            if (tfAmount.text.length < 2) {
                tfAmount.text=@"";
            }else if (![self validateDecimal:[tfAmount.text substringFromIndex:2]]) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Amount is invalid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                tfAmount.text=@"";
            }
        }
    }
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

- (IBAction)btnEditCategoryClick:(id)sender {
    if (currentCategory <= 5) {
        return;
    }
    CategoryObj *currentCategoryObj = [mainArray objectAtIndex:currentCategory];
    tfCategoryName.text = currentCategoryObj.title;
    viewAddCategory.hidden = NO;
    isEdit = YES;
    lblAddNewCategory.text = @"Edit Category";
    btnDelete.hidden = NO;
    btnIconDelete.hidden = NO;
}

- (IBAction)btnAddNewCategpryClick:(id)sender {
    tfCategoryName.text = @"";
    viewAddCategory.hidden = NO;
    isEdit = NO;
    btnDelete.hidden = YES;
    btnIconDelete.hidden = YES;
    lblAddNewCategory.text = @"Add New Category";
}

- (IBAction)btnSaveCategoryClick:(id)sender {
    viewAddCategory.hidden = YES;
    if (isEdit) {
        lblCategoryName.text = tfCategoryName.text;
        CategoryObj *currentCategoryObj = [mainArray objectAtIndex:currentCategory];
        currentCategoryObj.title = tfCategoryName.text;
        currentCategoryObj.flag = 2;
        @synchronized(self)
        {
            [sqliteManager updateCategory:currentCategoryObj];
        }
    }else{
        CategoryObj *objCat = [[CategoryObj alloc] init];
        objCat.title  = tfCategoryName.text;
        objCat.ownerUserId = [[USER_DEFAULT objectForKey:@"userId"] intValue];
        objCat.serverId    = 0;
        objCat.flag = 1;
        @synchronized(self)
        {
            [sqliteManager createTable:@"Categories"];
            [sqliteManager addCategoryInfor:objCat];
        }
        [self getNextColor];
    }
    [self getCategoryList];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        //        [Common showNetworkFailureAlert];
    } else {
        NSOperationQueue *myQueue = [[NSOperationQueue alloc]init];
        [myQueue addOperationWithBlock:^{
            [USER_DEFAULT setObject:@"0" forKey:@"syncCategory"];
            [USER_DEFAULT synchronize];
            [TripDetailVC SyncCategoryData];
        }];
    }
}

- (IBAction)btnDeleteClick:(id)sender {
    [self.view endEditing:YES];
    viewConfirmCancel.hidden = NO;
    lblContentConfirm.text = @"Are you sure you want to delete?";
}

- (IBAction)btnCancelClick:(id)sender {
    viewAddCategory.hidden = YES;
}
// get next color
- (void) getNextColor{
    float randomRed    = arc4random() % 255;
    float randomGreen  = arc4random() % 255;
    float randomBlue   = arc4random() % 255;
    NSInteger HexRed   = randomRed;
    NSInteger HexGreen = randomGreen;
    NSInteger HexBlue  = randomBlue;
    NSString *strNewColor = [NSString stringWithFormat:@"%X%x%x",HexRed,HexGreen,HexBlue];
    BOOL isExist = false;
    for (int i = 0; i < delegate.arrayColor.count; i++) {
        NSString *strColor = [delegate.arrayColor objectAtIndex:i];
        if ([strNewColor isEqualToString:strColor]) {
            isExist = true;
            break;
        }
    }
    if (isExist) {
        [self getNextColor];
    }else{
        [delegate.arrayColor addObject:strNewColor];
        @synchronized(self)
        {
            [sqliteManager createTable:@"Colors"];
            [sqliteManager addColor:strNewColor];
        }
    }
}
@end
