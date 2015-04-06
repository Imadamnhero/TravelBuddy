//
//  BaseViewController.h
//  Fun Spot App
//
//  Created by  Rawat on 08/02/13.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
//#import "ANIPlaceService.h"
#import "UIColor-Expanded.h"


@interface BaseViewController : UIViewController

@property (nonatomic,strong) AppDelegate *appDelagte;

- (void)setNavigationButons;
- (void)actionLocation:(id)sender;
- (void)actionGallery:(id)sender;
//- (UIImage *)imageWithTint:(UIColor *)tintColor;
@end
