//
//  CellGroup.h
//  Fun Spot App
//
//  Created by LE MINH TRI on 9/25/14.
//
//

#import <UIKit/UIKit.h>

@interface CellGroup : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgNote;
@property (weak, nonatomic) IBOutlet UILabel *lbtitle;
@property (weak, nonatomic) IBOutlet UILabel *lbdescrsiption;
@property (weak, nonatomic) IBOutlet UILabel *lbdatetime;
@end
