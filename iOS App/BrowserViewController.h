//
//  BrowserViewController.h
//  Fun Spot App
//
//  Created by PradeepSundriyal on 23/07/13.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BaseViewController.h"

@interface BrowserViewController : BaseViewController<UIWebViewDelegate>{
    AppDelegate *delegate;
    IBOutlet UIToolbar *toolBar;
    bool isFromTab;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *URL;
@property (nonatomic, strong)     IBOutlet UIToolbar *toolBar;
@property (nonatomic)  bool isFromTab;

@end
