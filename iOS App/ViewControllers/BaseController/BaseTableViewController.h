//
//  BaseTableViewController.h
//  Fun Spot App
//
//  Created by  Rawat on 08/02/13.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "UIColor-Expanded.h"

@interface BaseTableViewController : UITableViewController

@property (nonatomic,strong) AppDelegate *appDelagte;

- (void)setNavigationButons;
- (void)actionLocation:(id)sender;
- (void)actionGallery:(id)sender;
@end
