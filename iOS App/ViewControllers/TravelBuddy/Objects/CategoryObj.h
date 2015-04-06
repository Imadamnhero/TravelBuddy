//
//  CategoryObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface CategoryObj : NSObject{
    NSInteger categoryId;
    NSString *title;
    NSString *color;
    NSInteger ownerUserId;
    NSInteger serverId;
    NSInteger flag;
    UIImage *imageThumbnail;
    NSString *amount;
    NSString *percent;
    NSInteger isChecked;
    NSInteger numberItem;
    NSMutableArray *arrayExp;
}
@property (nonatomic, strong) NSMutableArray *arrayExp;
@property (nonatomic, strong) NSString *title,*color,*amount,*percent;
@property (nonatomic) NSInteger categoryId;
@property (nonatomic) NSInteger ownerUserId;
@property (nonatomic) NSInteger serverId;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger isChecked;
@property (nonatomic) NSInteger numberItem;
@end