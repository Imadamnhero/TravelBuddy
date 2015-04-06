//
//  LoadingViewController.h
//  i-ZooConnect
//
//  Created by Aniket on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface LoadingViewController : UIViewController {
	AppDelegate *delegate;

}
-(BOOL)connectedToNetwork;
-(void)removeLoadingView;
-(void)removeSplashView;
-(void)changeText:(int)num;
-(void)removeSplashView;

@end
