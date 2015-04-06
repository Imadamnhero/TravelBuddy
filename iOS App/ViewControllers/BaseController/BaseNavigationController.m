//
//  BaseNavigationController.m
//  Fun Spot App
//
//  Created by PradeepSundriyal on 31/07/13.
//
//

#import "BaseNavigationController.h"
#import "UIColor-Expanded.h"
//#import "CustomMovieViewController.h"

@interface BaseNavigationController ()

@property (nonatomic,strong) AppDelegate *delegate;

@end



@implementation BaseNavigationController

@synthesize appDelagte = _appDelagte;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	// Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
//    if ([self.topViewController isKindOfClass:[CustomMovieViewController class]]) {
//        return UIInterfaceOrientationMaskLandscape;
//    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
//    if ([self.topViewController isKindOfClass:[CustomMovieViewController class]]) {
//        return YES;
//    }
    
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    
//    if ([self.topViewController isKindOfClass:[CustomMovieViewController class]]) {
//        return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
//    }
    
    return UIInterfaceOrientationPortrait;
}

@end
