//
//  PackingItemObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface PackingItemObj : NSObject{
    NSInteger itemId;
    NSString *itemName;
    NSInteger isCheck;
    NSInteger packingId;
    NSInteger serverId;
    NSInteger flag;
    NSInteger idAddNew;
}
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic) NSInteger itemId;
@property (nonatomic) NSInteger packingId;
@property (nonatomic) NSInteger isCheck;
@property (nonatomic) NSInteger serverId;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger idAddNew;
@end