//
//  PhotoObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface PhotoObj : NSObject{
    NSInteger photoId;
    NSString *caption;
    NSString *urlPhoto;
    NSInteger isReceipt;
    NSInteger ownerUserId;
    NSInteger tripId;
    NSInteger serverId;
    NSInteger flag;
    NSInteger isChecked;
    NSInteger tagPhoto;
    
    UIImage *imageThumbnail;
}
@property (nonatomic, strong) UIImage *imageThumbnail;
@property (nonatomic, strong) NSString *caption,*urlPhoto;
@property (nonatomic) NSInteger photoId;
@property (nonatomic) NSInteger isReceipt;
@property (nonatomic) NSInteger ownerUserId;
@property (nonatomic) NSInteger tripId;
@property (nonatomic) NSInteger serverId;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger isChecked;
@property (nonatomic) NSInteger tagPhoto;
@end