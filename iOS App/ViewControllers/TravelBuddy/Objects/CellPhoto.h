//
//  CellPhoto.h
//  SpyTool
//
//  Created by Tran Thanh Bang on 11/14/14.
//  Copyright (c) 2014 thanhbang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellPhoto : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *myImage;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UIButton *btnUpload;
@property (weak, nonatomic) IBOutlet UIButton *btnUpLoadPhoto;


@end
