//
//  PremadeListObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface PremadeListObj : NSObject{
    NSInteger listId;
    NSString *title;
    NSInteger serverId;
    NSInteger flag;
    NSInteger isCheck;
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSInteger listId;
@property (nonatomic) NSInteger serverId;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger isCheck;
@end