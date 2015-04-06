//
//  NewListVC.m
//  Fun Spot App
//
//  Created by Luong Anh on 8/15/14.
//
//

#import "NewListVC.h"
#import "CustomeListVC.h"
#import "AddNewListVC.h"

@interface NewListVC ()

@end

@implementation NewListVC

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
    btnHome.imageEdgeInsets = UIEdgeInsetsMake(7, 12, 7, 8);
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, main_top, self.view.frame.size.width-200, mainRect.size.height-main_top)];
    self.itemsView.hidden = YES;
    [self.view addSubview:self.itemsView];
    
    mainArray = [[NSMutableArray alloc] init];
    bgImgSubView.layer.cornerRadius = 4.0;
    NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom1.png",@"imageName",@"Miami",@"name",@"1",@"status", nil];
    [mainArray addObject:dict3];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom1.png",@"imageName",@"Beach",@"name",@"0",@"status", nil];
    [mainArray addObject:dict];
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom2.png",@"imageName",@"Glass",@"name",@"0",@"status", nil];
    [mainArray addObject:dict1];
    NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"imagesTom3.png",@"imageName",@"Sunshine",@"name",@"0",@"status", nil];
    [mainArray addObject:dict2];
    mainTable.allowsSelectionDuringEditing = YES;
    mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
    [self getPremadeList];
}
- (void)getPremadeList{
    [mainArray removeAllObjects];
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    @synchronized(self)
    {
        mainArray = [sqliteManager getPremadeList];
    }
    if (mainArray.count < 7 && mainArray.count >0) {
        mainTable.frame = CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width,mainArray.count*44);
    }
    
//    CGRect rectBtnSave = btnSave.frame;
//    rectBtnSave.origin.y = mainTable.frame.origin.y + mainTable.frame.size.height + 20;
//    btnSave.frame = rectBtnSave;
//    
//    CGRect rectBtnCancel = btnCancel.frame;
//    rectBtnCancel.origin.y = mainTable.frame.origin.y + mainTable.frame.size.height + 20;
//    btnCancel.frame = rectBtnCancel;
    
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
    PremadeListObj *preObj = [[PremadeListObj alloc] init];
    preObj = [mainArray objectAtIndex:indexPath.row];
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(55, 12, 200, 21)];
    lblDescription.text = [NSString stringWithFormat:@"%@",preObj.title];//@"Description";
    [lblDescription setFont:[UIFont boldSystemFontOfSize:15]];
    [cell.contentView addSubview:lblDescription];
    
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(7, 7, 30, 30)];
    btnCheck.tag = indexPath.row + 5000;
    [btnCheck addTarget:self action:@selector(checkBoxSelected:) forControlEvents:UIControlEventTouchUpInside];
    NSString* strStatus =@"radio_button.png";
    if (preObj.isCheck == 1) {
        strStatus = @"radio_button_check.png";
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
    PremadeListObj *premadeObj = [[PremadeListObj alloc] init];
    for (int i = 0 ; i < mainArray.count ; i++) {
        PremadeListObj *preObj = [[PremadeListObj alloc] init];
        preObj = [mainArray objectAtIndex:i];
        if (i == indexPath.row) {
            preObj.isCheck = 1;
            premadeObj = preObj;
        }else
            preObj.isCheck = 0;
    }
    [mainTable reloadData];
    
    AddNewListVC *EditListVCController = [[AddNewListVC alloc] initWithNibName:@"AddNewListVC" bundle:Nil];
    EditListVCController.premadeListId = premadeObj.listId;
    EditListVCController.strTitle = premadeObj.title;
    [self.navigationController pushViewController:EditListVCController animated:YES];
}

// action event of check box
- (void)checkBoxSelected:(id)sender{
    UIButton *btn = (UIButton*)sender;
    int tag = btn.tag - 5000;
    PremadeListObj *premadeObj = [[PremadeListObj alloc] init];
    for (int i = 0 ; i < mainArray.count ; i++) {
        PremadeListObj *preObj = [[PremadeListObj alloc] init];
        preObj = [mainArray objectAtIndex:i];
        if (i == tag) {
            preObj.isCheck = 1;
            premadeObj = preObj;
        }else
            preObj.isCheck = 0;
    }
    [mainTable reloadData];
    AddNewListVC *EditListVCController = [[AddNewListVC alloc] initWithNibName:@"AddNewListVC" bundle:Nil];
    EditListVCController.premadeListId = premadeObj.listId;
    EditListVCController.strTitle = premadeObj.title;
    [self.navigationController pushViewController:EditListVCController animated:YES];
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
