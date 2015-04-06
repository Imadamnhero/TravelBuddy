//
//  PremadeItemObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface PremadeItemObj : NSObject{
    NSInteger itemId;
    NSString *itemName;
    NSInteger listId;
    NSInteger serverId;
    NSInteger flag;
    NSInteger isCheck;
}
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic) NSInteger itemId;
@property (nonatomic) NSInteger listId;
@property (nonatomic) NSInteger serverId;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger isCheck;
@end