//
//  NewCellPhoto.h
//  Fun Spot App
//
//  Created by Luong Hoang Anh on 12/23/14.
//
//

#import <UIKit/UIKit.h>

@interface NewCellPhoto : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *myImage;
@property (weak, nonatomic) IBOutlet UIButton *myBtnUpLoad;
@property (weak, nonatomic) IBOutlet UIImageView *myImageBg;
@property (weak, nonatomic) IBOutlet UILabel *myLblCaption;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *myActivity;

@end
