//
//  DialogLogOutVC.h
//  Fun Spot App
//
//  Created by MAC on 8/27/14.
//
//

#import <UIKit/UIKit.h>

@interface DialogLogOutVC : UIViewController{
    
    IBOutlet UIImageView *bgImgLogOur;
    UIViewController *m_parentViewController;
}
- (IBAction)btnYesClick:(id)sender;
- (IBAction)btnNoClick:(id)sender;

@end
