//
//  User.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface User : NSObject{
    NSInteger userId;
    NSInteger userInTripId;
    NSInteger tripId;
    NSString *name;
    NSString *avatarUrl;
    UIImage *userIcon;
    NSInteger isCheck;
}
@property (nonatomic) NSInteger userId,tripId,userInTripId,isCheck;
@property (nonatomic, strong) NSString *name,*avatarUrl;
@property(nonatomic, strong) UIImage *userIcon;
@end
