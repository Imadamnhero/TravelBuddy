//
//  LeftTabBarViewController.h
//  Fun Spot App
//
//  Created by wang chenglei on 1/30/14.
//
//

#import <UIKit/UIKit.h>
#import "ANICustomButton.h"

#define ColorHighlighted [UIColor colorWithRed:132/255.0 green:201/255.0 blue:45/255.0 alpha:1.0]
#define ColorSelected [UIColor colorWithRed:43/255.0 green:140/255.0 blue:204/255.0 alpha:1.0]

#define WIDTH               120
#define HEIGHT              40

#define SCROLL_TAG          20000
#define LEFT_TAB_ITME_TAG   20001

@protocol LeftTabBarIconDownloadDelegate;

@interface LeftTabBarViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    UIViewController *m_parentViewController;
    UIView *m_parentView;
    
    NSMutableArray *imageName;
    
    NSString *strSelTabName;
    IBOutlet UIView *viewLogOut;
}

@property (nonatomic, weak) id <LeftTabBarIconDownloadDelegate> lefTabBarDelegate;

@property (strong, nonatomic) NSMutableArray *buttonTitles;
@property (strong, nonatomic) NSMutableArray *buttonIcons;
@property (strong, nonatomic) NSMutableArray *defaultButtonIcons;
@property (strong, nonatomic) NSMutableArray *eventPlaceArr;

@property (strong, nonatomic) UIViewController *m_parentViewController;
@property (strong, nonatomic) UIView *m_parentView;

- (void)createButtons;
- (void)showLeftTabBar:(UIView *)parentView show:(BOOL)bShow delegate:(UIViewController *)parentViewController rect:(CGRect)rect selected:(NSString *)selectedName;
- (void)setLinkToggleButtonImage:(UIViewController *)parentViewController;
- (void)actionButton:(id)sender;
@end

@protocol LeftTabBarIconDownloadDelegate <NSObject>

- (void)leftTabBarIconDownloadDidFinished;

@end